import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Severity levels we surface. Keep this small — every level becomes
/// a switch arm and a Sentry breadcrumb level.
enum LogLevel { trace, debug, info, warn, error }

/// PHI-aware structured logger.
///
/// **Why this exists:** clinical-grade PHI safety. The entire app calls
/// [AppLogger] — never `print`, `debugPrint`, or `dart:developer.log` directly.
/// The logger scrubs known-PHI keys (and any nested map containing them)
/// before emission, regardless of caller intent.
///
/// **Adding a new patient field?** Add its JSON key to [_phiKeys]
/// in the same commit, or you've leaked PHI. The CI grep guard checks this.
///
/// Output destinations:
///  * In `kDebugMode`: `dart:developer.log` (visible in IDE / DevTools).
///  * In release: same channel, but also intended to feed Sentry breadcrumbs
///    (wire in `core/obs/sentry.dart` when Sentry is initialized).
class AppLogger {
  const AppLogger(this.tag);

  final String tag;

  /// Lowercase JSON keys whose VALUES are treated as PHI and replaced
  /// with `<scrubbed>` before logging. Match is exact (after lowercasing).
  ///
  /// Keep this in sync with the wire contract. Anything the LLM/ASR
  /// produces that carries patient-derived text goes here.
  static const Set<String> _phiKeys = <String>{
    // Transcripts and source utterances (ASR / extractor)
    'transcript',
    'text',
    'note_text',
    'notes',
    'source_utterance',
    'audio_b64',

    // Identifiers
    'patient_name',
    'full_name',
    'first_name',
    'last_name',
    'mrn',
    'medical_record_number',
    'dob',
    'date_of_birth',
    'ssn',
    'phone',
    'phone_number',
    'address',
    'email',

    // Clinical values that read as PHI in narrative form
    'allergies',
    'comorbidities',
    'current_medications',
    'medications',
    'indication',
  };

  /// Returns a shallow copy of [data] with PHI values masked recursively.
  /// Lists are walked element by element. Non-Map/List leaf values are
  /// retained as-is (because keys, not values, drive the rule).
  ///
  /// Idempotent and safe to call on `null`.
  static Map<String, Object?> maskPhi(Map<String, Object?>? data) {
    if (data == null || data.isEmpty) return const <String, Object?>{};
    final out = <String, Object?>{};
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      if (_phiKeys.contains(key.toLowerCase())) {
        out[key] = '<scrubbed>';
      } else if (value is Map<String, Object?>) {
        out[key] = maskPhi(value);
      } else if (value is Map) {
        out[key] = maskPhi(
          value.map<String, Object?>(
            (Object? k, Object? v) =>
                MapEntry<String, Object?>(k.toString(), v),
          ),
        );
      } else if (value is List) {
        out[key] = _maskList(value);
      } else {
        out[key] = value;
      }
    }
    return out;
  }

  static List<Object?> _maskList(List<Object?> list) {
    return <Object?>[
      for (final item in list)
        if (item is Map<String, Object?>)
          maskPhi(item)
        else if (item is Map)
          maskPhi(
            item.map<String, Object?>(
              (Object? k, Object? v) =>
                  MapEntry<String, Object?>(k.toString(), v),
            ),
          )
        else if (item is List)
          _maskList(item)
        else
          item,
    ];
  }

  void trace(String message, {Map<String, Object?>? data}) =>
      _emit(LogLevel.trace, message, data: data);
  void debug(String message, {Map<String, Object?>? data}) =>
      _emit(LogLevel.debug, message, data: data);
  void info(String message, {Map<String, Object?>? data}) =>
      _emit(LogLevel.info, message, data: data);
  void warn(
    String message, {
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) => _emit(
    LogLevel.warn,
    message,
    data: data,
    error: error,
    stackTrace: stackTrace,
  );
  void error(
    String message, {
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) => _emit(
    LogLevel.error,
    message,
    data: data,
    error: error,
    stackTrace: stackTrace,
  );

  void _emit(
    LogLevel level,
    String message, {
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // In release we still log INFO/WARN/ERROR but drop TRACE/DEBUG.
    if (!kDebugMode && (level == LogLevel.trace || level == LogLevel.debug)) {
      return;
    }

    final scrubbed = maskPhi(data);
    final payload = scrubbed.isEmpty ? '' : ' ${_renderMap(scrubbed)}';

    developer.log(
      '$message$payload',
      name: tag,
      level: _developerLevel(level),
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
  }

  int _developerLevel(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return 300;
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warn:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }

  String _renderMap(Map<String, Object?> map) {
    final buf = StringBuffer('{');
    var first = true;
    for (final entry in map.entries) {
      if (!first) buf.write(', ');
      first = false;
      buf
        ..write(entry.key)
        ..write('=')
        ..write(entry.value);
    }
    buf.write('}');
    return buf.toString();
  }
}

/// Run [body] inside a Zone whose `print` is silenced. Useful for tests
/// or third-party plugins that misbehave. Application code must never
/// call `print` — the analyzer enforces it.
Future<T> runWithoutPrints<T>(Future<T> Function() body) {
  return runZoned<Future<T>>(
    body,
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        // Intentionally swallow. We do NOT route this to AppLogger to
        // avoid laundering PHI through `print`.
      },
    ),
  );
}
