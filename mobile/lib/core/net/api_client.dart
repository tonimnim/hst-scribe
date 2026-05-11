import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/core/auth/auth_providers.dart';
import 'package:hst_scribe/core/auth/oauth_pkce_flow.dart';
import 'package:hst_scribe/core/auth/token_store.dart';
import 'package:hst_scribe/core/config/app_config.dart';
import 'package:hst_scribe/core/config/app_config_provider.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/core/obs/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

/// Singleton REST client wired against [AppConfig.apiBaseUrl] with:
///  * Bearer token attached from [TokenStore] on every request.
///  * Single-shot 401 → refresh → retry. Second 401 surfaces as
///    [AppFailure.unauthenticated] and clears the token store.
///  * Response errors mapped to [AppFailure] (wire / network / unexpected).
///  * Request lifecycle logged via [AppLogger]: URL + status + duration
///    only — never bodies, which may contain PHI.
@Riverpod(keepAlive: true)
ApiClient apiClient(ApiClientRef ref) {
  final config = ref.watch(appConfigProvider);
  final store = ref.watch(tokenStoreProvider);
  final flow = ref.watch(oauthPkceFlowProvider);
  final client = ApiClient(
    config: config,
    tokenStore: store,
    pkceFlow: flow,
    onTokenExpired: () =>
        ref.read(authControllerProvider.notifier).onTokenExpiredFromApi(),
  );
  ref.onDispose(client.dispose);
  return client;
}

/// Wraps a [Dio] instance with HST-Scribe auth behaviour.
///
/// Test usage: pass in a `Dio` constructed against a `MockAdapter` (or
/// `mocktail` interceptor) and observe outbound requests / errors.
class ApiClient {
  ApiClient({
    required AppConfig config,
    required TokenStore tokenStore,
    required OauthPkceFlow pkceFlow,
    required this.onTokenExpired,
    Dio? dio,
  }) : _config = config,
       _tokenStore = tokenStore,
       _pkceFlow = pkceFlow,
       dio = dio ?? Dio() {
    this.dio.options = BaseOptions(
      baseUrl: '${config.apiBaseUrl}/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: <String, Object?>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    this.dio.interceptors.add(_AuthInterceptor(this));
    this.dio.interceptors.add(_LoggingInterceptor());
  }

  static const AppLogger _log = AppLogger('ApiClient');

  final AppConfig _config;
  final TokenStore _tokenStore;
  final OauthPkceFlow _pkceFlow;

  /// Called when refresh fails. Wired to [AuthController.onTokenExpiredFromApi].
  final void Function() onTokenExpired;

  /// Underlying Dio. Exposed so feature repositories can call directly.
  final Dio dio;

  AppConfig get config => _config;

  void dispose() {
    dio.close(force: true);
  }

  // ---------------- Internal: token refresh path ----------------

  Future<TokenBundle?> _readBundle() => _tokenStore.read();

  /// Attempt a refresh. Returns the new bundle, or null if it failed.
  /// On failure the token store is cleared and [onTokenExpired] is invoked.
  Future<TokenBundle?> _refreshOrDie() async {
    final current = await _tokenStore.read();
    if (current == null) {
      onTokenExpired();
      return null;
    }
    try {
      final refreshed = await _pkceFlow.refresh(current);
      await _tokenStore.write(refreshed);
      _log.info(
        'token refreshed via 401 path',
        data: <String, Object?>{'user_id': refreshed.userId},
      );
      return refreshed;
    } on AppFailure catch (e) {
      _log.warn('401 refresh failed — clearing tokens', data: <String, Object?>{
        'failure': e.toString(),
      });
      await _tokenStore.clear();
      onTokenExpired();
      return null;
    } catch (e, st) {
      _log.warn(
        '401 refresh threw — clearing tokens',
        error: e,
        stackTrace: st,
      );
      await _tokenStore.clear();
      onTokenExpired();
      return null;
    }
  }

  /// Map a [DioException] (or any thrown object) to a typed [AppFailure].
  ///
  /// Visible so feature repositories can wrap their own try/catch around
  /// non-Dio calls (e.g. JSON parse) and use the same envelope.
  AppFailure mapError(Object error, [StackTrace? stack]) {
    if (error is DioException) {
      final response = error.response;
      if (response != null) {
        final body = response.data;
        if (body is Map<String, Object?>) {
          final code = body['code'];
          final message = body['message'];
          if (code is String && message is String) {
            return AppFailure.fromWireError(
              code,
              message,
              details:
                  (body['details'] as Map<Object?, Object?>?)
                      ?.cast<String, Object?>(),
            );
          }
        }
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return AppFailure.network(
            message: 'Request timed out',
            cause: error,
          );
        case DioExceptionType.connectionError:
          return AppFailure.network(
            message: 'Network unreachable',
            cause: error,
          );
        case DioExceptionType.cancel:
          return AppFailure.network(
            message: 'Request cancelled',
            cause: error,
          );
        case DioExceptionType.badCertificate:
          return AppFailure.network(
            message: 'TLS certificate rejected',
            cause: error,
          );
        case DioExceptionType.badResponse:
          // 401 already handled by interceptor; surface as generic wire failure.
          final status = error.response?.statusCode ?? 0;
          return AppFailure.wire(
            code: WireErrorCode.internal,
            message: 'HTTP $status',
            details: <String, Object?>{'status': status},
          );
        case DioExceptionType.unknown:
          return AppFailure.unexpected(
            message: 'Unexpected HTTP error: ${error.message}',
            cause: error.error,
            stackTrace: stack ?? error.stackTrace,
          );
      }
    }
    return AppFailure.unexpected(
      message: 'Unexpected error: $error',
      cause: error,
      stackTrace: stack,
    );
  }
}

/// Attaches `Authorization: Bearer <access_token>` and handles single 401 retry.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._client);

