import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/core/auth/auth_providers.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/core/net/api_client.dart';
import 'package:hst_scribe/core/obs/logger.dart';
import 'package:hst_scribe/features/session/domain/session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_repository.g.dart';

/// REST data layer for the session lifecycle.
///
/// Endpoints (CONTRACT.md §1):
///  * `POST   /sessions`             → create + lock to patient
///  * `GET    /sessions/{id}`        → summary
///  * `POST   /sessions/{id}/sign`   → finalize and write to eChart
class SessionRepository {
  SessionRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  static const AppLogger _log = AppLogger('SessionRepository');

  final ApiClient _apiClient;

  /// Create a session locked to [patientId].
  ///
  /// Idempotent on the server: an existing `(asc_id, patient_id, user_id)`
  /// active session is returned as-is.
  ///
  /// Maps a 409 `patient_locked` to [AppFailure.wire] with
  /// [WireErrorCode.patientLocked].
  Future<Session> createSession({
    required String ascId,
    required String patientId,
    WorkflowType workflowType = WorkflowType.pacu,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, Object?>>(
        '/sessions',
        data: <String, Object?>{
          'asc_id': ascId,
          'patient_id': patientId,
          'workflow_type': workflowType.wireValue,
        },
      );
      final body = response.data;
      if (body == null) {
        throw const FormatException('Empty POST /sessions response');
      }
      final session = Session.fromWire(body);
      _log.info(
        'session created',
        data: <String, Object?>{
          'session_id': session.id,
          'asc_id': ascId,
          'patient_id': patientId,
        },
      );
      return session;
    } on DioException catch (e, st) {
      throw _apiClient.mapError(e, st);
    } on FormatException catch (e) {
      throw AppFailure.unexpected(
        message: 'Bad POST /sessions response: ${e.message}',
      );
    }
  }

  /// Fetch the full session summary.
  Future<Session> getSession(String sessionId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, Object?>>(
        '/sessions/$sessionId',
      );
      final body = response.data;
      if (body == null) {
        throw const FormatException('Empty GET /sessions/{id} response');
      }
      return Session.fromWire(body);
    } on DioException catch (e, st) {
      throw _apiClient.mapError(e, st);
    } on FormatException catch (e) {
      throw AppFailure.unexpected(
        message: 'Bad GET /sessions/{id} response: ${e.message}',
      );
    }
  }

  /// Sign the session. `auth_method` ∈ `biometric | pin`.
  Future<Map<String, Object?>> signSession({
    required String sessionId,
    required String authMethod,
    required String authToken,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, Object?>>(
        '/sessions/$sessionId/sign',
        data: <String, Object?>{
          'auth_method': authMethod,
          'auth_token': authToken,
        },
      );
      final body = response.data;
      if (body == null) {
        throw const FormatException('Empty POST /sessions/{id}/sign response');
      }
      _log.info(
        'session signed',
        data: <String, Object?>{
          'session_id': sessionId,
          'events_written': body['events_written'],
          'events_rejected': body['events_rejected'],
        },
      );
      return body;
    } on DioException catch (e, st) {
      throw _apiClient.mapError(e, st);
    }
  }
}

@Riverpod(keepAlive: true)
SessionRepository sessionRepository(SessionRepositoryRef ref) =>
    SessionRepository(apiClient: ref.watch(apiClientProvider));

/// Holder for the currently active session created by the start flow.
///
/// Wave-2 capture agent reads this to obtain the WSS URL + patient context.
/// Independent of [authControllerProvider] — we want the session to survive
/// silent token refresh without rebuilding.
@Riverpod(keepAlive: true)
class ActiveSession extends _$ActiveSession {
  @override
  Session? build() => null;

  void set(Session session) {
    state = session;
  }

  void clear() {
    state = null;
  }
}
