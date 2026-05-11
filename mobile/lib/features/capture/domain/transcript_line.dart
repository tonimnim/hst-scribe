import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hst_scribe/core/contract/wss_messages.dart';

part 'transcript_line.freezed.dart';

/// One line in the transcript pane.
///
/// Mirrors either a `transcript_partial` or `transcript_final` WSS payload
/// (CONTRACT.md §2). Partial lines render in italic; final lines render in
/// regular weight. A new final-line replaces the most recent partial.
@freezed
class TranscriptLine with _$TranscriptLine {
  const factory TranscriptLine({
    required String text,
    required SpeakerRole speaker,

    /// Server `transcript_id`. Null for partials (partials have no id on
    /// the wire). Used to dedupe and to swap a final in place of its
    /// preceding partial.
    String? transcriptId,

    required bool isFinal,
    required DateTime receivedAt,
  }) = _TranscriptLine;
}
