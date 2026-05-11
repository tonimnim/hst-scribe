import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/app/theme.dart';
import 'package:hst_scribe/core/contract/extracted_event.dart';
import 'package:hst_scribe/features/events/data/events_controller.dart';
import 'package:hst_scribe/features/events/domain/draft_event.dart';
import 'package:hst_scribe/features/events/presentation/event_edit_sheet.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';

/// Single draft event rendered as a clinical card.
///
/// Layout (per PRD F2):
///   * Left edge: confidence band (green / yellow / red). NEVER a raw
///     percentage — AGENTS.md §Pitfalls is strict on this.
///   * Title row: human-friendly summary of the typed fields.
///   * Source utterance disclosure (collapsed by default).
///   * Confirm primary action (single tap), Reject swipe-left, Edit
///     opens [EventEditSheet].
///
/// Interactions delegate to [EventsController] via Riverpod. The card
/// itself is stateless except for the expand/collapse toggle.
class EventCard extends ConsumerStatefulWidget {
  const EventCard({required this.sessionId, required this.draft, super.key});

  final String sessionId;
  final DraftEvent draft;

  @override
  ConsumerState<EventCard> createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<EventCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final draft = widget.draft;
    final bandColor = AppTheme.confidenceColor(
      context,
      confidence: draft.event.confidence,
    );
    final bandLabel = _confidenceLabel(l10n, draft.confidenceBand);
    final summary = _summarizeEvent(draft.event);

