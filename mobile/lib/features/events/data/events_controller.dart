import 'package:hst_scribe/core/contract/extracted_event.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';
import 'package:hst_scribe/core/obs/logger.dart';
import 'package:hst_scribe/features/events/data/events_repository.dart';
import 'package:hst_scribe/features/events/domain/draft_event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'events_controller.g.dart';

/// Holds the list of draft events for a single active session.
///
/// Wired from [CaptureController]: every `event_extracted` WSS frame is
/// forwarded here via [addExtracted]. Voice commands `confirm_last` /
/// `strike_last` are dispatched to [confirmLast] / [rejectLast].
///
/// Optimistic UI:
///   * `confirm` flips status to [DraftEventStatus.confirming] immediately,
///      POST in the background; on success → [DraftEventStatus.confirmed].
///      On failure → revert to [DraftEventStatus.pending] + set lastError.
///   * Same pattern for reject and edit.
///
/// Newest events are at the head of the list (index 0). Source of truth
/// for the "events confirmed / rejected / drafts pending" counts that
/// the sign screen reads.
@Riverpod(keepAlive: true)
class EventsController extends _$EventsController {
  static const AppLogger _log = AppLogger('EventsController');

  @override
  List<DraftEvent> build(String sessionId) {
    _log.info(
      'events controller initialized',
      data: <String, Object?>{'session_id': sessionId},
    );
    return const <DraftEvent>[];
  }

  /// Append an extracted event from the WSS stream. New events go to the
  /// head of the list (newest first).
  ///
  /// Dedupes by `event_id` — replaying the same WSS frame (e.g. on a
  /// reconnect that re-emits buffered server events) does NOT create a
  /// duplicate card.
  void addExtracted(ExtractedEvent extracted) {
    final alreadyPresent = state.any(
      (DraftEvent e) => e.id == extracted.eventId,
    );
    if (alreadyPresent) {
      _log.info(
        'event_extracted dedup — already in list',
        data: <String, Object?>{'event_id': extracted.eventId},
      );
      return;
    }
    final draft = DraftEvent(
      event: extracted,
      status: DraftEventStatus.pending,
      arrivedAt: DateTime.now().toUtc(),
    );
    state = <DraftEvent>[draft, ...state];
    _log.info(
      'event_extracted appended',
      data: <String, Object?>{
        'event_id': extracted.eventId,
        'event_type': extracted.eventType.name,
      },
    );
  }

  /// Voice-command path: confirm the most recently extracted PENDING event.
  /// No-op if the list has nothing to confirm.
  Future<void> confirmLast() async {
    final last = _firstPending();
    if (last == null) {
      _log.info('confirmLast: no pending event');
      return;
    }
    await confirm(last.id);
  }

  /// Voice-command path: reject (strike) the most recently extracted
  /// PENDING event.
  Future<void> rejectLast() async {
    final last = _firstPending();
    if (last == null) {
      _log.info('rejectLast: no pending event');
      return;
    }
    await reject(last.id);
  }

  Future<void> confirm(String eventId) async {
    _mutate(eventId, (DraftEvent e) {
      if (e.isBusy || e.isResolved) return e;
      return e.copyWith(status: DraftEventStatus.confirming, lastError: null);
    });
    final repo = ref.read(eventsRepositoryProvider);
    try {
      await repo.confirm(sessionId: sessionId, eventId: eventId);
      _mutate(
        eventId,
        (DraftEvent e) => e.copyWith(status: DraftEventStatus.confirmed),
      );
    } on AppFailure catch (failure, st) {
      _log.warn(
        'confirm failed',
        data: <String, Object?>{'event_id': eventId},
        error: failure,
        stackTrace: st,
      );
      _mutate(
        eventId,
        (DraftEvent e) => e.copyWith(
          status: DraftEventStatus.pending,
          lastError: _failureMessage(failure),
        ),
      );
    }
  }

