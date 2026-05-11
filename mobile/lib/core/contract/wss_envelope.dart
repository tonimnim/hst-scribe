import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hst_scribe/core/contract/extracted_event.dart';
import 'package:hst_scribe/core/contract/wire_error.dart';
import 'package:hst_scribe/core/contract/wss_messages.dart';

part 'wss_envelope.freezed.dart';

/// Envelope wrapper for every WSS message (both directions) per CONTRACT.md §2:
/// ```json
/// { "type": "...", "session_id": "...", "seq": 42, "ts": "...", "payload": {...} }
/// ```
@freezed
class WssEnvelope with _$WssEnvelope {
  const factory WssEnvelope({
    required WssMessageType type,
    required String sessionId,
    required int seq,
    required DateTime ts,
    required WssPayload payload,
  }) = _WssEnvelope;

  /// Parse a raw decoded JSON map into an envelope.
  ///
  /// Forward-compatible: unknown `type` produces [UnknownWssPayload], not
  /// a [FormatException], so the server can roll out additive message types
  /// without breaking older clients (per CONTRACT.md §6 Versioning Policy).
  ///
  /// Throws [FormatException] only for structural failures (missing required
  /// envelope fields, malformed RFC3339 timestamp).
  factory WssEnvelope.fromJson(Map<String, Object?> json) {
    final rawType = json['type'] as String?;
    if (rawType == null) {
      throw const FormatException('WSS envelope missing required `type`');
    }
    final sessionId = json['session_id'] as String?;
    if (sessionId == null) {
      throw const FormatException('WSS envelope missing required `session_id`');
    }
    final seq = json['seq'];
    if (seq is! int) {
      throw const FormatException('WSS envelope `seq` must be int');
    }
    final tsRaw = json['ts'] as String?;
    if (tsRaw == null) {
      throw const FormatException('WSS envelope missing required `ts`');
    }
    final ts = DateTime.parse(tsRaw);

    final rawPayload =
        (json['payload'] as Map<Object?, Object?>?)?.cast<String, Object?>() ??
        const <String, Object?>{};
    final messageType = WssMessageTypeX.fromWire(rawType);
    final payload = _parsePayload(rawType, messageType, rawPayload);

    return WssEnvelope(
      type: messageType ?? _coerceUnknownType(rawType),
      sessionId: sessionId,
      seq: seq,
      ts: ts.toUtc(),
      payload: payload,
    );
  }

  const WssEnvelope._();

  /// Serialize back to wire JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'type': type.wireValue,
    'session_id': sessionId,
    'seq': seq,
    'ts': ts.toUtc().toIso8601String(),
    'payload': _serializePayload(payload),
  };
}

/// Build a payload variant from the raw decoded map.
WssPayload _parsePayload(
  String rawType,
  WssMessageType? type,
  Map<String, Object?> raw,
) {
  if (type == null) return WssPayload.unknown(rawType, raw);
  switch (type) {
    case WssMessageType.audioChunk:
      return WssPayload.audioChunk(AudioChunkPayload.fromJson(raw));
    case WssMessageType.voiceCommand:
      return WssPayload.voiceCommand(VoiceCommandPayload.fromJson(raw));
    case WssMessageType.sessionPause:
      return const WssPayload.sessionPause();
    case WssMessageType.sessionResume:
      return const WssPayload.sessionResume();
    case WssMessageType.sessionEnd:
      return const WssPayload.sessionEnd();
    case WssMessageType.ping:
      return const WssPayload.ping();
    case WssMessageType.sessionStarted:
      return WssPayload.sessionStarted(SessionStartedPayload.fromJson(raw));
    case WssMessageType.transcriptPartial:
      return WssPayload.transcriptPartial(
        TranscriptPartialPayload.fromJson(raw),
      );
    case WssMessageType.transcriptFinal:
      return WssPayload.transcriptFinal(TranscriptFinalPayload.fromJson(raw));
    case WssMessageType.eventExtracted:
      return WssPayload.eventExtracted(EventExtractedPayload.fromJson(raw));
    case WssMessageType.eventAck:
      return WssPayload.eventAck(EventAckPayload.fromJson(raw));
    case WssMessageType.sessionEnded:
      return WssPayload.sessionEnded(SessionEndedPayload.fromJson(raw));
    case WssMessageType.error:
      return WssPayload.error(WireError.fromJson(raw));
    case WssMessageType.pong:
      return const WssPayload.pong();
  }
}

/// Fallback: if we got an unknown type string we still want to round-trip
/// the envelope. We can't synthesize a real enum value, so callers receive
/// `WssPayload.unknown` and an arbitrary `type` (we reuse `pong` slot only
/// as a parking value — UI never sees this; controllers always switch on
/// the payload variant, not the enum).
///
/// Note: in practice we never hit this path because `_parsePayload` already
/// returned [UnknownWssPayload]; we just need *some* enum value to satisfy
/// the typed envelope field.
WssMessageType _coerceUnknownType(String _) => WssMessageType.pong;

/// Serialize a payload variant back to its on-wire body.
Map<String, Object?> _serializePayload(WssPayload payload) {
  return switch (payload) {
    AudioChunkWssPayload(:final payload) => payload.toJson(),
    VoiceCommandWssPayload(:final payload) => payload.toJson(),
    SessionStartedWssPayload(:final payload) => payload.toJson(),
    TranscriptPartialWssPayload(:final payload) => payload.toJson(),
    TranscriptFinalWssPayload(:final payload) => payload.toJson(),
    EventExtractedWssPayload(:final payload) => payload.toJson(),
    EventAckWssPayload(:final payload) => payload.toJson(),
    SessionEndedWssPayload(:final payload) => payload.toJson(),
    ErrorWssPayload(:final payload) => payload.toJson(),
    SessionPauseWssPayload() => const <String, Object?>{},
    SessionResumeWssPayload() => const <String, Object?>{},
    SessionEndWssPayload() => const <String, Object?>{},
    PingWssPayload() => const <String, Object?>{},
    PongWssPayload() => const <String, Object?>{},
    UnknownWssPayload(:final raw) => raw,
  };
}

/// Helpers for the (rare) need to render a non-PHI summary of an envelope
/// into logs. Returns a tiny, log-safe map.
extension WssEnvelopeLogX on WssEnvelope {
  Map<String, Object?> toLogSummary() => <String, Object?>{
    'type': type.wireValue,
    'session_id': sessionId,
    'seq': seq,
    'ts': ts.toIso8601String(),
    // payload intentionally omitted (may contain PHI). Use the
    // `AppLogger.maskPhi` helper if you must include a field-by-field
    // summary.
  };

  /// True if this server-frame represents a high-confidence event card
  /// the UI should auto-style green.
  bool get isHighConfidenceEvent {
    final p = payload;
    if (p is EventExtractedWssPayload) {
      return p.payload.event.confidence >= 0.9;
    }
    return false;
  }

  /// Convenience accessor for the embedded extracted event, if any.
  ExtractedEvent? get extractedEvent {
    final p = payload;
    if (p is EventExtractedWssPayload) return p.payload.event;
    return null;
  }
}
