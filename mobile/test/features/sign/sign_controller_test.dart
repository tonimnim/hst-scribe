import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/features/session/data/session_repository.dart';
import 'package:hst_scribe/features/sign/data/sign_controller.dart';
import 'package:hst_scribe/features/sign/domain/sign_state.dart';
import 'package:mocktail/mocktail.dart';

/// Mock session repository — bypasses ApiClient entirely.
class _MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  const String sid = 'session-1';

  group('SignController.beginSign', () {
    test('idle → promptingPin when biometric unavailable', () {
      final repo = _MockSessionRepository();
      final container = ProviderContainer(
        overrides: <Override>[
          sessionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(signControllerProvider(sid).notifier);
      expect(container.read(signControllerProvider(sid)), isA<IdleSignState>());
      notifier.beginSign();
      // Wave 1: biometric is hard-coded unavailable, so we expect promptingPin.
      expect(
        container.read(signControllerProvider(sid)),
        isA<PromptingPinSignState>(),
      );
    });

    test('forcePin always picks the PIN branch', () {
      final repo = _MockSessionRepository();
      final container = ProviderContainer(
        overrides: <Override>[
          sessionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(signControllerProvider(sid).notifier);
      notifier.beginSign(forcePin: true);
      expect(
        container.read(signControllerProvider(sid)),
        isA<PromptingPinSignState>(),
      );
    });
  });

  group('SignController.submit', () {
    test('flips through submitting → success on 200', () async {
      final repo = _MockSessionRepository();
      when(
        () => repo.signSession(
          sessionId: any(named: 'sessionId'),
          authMethod: any(named: 'authMethod'),
          authToken: any(named: 'authToken'),
        ),
      ).thenAnswer(
        (_) async => <String, Object?>{
          'session_id': sid,
          'status': 'signed',
          'signed_at': '2026-05-11T14:58:12-04:00',
          'events_written': 14,
          'events_rejected': 2,
        },
      );
      final container = ProviderContainer(
        overrides: <Override>[
          sessionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(signControllerProvider(sid).notifier);
      notifier.beginSign(forcePin: true);
      final future = notifier.submit(authMethod: 'pin', authToken: '123456');
      // Synchronous flip to submitting.
      expect(
        container.read(signControllerProvider(sid)),
        isA<SubmittingSignState>(),
      );
      await future;
      final state = container.read(signControllerProvider(sid));
      expect(state, isA<SuccessSignState>());
      final success = state as SuccessSignState;
      expect(success.signed.eventsWritten, 14);
      expect(success.signed.eventsRejected, 2);
    });

    test('falls into error on AppFailure', () async {
      final repo = _MockSessionRepository();
      when(
        () => repo.signSession(
          sessionId: any(named: 'sessionId'),
          authMethod: any(named: 'authMethod'),
          authToken: any(named: 'authToken'),
        ),
      ).thenThrow(const AppFailure.network(message: 'offline'));
      final container = ProviderContainer(
        overrides: <Override>[
          sessionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(signControllerProvider(sid).notifier);
      await notifier.submit(authMethod: 'pin', authToken: '999999');
      final state = container.read(signControllerProvider(sid));
      expect(state, isA<ErrorSignState>());
      final err = state as ErrorSignState;
      expect(err.failure, isA<NetworkAppFailure>());
    });

    test('malformed response → unexpected failure', () async {
      final repo = _MockSessionRepository();
      when(
        () => repo.signSession(
          sessionId: any(named: 'sessionId'),
          authMethod: any(named: 'authMethod'),
          authToken: any(named: 'authToken'),
        ),
      ).thenAnswer(
        (_) async => <String, Object?>{'status': 'signed'}, // missing fields
      );
      final container = ProviderContainer(
        overrides: <Override>[
          sessionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(signControllerProvider(sid).notifier);
      await notifier.submit(authMethod: 'pin', authToken: '111111');
      final state = container.read(signControllerProvider(sid));
      expect(state, isA<ErrorSignState>());
    });
  });

  group('SignController.fallbackToPin', () {
    test('transitions from promptingBiometric to promptingPin', () {
      final repo = _MockSessionRepository();
      final container = ProviderContainer(
        overrides: <Override>[
          sessionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(signControllerProvider(sid).notifier);
      notifier.beginSign(forcePin: true);
      notifier.fallbackToPin();
      expect(
        container.read(signControllerProvider(sid)),
        isA<PromptingPinSignState>(),
      );
    });
  });

  group('biometricAvailableProvider', () {
    test('returns the compile-time flag', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Wave 1: hard-coded false.
      expect(container.read(biometricAvailableProvider), isFalse);
    });
  });
}
