import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hst_scribe/core/contract/extracted_event.dart';

part 'draft_event.freezed.dart';

/// UI lifecycle status of a draft event.
///
/// Mirrors the wire `event_ack.status` per CONTRACT.md §2 but also models
/// transient in-flight states (`confirming`, `editing`) the wire doesn't
/// surface — these are local-only and reconcile when the ack lands.
enum DraftEventStatus {
  /// No nurse action taken yet.
  pending,

  /// Confirm POST in flight.
  confirming,

  /// Confirmed by nurse, server ack received.
  confirmed,

  /// PATCH (edit) in flight.
  editing,

  /// Edited and acked.
  edited,

  /// Rejected by nurse, server ack received.
  rejected,
}

/// Single draft event card in the events list.
///
/// Wraps the wire [ExtractedEvent] with UI-only fields ([status], a
/// monotonic [arrivedAt] used for ordering, and an optional [error] that
/// surfaces when a confirm/edit/reject POST fails).
@freezed
class DraftEvent with _$DraftEvent {
  const factory DraftEvent({
    required ExtractedEvent event,
    required DraftEventStatus status,
    required DateTime arrivedAt,

    /// Most recent failure for this card. UI shows a retry affordance
    /// when set. Cleared on the next successful mutation.
    String? lastError,
  }) = _DraftEvent;

  const DraftEvent._();

  String get id => event.eventId;

  ConfidenceBand get confidenceBand => event.confidence.confidenceBand;

  /// True if the card is in a mutation in-flight state — UI uses this
  /// to disable the confirm/edit/reject affordances until the ack lands.
  bool get isBusy =>
      status == DraftEventStatus.confirming ||
      status == DraftEventStatus.editing;

  /// True if the nurse has finished with this card (signed off or rejected).
  bool get isResolved =>
      status == DraftEventStatus.confirmed ||
      status == DraftEventStatus.edited ||
      status == DraftEventStatus.rejected;

  /// True while the card is still draft material (pending nurse decision).
  bool get isPending =>
      status == DraftEventStatus.pending ||
      status == DraftEventStatus.confirming ||
      status == DraftEventStatus.editing;
}
