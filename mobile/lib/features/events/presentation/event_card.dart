import 'package:flutter/material.dart';
import 'package:hst_scribe/app/theme.dart';
import 'package:hst_scribe/core/contract/extracted_event.dart';

/// Placeholder event card. The next round of agents will:
///  * Render typed fields per event variant (vital_sign, medication_administered, dispo, note).
///  * Support inline edit interactions per field.
///  * Add confirm / reject swipe gestures.
///  * Add the source-utterance disclosure expansion.
class EventCard extends StatelessWidget {
  const EventCard({required this.event, super.key});

  final ExtractedEvent event;

  @override
  Widget build(BuildContext context) {
    final confidenceColor = AppTheme.confidenceColor(
      context,
      confidence: event.confidence,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Container(
              width: 6,
              height: 48,
              decoration: BoxDecoration(
                color: confidenceColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                event.eventType.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
