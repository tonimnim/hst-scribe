import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/core/obs/logger.dart';
import 'package:hst_scribe/features/session/data/session_repository.dart';
import 'package:hst_scribe/features/sign/domain/sign_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_controller.g.dart';

/// Whether biometric auth is available at all on this build.
///
/// Wave 1 of the mobile codebase has `local_auth` commented out in
/// pubspec.yaml because of a Windows codegen blocker; this flag reflects
/// that. Set to `false` while the dep is disabled. When agent 3 re-enables
/// `local_auth`, flip this to `true` (or replace with a runtime probe via
/// `LocalAuthentication.canCheckBiometrics`).
const bool _biometricAvailable = false;

/// Drives the sign-off flow.
///
/// Lifecycle:
///   * UI calls [beginSign] → controller flips state through
///     `summarizing → promptingBiometric / promptingPin`.
///   * On biometric success or PIN submission, the controller POSTs
///     `/sessions/{id}/sign` and emits `success` or `error`.
///
/// The actual biometric prompt UI lives in the screen, NOT in the
/// controller — `local_auth` requires a `BuildContext`-bound platform
/// channel call and we keep widgets out of controllers per AGENTS.md.
@riverpod
class SignController extends _$SignController {
  static const AppLogger _log = AppLogger('SignController');

  @override
  SignState build(String sessionId) {
    return const SignState.idle();
  }

  /// Move into the prompt phase. UI then shows either biometric or PIN.
  ///
  /// If [forcePin] is true (e.g. the nurse explicitly chose "Use PIN"),
  /// skip the biometric path entirely. Same outcome if biometric isn't
  /// available at all.
  void beginSign({bool forcePin = false}) {
    if (state is SubmittingSignState || state is SuccessSignState) return;
    _log.info(
      'beginSign',
      data: <String, Object?>{
        'session_id': sessionId,
        'force_pin': forcePin,
        'biometric_available': _biometricAvailable,
      },
    );
    state = const SignState.summarizing();
    final useBiometric = _biometricAvailable && !forcePin;
    state =
        useBiometric
            ? const SignState.promptingBiometric()
            : const SignState.promptingPin();
  }

  /// Switch from biometric to PIN. UI calls this when the user taps
  /// "Use PIN instead" or biometric fails.
  void fallbackToPin() {
    if (state is SubmittingSignState || state is SuccessSignState) return;
    _log.info(
      'fallbackToPin',
      data: <String, Object?>{'session_id': sessionId},
    );
    state = const SignState.promptingPin();
  }

  /// Reset to idle (used by retry).
  void reset() {
    state = const SignState.idle();
  }

  /// Submit a signed session.
  ///
  /// [authMethod] is `biometric` or `pin` per CONTRACT.md §1.
  /// [authToken] is the biometric assertion (Phase B: an attestation
  /// blob from `local_auth`; Wave 1: a sentinel string the dev backend
  /// accepts) or the 6-digit PIN.
  Future<void> submit({
    required String authMethod,
    required String authToken,
  }) async {
    if (state is SubmittingSignState || state is SuccessSignState) return;
    state = const SignState.submitting();
    final repo = ref.read(sessionRepositoryProvider);
    try {
      final body = await repo.signSession(
        sessionId: sessionId,
        authMethod: authMethod,
        authToken: authToken,
      );
      final signed = SignedSession.fromWire(body);
      _log.info(
        'session signed',
        data: <String, Object?>{
          'session_id': sessionId,
          'events_written': signed.eventsWritten,
          'events_rejected': signed.eventsRejected,
        },
      );
      state = SignState.success(signed: signed);
    } on AppFailure catch (failure, st) {
      _log.warn(
        'sign failed',
        error: failure,
        stackTrace: st,
        data: <String, Object?>{'session_id': sessionId},
      );
      state = SignState.error(failure: failure);
    } on FormatException catch (e, st) {
      _log.warn(
        'sign response malformed',
        error: e,
        stackTrace: st,
        data: <String, Object?>{'session_id': sessionId},
      );
      state = SignState.error(
        failure: AppFailure.unexpected(
          message: 'Malformed sign response: ${e.message}',
        ),
      );
    }
  }
}

/// Synchronous accessor: is biometric available in this build?
///
/// Exposed so the UI can label the primary CTA appropriately ("Sign with
/// Face ID" vs "Enter PIN") without poking at the local_auth API.
@riverpod
bool biometricAvailable(BiometricAvailableRef ref) => _biometricAvailable;