  final ApiClient _client;
  static const AppLogger _log = AppLogger('ApiClient.auth');

  /// Guard set on a request after a retry attempt so we never loop.
  static const String _retriedFlag = 'x-hst-retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final bundle = await _client._readBundle();
    if (bundle != null) {
      options.headers['Authorization'] = 'Bearer ${bundle.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final wasRetried = err.requestOptions.extra[_retriedFlag] == true;
    if (status == 401 && !wasRetried) {
      _log.info(
        '401 received — attempting refresh + retry',
        data: <String, Object?>{
          'path': err.requestOptions.path,
        },
      );
      final refreshed = await _client._refreshOrDie();
      if (refreshed == null) {
        // Token-store was cleared; propagate as unauth failure.
        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: DioExceptionType.badResponse,
            error: const AppFailure.unauthenticated(
              message: 'Token expired',
            ),
          ),
        );
        return;
      }
      // Retry with the new token. Mark the request so we don't loop.
      final retryOptions = err.requestOptions
        ..extra[_retriedFlag] = true
        ..headers['Authorization'] = 'Bearer ${refreshed.accessToken}';
      try {
        final retried = await _client.dio.fetch<Object?>(retryOptions);
        handler.resolve(retried);
        return;
      } on DioException catch (retryError) {
        handler.next(retryError);
        return;
      }
    }
    handler.next(err);
  }
}

/// PHI-safe request logger.
///
/// Logs URL (method + path + query keys, not values), status, and duration.
/// NEVER logs request or response bodies — they may carry PHI.
class _LoggingInterceptor extends Interceptor {
  _LoggingInterceptor();

  static const AppLogger _log = AppLogger('ApiClient.http');
  static const String _startKey = 'x-hst-start';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final start = response.requestOptions.extra[_startKey];
    final durationMs = start is int
        ? DateTime.now().millisecondsSinceEpoch - start
        : -1;
    _log.info(
      'http ${response.requestOptions.method} ${response.requestOptions.path}',
      data: <String, Object?>{
        'status': response.statusCode,
        'duration_ms': durationMs,
      },
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final start = err.requestOptions.extra[_startKey];
    final durationMs = start is int
        ? DateTime.now().millisecondsSinceEpoch - start
        : -1;
    _log.warn(
      'http ${err.requestOptions.method} ${err.requestOptions.path} failed',
      data: <String, Object?>{
        'status': err.response?.statusCode,
        'duration_ms': durationMs,
        'type': err.type.name,
      },
    );
    handler.next(err);
  }
}