  Future<void> reject(String eventId) async {
    _mutate(eventId, (DraftEvent e) {
      if (e.isBusy || e.isResolved) return e;
      return e.copyWith(status: DraftEventStatus.confirming, lastError: null);
    });
    final repo = ref.read(eventsRepositoryProvider);
    try {
      await repo.reject(sessionId: sessionId, eventId: eventId);
      _mutate(
        eventId,
        (DraftEvent e) => e.copyWith(status: DraftEventStatus.rejected),
      );
    } on AppFailure catch (failure, st) {
      _log.warn(
        'reject failed',
        data: <String, Object?>{'event_id': eventId},
        error: failure,
        stackTrace: st,
      );
      _mutate(
        eventId,
        (DraftEvent e) => e.copyWith(
          status: DraftEventStatus.pending,
          lastError: _failureMessage(failure),
        ),
      );
    }
  }

  /// Edit a draft event with a partial field map.
  ///
  /// [fields] is whatever subset of the event's typed `fields` block the
  /// nurse changed. The repository PATCHes the server; on ack we mark the
  /// card edited but keep the locally-known `extracted_event` in place
  /// (the wire ack returns the updated fields but parsing them back into
  /// a typed [ExtractedEvent] variant is left to a Phase B refactor).
  Future<void> edit(String eventId, Map<String, Object?> fields) async {
    _mutate(eventId, (DraftEvent e) {
      if (e.isBusy || e.isResolved) return e;
      return e.copyWith(status: DraftEventStatus.editing, lastError: null);
    });
    final repo = ref.read(eventsRepositoryProvider);
    try {
      await repo.edit(sessionId: sessionId, eventId: eventId, fields: fields);
      _mutate(
        eventId,
        (DraftEvent e) => e.copyWith(status: DraftEventStatus.edited),
      );
    } on AppFailure catch (failure, st) {
      _log.warn(
        'edit failed',
        data: <String, Object?>{'event_id': eventId},
        error: failure,
        stackTrace: st,
      );
      _mutate(
        eventId,
        (DraftEvent e) => e.copyWith(
          status: DraftEventStatus.pending,
          lastError: _failureMessage(failure),
        ),
      );
    }
  }

  // ----- helpers -----

  DraftEvent? _firstPending() {
    for (final DraftEvent e in state) {
      if (e.status == DraftEventStatus.pending) return e;
    }
    return null;
  }

  void _mutate(String eventId, DraftEvent Function(DraftEvent current) update) {
    final idx = state.indexWhere((DraftEvent e) => e.id == eventId);
    if (idx == -1) return;
    final next = List<DraftEvent>.of(state);
    next[idx] = update(state[idx]);
    state = next;
  }

  static String _failureMessage(AppFailure failure) {
    return switch (failure) {
      WireAppFailure(:final message) => message,
      NetworkAppFailure(:final message) => message,
      UnauthenticatedAppFailure(:final message) => message,
      PlatformAppFailure(:final message) => message,
      UnexpectedAppFailure(:final message) => message,
    };
  }
}

/// Lightweight derived counts used by the sign screen summary.
class EventCounts {
  const EventCounts({
    required this.confirmed,
    required this.rejected,
    required this.pending,
    required this.edited,
  });

  final int confirmed;
  final int rejected;
  final int pending;
  final int edited;

  int get total => confirmed + rejected + pending + edited;
  bool get hasPending => pending > 0;
}

@riverpod
EventCounts eventCounts(EventCountsRef ref, String sessionId) {
  final events = ref.watch(eventsControllerProvider(sessionId));
  var confirmed = 0;
  var rejected = 0;
  var pending = 0;
  var edited = 0;
  for (final DraftEvent e in events) {
    switch (e.status) {
      case DraftEventStatus.confirmed:
        confirmed++;
      case DraftEventStatus.rejected:
        rejected++;
      case DraftEventStatus.edited:
        edited++;
      case DraftEventStatus.pending:
      case DraftEventStatus.confirming:
      case DraftEventStatus.editing:
        pending++;
    }
  }
  return EventCounts(
    confirmed: confirmed,
    rejected: rejected,
    pending: pending,
    edited: edited,
  );
}
