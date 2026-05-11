import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hst_scribe/core/contract/extracted_event.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/features/events/data/events_controller.dart';
import 'package:hst_scribe/features/events/data/events_repository.dart';
import 'package:hst_scribe/features/events/domain/draft_event.dart';
import 'package:mocktail/mocktail.dart';

class _MockEventsRepository extends Mock implements EventsRepository {}

ExtractedEvent _makeVital({required String id, double confidence = 0.95}) {
  final now = DateTime.utc(2026, 5, 11, 14, 32, 19);
  return ExtractedEvent.vitalSign(
    eventId: id,
    fields: const VitalSignFields(
      vitalType: VitalType.bloodPressureSystolic,
      value: 130,
      unit: 'mmHg',
    ),
    confidence: confidence,
    sourceUtterance: 'BP one thirty over eighty',
    sourceTranscriptIds: const <String>['t1'],
    extractedAt: now,
    eventTime: now,
  );
}

void _stubConfirmOk(_MockEventsRepository repo) {
  when(
    () => repo.confirm(
      sessionId: any(named: 'sessionId'),
      eventId: any(named: 'eventId'),
    ),
  ).thenAnswer((_) async {});
}

void _stubRejectOk(_MockEventsRepository repo) {
  when(
    () => repo.reject(
      sessionId: any(named: 'sessionId'),
      eventId: any(named: 'eventId'),
    ),
  ).thenAnswer((_) async {});
}

void main() {
  const String sid = 'session-1';

  group('EventsController.addExtracted', () {
    test('appends new events at the head', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(eventsControllerProvider(sid).notifier);
      notifier.addExtracted(_makeVital(id: 'e1'));
      notifier.addExtracted(_makeVital(id: 'e2'));
      final list = container.read(eventsControllerProvider(sid));
      expect(list.length, 2);
      // Newest at head.
      expect(list.first.id, 'e2');
      expect(list.last.id, 'e1');
      expect(list.first.status, DraftEventStatus.pending);
    });

    test('dedupes by event_id', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(eventsControllerProvider(sid).notifier);
      notifier.addExtracted(_makeVital(id: 'dup'));
      notifier.addExtracted(_makeVital(id: 'dup'));
      expect(container.read(eventsControllerProvider(sid)).length, 1);
    });
  });

  group('EventsController.confirm', () {
    test('confirms a pending event optimistically and on success', () async {
      final repo = _MockEventsRepository();
      _stubConfirmOk(repo);
      final container = ProviderContainer(
        overrides: <Override>[eventsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(eventsControllerProvider(sid).notifier);
      notifier.addExtracted(_makeVital(id: 'e1'));
      final future = notifier.confirm('e1');
      // Optimistic flip happens synchronously.
      final mid = container.read(eventsControllerProvider(sid)).first;
      expect(mid.status, DraftEventStatus.confirming);
      await future;
      final after = container.read(eventsControllerProvider(sid)).first;
      expect(after.status, DraftEventStatus.confirmed);
      verify(() => repo.confirm(sessionId: sid, eventId: 'e1')).called(1);
    });

    test('reverts to pending on failure with lastError set', () async {
      final repo = _MockEventsRepository();
      when(
        () => repo.confirm(
          sessionId: any(named: 'sessionId'),
          eventId: any(named: 'eventId'),
        ),
      ).thenThrow(const AppFailure.network(message: 'simulated network error'));
      final container = ProviderContainer(
        overrides: <Override>[eventsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(eventsControllerProvider(sid).notifier);
      notifier.addExtracted(_makeVital(id: 'e1'));
      await notifier.confirm('e1');
      final after = container.read(eventsControllerProvider(sid)).first;
      expect(after.status, DraftEventStatus.pending);
      expect(after.lastError, contains('network'));
    });
  });

  group('EventsController.confirmLast / rejectLast', () {
    test(
      'confirmLast targets the most-recently extracted pending event',
      () async {
        final repo = _MockEventsRepository();
        _stubConfirmOk(repo);
        final container = ProviderContainer(
          overrides: <Override>[
            eventsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);
        final notifier = container.read(eventsControllerProvider(sid).notifier);
        notifier.addExtracted(_makeVital(id: 'older'));
        notifier.addExtracted(_makeVital(id: 'newer'));
        await notifier.confirmLast();
        // confirmLast picked the newer one (head of the list).
        verify(() => repo.confirm(sessionId: sid, eventId: 'newer')).called(1);
      },
    );

    test('rejectLast skips already-resolved events', () async {
      final repo = _MockEventsRepository();
      _stubConfirmOk(repo);
      _stubRejectOk(repo);
      final container = ProviderContainer(
        overrides: <Override>[eventsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(eventsControllerProvider(sid).notifier);
      notifier.addExtracted(_makeVital(id: 'a'));
      notifier.addExtracted(_makeVital(id: 'b'));
      await notifier.confirm('b'); // mark b confirmed
      await notifier.rejectLast(); // should fall through to 'a'
      verify(() => repo.reject(sessionId: sid, eventId: 'a')).called(1);
    });

    test('rejectLast is a no-op when nothing is pending', () async {
      final repo = _MockEventsRepository();
      _stubRejectOk(repo);
      final container = ProviderContainer(
        overrides: <Override>[eventsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(eventsControllerProvider(sid).notifier);
      await notifier.rejectLast();
      verifyNever(
        () => repo.reject(
          sessionId: any(named: 'sessionId'),
          eventId: any(named: 'eventId'),
        ),
      );
    });
  });

  group('eventCountsProvider', () {
    test('groups statuses correctly', () async {
      final repo = _MockEventsRepository();
      _stubConfirmOk(repo);
      _stubRejectOk(repo);
      final container = ProviderContainer(
        overrides: <Override>[eventsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(eventsControllerProvider(sid).notifier);
      notifier.addExtracted(_makeVital(id: 'a'));
      notifier.addExtracted(_makeVital(id: 'b'));
      notifier.addExtracted(_makeVital(id: 'c'));
      await notifier.confirm('a');
      await notifier.reject('b');
      final counts = container.read(eventCountsProvider(sid));
      expect(counts.confirmed, 1);
      expect(counts.rejected, 1);
      expect(counts.pending, 1);
      expect(counts.hasPending, isTrue);
    });
  });
}
