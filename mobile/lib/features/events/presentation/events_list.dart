import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/features/events/data/events_controller.dart';
import 'package:hst_scribe/features/events/domain/draft_event.dart';
import 'package:hst_scribe/features/events/presentation/event_card.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';

/// Scrollable list of [EventCard]s for the active session.
///
/// Behaviour:
///   * Newest events at index 0 (head of the list).
///   * `ListView.builder` — never `.map().toList()` (AGENTS §Performance).
///   * Auto-scroll-to-top only when the user is already at the top — we
///     never yank the viewport away from a card the nurse is examining.
class EventsList extends ConsumerStatefulWidget {
  const EventsList({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<EventsList> createState() => _EventsListState();
}

class _EventsListState extends ConsumerState<EventsList> {
  final ScrollController _controller = ScrollController();
  int _previousCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final events = ref.watch(eventsControllerProvider(widget.sessionId));

    // Auto-stick-to-top: only when the user was at offset 0 before the
    // insert. If they've scrolled away, leave the viewport alone.
    if (events.length > _previousCount && _controller.hasClients) {
      final atTop = _controller.offset <= 8;
      if (atTop) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (!_controller.hasClients) return;
          _controller.animateTo(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        });
      }
    }
    _previousCount = events.length;

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.event_note_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.eventListEmpty,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _controller,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final DraftEvent draft = events[index];
        return EventCard(sessionId: widget.sessionId, draft: draft);
      },
    );
  }
}
