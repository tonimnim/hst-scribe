import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hst_scribe/core/contract/wss_messages.dart';
import 'package:hst_scribe/features/capture/data/capture_controller.dart';
import 'package:hst_scribe/features/capture/domain/transcript_line.dart';
import 'package:hst_scribe/l10n/generated/app_localizations.dart';

/// Scrolling transcript pane.
///
/// Visual contract (per PRD F2):
///   * `transcript_partial` → italic, muted color
///   * `transcript_final`   → regular weight, full opacity
/// Speaker tags appear as a small chip prefix on speaker change.
///
/// Auto-scrolls to the bottom only if the user is already pinned to the
/// bottom — we never yank a nurse out of historical context.
class TranscriptPane extends ConsumerStatefulWidget {
  const TranscriptPane({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<TranscriptPane> createState() => _TranscriptPaneState();
}

class _TranscriptPaneState extends ConsumerState<TranscriptPane> {
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
    final lines = ref.watch(transcriptControllerProvider(widget.sessionId));

    if (lines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.captureTranscriptPlaceholder,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (lines.length > _previousCount && _controller.hasClients) {
      final atBottom =
          _controller.offset >= _controller.position.maxScrollExtent - 8;
      if (atBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_controller.hasClients) return;
          _controller.animateTo(
            _controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        });
      }
    }
    _previousCount = lines.length;

    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: lines.length,
      itemBuilder: (BuildContext context, int index) {
        final TranscriptLine line = lines[index];
        final TranscriptLine? prev = index == 0 ? null : lines[index - 1];
        final bool speakerChanged =
            prev == null || prev.speaker != line.speaker;
        return _TranscriptLineView(line: line, showSpeaker: speakerChanged);
      },
    );
  }
}

class _TranscriptLineView extends StatelessWidget {
  const _TranscriptLineView({required this.line, required this.showSpeaker});

  final TranscriptLine line;
  final bool showSpeaker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyLarge?.copyWith(
      fontStyle: line.isFinal ? FontStyle.normal : FontStyle.italic,
      color:
          line.isFinal
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurfaceVariant,
      fontWeight: line.isFinal ? FontWeight.w500 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (showSpeaker)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _SpeakerChip(speaker: line.speaker),
            ),
          // PHI safety: the text body itself is the transcript — rendered
          // on screen is the whole point of this widget. Logging this
          // string is forbidden; we do not pass it to any logger call.
          Text(line.text, style: style),
        ],
      ),
    );
  }
}

class _SpeakerChip extends StatelessWidget {
  const _SpeakerChip({required this.speaker});

  final SpeakerRole speaker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = switch (speaker) {
      SpeakerRole.nurse => 'Nurse',
      SpeakerRole.patient => 'Patient',
      SpeakerRole.surgeon => 'Surgeon',
      SpeakerRole.anesthesia => 'Anesthesia',
      SpeakerRole.unknown => 'Speaker',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