    return Dismissible(
      key: ValueKey<String>('event_card_${draft.id}'),
      direction:
          draft.isResolved || draft.isBusy
              ? DismissDirection.none
              : DismissDirection.endToStart,
      background: const SizedBox.shrink(),
      secondaryBackground: _SwipeBackground(label: l10n.eventCardReject),
      confirmDismiss: (DismissDirection _) async {
        // We don't actually remove the card on swipe — the reject status
        // makes it visually distinct in place, and the nurse may still
        // want to scroll back through audit history.
        await _onReject();
        return false;
      },
      child: Semantics(
        label: _semanticLabel(l10n, draft, summary, bandLabel),
        button: true,
        child: Card(
          color:
              draft.isResolved
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surface,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 6,
                    height: 64,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: bandColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                summary.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _ConfidenceChip(color: bandColor, label: bandLabel),
                          ],
                        ),
                        if (summary.subtitle != null) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            summary.subtitle!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _StatusRow(draft: draft),
                        if (_expanded) ...<Widget>[
                          const Divider(height: 16),
                          Text(
                            l10n.eventCardSourceLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // NB: source_utterance is PHI. Rendered on
                          // screen is fine (it's why we have a screen);
                          // it must NEVER reach a log line. The logger
                          // scrubber blocks the key, but extra care here
                          // means we don't pass it through any logger
                          // call by accident.
                          Text(
                            '"${draft.event.sourceUtterance}"',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        if (draft.lastError != null) ...<Widget>[
                          const SizedBox(height: 8),
                          _ErrorChip(message: draft.lastError!),
                        ],
                        if (!draft.isResolved) ...<Widget>[
                          const SizedBox(height: 8),
                          _ActionRow(
                            draft: draft,
                            onConfirm: _onConfirm,
                            onEdit: _onEdit,
                            onReject: _onReject,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    final controller = ref.read(
      eventsControllerProvider(widget.sessionId).notifier,
    );
    await controller.confirm(widget.draft.id);
  }

  Future<void> _onReject() async {
    final controller = ref.read(
      eventsControllerProvider(widget.sessionId).notifier,
    );
    await controller.reject(widget.draft.id);
  }

  Future<void> _onEdit() async {
    final updatedFields = await showModalBottomSheet<Map<String, Object?>>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return EventEditSheet(event: widget.draft.event);
      },
    );
    if (!mounted) return;
    if (updatedFields == null || updatedFields.isEmpty) return;
    final controller = ref.read(
      eventsControllerProvider(widget.sessionId).notifier,
    );
    await controller.edit(widget.draft.id, updatedFields);
  }

  String _semanticLabel(
    AppLocalizations l10n,
    DraftEvent draft,
    _EventSummary summary,
    String bandLabel,
  ) {
    final statusLabel = switch (draft.status) {
      DraftEventStatus.pending => 'pending',
      DraftEventStatus.confirming => 'confirming',
      DraftEventStatus.confirmed => 'confirmed',
      DraftEventStatus.editing => 'editing',
      DraftEventStatus.edited => 'edited',
      DraftEventStatus.rejected => 'rejected',
    };
    return '${summary.title}. ${summary.subtitle ?? ''}. '
        '$bandLabel confidence. $statusLabel.';
  }

  String _confidenceLabel(AppLocalizations l10n, ConfidenceBand band) {
    return switch (band) {
      ConfidenceBand.high => l10n.eventConfidenceHigh,
      ConfidenceBand.medium => l10n.eventConfidenceMedium,
      ConfidenceBand.low => l10n.eventConfidenceLow,
    };
  }
}

class _ConfidenceChip extends StatelessWidget {
  const _ConfidenceChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.draft});

  final DraftEvent draft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (IconData icon, String label, Color color) = switch (draft.status) {
      DraftEventStatus.pending => (
        Icons.hourglass_empty,
        'Pending',
        theme.colorScheme.onSurfaceVariant,
      ),
      DraftEventStatus.confirming => (
        Icons.sync,
        'Confirming…',
        theme.colorScheme.primary,
      ),
      DraftEventStatus.confirmed => (
        Icons.check_circle,
        'Confirmed',
        theme.colorScheme.tertiary,
      ),
      DraftEventStatus.editing => (
        Icons.edit,
        'Saving edits…',
        theme.colorScheme.primary,
      ),
      DraftEventStatus.edited => (
        Icons.check_circle_outline,
        'Edited',
        theme.colorScheme.tertiary,
      ),
      DraftEventStatus.rejected => (
        Icons.cancel,
        'Rejected',
        theme.colorScheme.error,
      ),
    };
    return Row(
      children: <Widget>[
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ErrorChip extends StatelessWidget {
  const _ErrorChip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.warning_amber,
            size: 14,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.draft,
    required this.onConfirm,
    required this.onEdit,
    required this.onReject,
  });

  final DraftEvent draft;
  final Future<void> Function() onConfirm;
  final Future<void> Function() onEdit;
  final Future<void> Function() onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final disabled = draft.isBusy;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: <Widget>[
        FilledButton.icon(
          icon: const Icon(Icons.check, size: 18),
          label: Text(l10n.eventCardConfirm),
          onPressed: disabled ? null : onConfirm,
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(l10n.eventCardEdit),
          onPressed: disabled ? null : onEdit,
        ),
        TextButton.icon(
          icon: const Icon(Icons.close, size: 18),
          label: Text(l10n.eventCardReject),
          onPressed: disabled ? null : onReject,
        ),
      ],
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: theme.colorScheme.errorContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(Icons.close, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal helper — derives a non-PHI* title + subtitle from a typed
/// [ExtractedEvent]. (*Source utterance is PHI; vitals/med routes are not.)
class _EventSummary {
  const _EventSummary({required this.title, this.subtitle});
  final String title;
  final String? subtitle;
}

_EventSummary _summarizeEvent(ExtractedEvent event) {
  return switch (event) {
    ExtractedVitalSign(:final fields) => _EventSummary(
      title: _vitalTitle(fields.vitalType),
      subtitle: '${fields.value} ${fields.unit}',
    ),
    ExtractedMedicationAdministered(:final fields) => _EventSummary(
      title: fields.medicationName,
      subtitle:
          '${fields.doseValue} ${fields.doseUnit.name} · ${fields.route.name}',
    ),
    ExtractedDispo(:final fields) => _EventSummary(
      title: _dispoTitle(fields.dispositionType),
      subtitle:
          fields.dischargeCriteriaMet == true
              ? 'Criteria met'
              : (fields.dischargeCriteriaMet == false
                  ? 'Criteria not met'
                  : null),
    ),
    ExtractedNote() => const _EventSummary(title: 'Note'),
  };
}

String _vitalTitle(VitalType type) {
  return switch (type) {
    VitalType.bloodPressureSystolic => 'BP systolic',
    VitalType.bloodPressureDiastolic => 'BP diastolic',
    VitalType.heartRate => 'Heart rate',
    VitalType.spo2 => 'SpO₂',
    VitalType.respiratoryRate => 'Respiratory rate',
    VitalType.temperatureC => 'Temperature (°C)',
    VitalType.temperatureF => 'Temperature (°F)',
    VitalType.painScore => 'Pain score',
  };
}

String _dispoTitle(DispositionType type) {
  return switch (type) {
    DispositionType.dischargeHome => 'Discharge home',
    DispositionType.transferToHospital => 'Transfer to hospital',
    DispositionType.admitObservation => 'Admit (observation)',
    DispositionType.transferToFloor => 'Transfer to floor',
  };
}
