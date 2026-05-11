import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_failure.freezed.dart';

/// Wire-level error code per `contract/CONTRACT.md` §Error codes.
///
/// String name (Dart `name` is the camelCase variant); the wire value is
/// snake_case, see [WireErrorCodeX.wireCode].
enum WireErrorCode {
  authInvalid,
  authForbidden,
  sessionNotFound,
  sessionExpired,
  patientLocked,
  audioFormatUnsupported,
  chunkOutOfOrder,
  rateLimited,
  extractorFailed,
  internal;

  static WireErrorCode? fromWire(String? raw) {
    switch (raw) {
      case 'auth_invalid':
        return WireErrorCode.authInvalid;
      case 'auth_forbidden':
        return WireErrorCode.authForbidden;
      case 'session_not_found':
        return WireErrorCode.sessionNotFound;
      case 'session_expired':
        return WireErrorCode.sessionExpired;
      case 'patient_locked':
        return WireErrorCode.patientLocked;
      case 'audio_format_unsupported':
        return WireErrorCode.audioFormatUnsupported;
      case 'chunk_out_of_order':
        return WireErrorCode.chunkOutOfOrder;
      case 'rate_limited':
        return WireErrorCode.rateLimited;
      case 'extractor_failed':
        return WireErrorCode.extractorFailed;
      case 'internal':
        return WireErrorCode.internal;
      default:
        return null;
    }
  }
}

extension WireErrorCodeX on WireErrorCode {
  String get wireCode {
    switch (this) {
      case WireErrorCode.authInvalid:
        return 'auth_invalid';
      case WireErrorCode.authForbidden:
        return 'auth_forbidden';
      case WireErrorCode.sessionNotFound:
        return 'session_not_found';
      case WireErrorCode.sessionExpired:
        return 'session_expired';
      case WireErrorCode.patientLocked:
        return 'patient_locked';
      case WireErrorCode.audioFormatUnsupported:
        return 'audio_format_unsupported';
      case WireErrorCode.chunkOutOfOrder:
        return 'chunk_out_of_order';
      case WireErrorCode.rateLimited:
        return 'rate_limited';
      case WireErrorCode.extractorFailed:
        return 'extractor_failed';
      case WireErrorCode.internal:
        return 'internal';
    }
  }
}

/// Typed failure surface for the entire app. UI never sees raw exceptions.
///
/// All async results travel as `AsyncValue<T>`; data-layer code catches
/// implementation errors and maps to one of these variants. UI switches
/// on the variant to choose copy and behaviour.
@freezed
sealed class AppFailure with _$AppFailure {
  /// A typed wire error from the server (REST or WSS) using the codes in
  /// `contract/CONTRACT.md` §Error codes.
  const factory AppFailure.wire({
    required WireErrorCode code,
    required String message,
    Map<String, Object?>? details,
  }) = WireAppFailure;

  /// Transport-level problem: no internet, TLS handshake failed, WSS dropped
  /// while reconnecting, REST timeout. Distinct from server-returned errors.
  const factory AppFailure.network({required String message, Object? cause}) =
      NetworkAppFailure;

  /// Authentication state has fallen below the required level — e.g. token
  /// refresh exhausted, biometric prompt failed, MDM revoked tokens.
  const factory AppFailure.unauthenticated({required String message}) =
      UnauthenticatedAppFailure;

  /// Local hardware or platform problem — mic permission denied, audio
  /// device unavailable, secure storage unreachable.
  const factory AppFailure.platform({required String message, String? code}) =
      PlatformAppFailure;

  /// Catch-all for genuinely unexpected exceptions. Logged with stack trace.
  /// Surface to the user as a generic "something went wrong" message.
  const factory AppFailure.unexpected({
    required String message,
    Object? cause,
    StackTrace? stackTrace,
  }) = UnexpectedAppFailure;

  /// Map a wire-error envelope (per CONTRACT.md) to an [AppFailure].
  /// Falls back to [WireErrorCode.internal] if [code] is unknown.
  factory AppFailure.fromWireError(
    String code,
    String message, {
    Map<String, Object?>? details,
  }) {
    final parsed = WireErrorCode.fromWire(code) ?? WireErrorCode.internal;
    return AppFailure.wire(code: parsed, message: message, details: details);
  }
}
