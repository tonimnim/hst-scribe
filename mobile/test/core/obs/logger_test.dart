import 'package:flutter_test/flutter_test.dart';
import 'package:hst_scribe/core/obs/logger.dart';

void main() {
  group('AppLogger.maskPhi', () {
    test('returns empty map for null input', () {
      expect(AppLogger.maskPhi(null), isEmpty);
    });

    test('scrubs known PHI keys at top level', () {
      final input = <String, Object?>{
        'transcript': 'BP one thirty over eighty',
        'patient_name': 'Jane Doe',
        'mrn': '1234567',
        'session_id': '01931d80-aaaa-bbbb-cccc-dddddddddddd',
        'seq': 42,
      };
      final out = AppLogger.maskPhi(input);
      expect(out['transcript'], '<scrubbed>');
      expect(out['patient_name'], '<scrubbed>');
      expect(out['mrn'], '<scrubbed>');
      // Non-PHI keys pass through.
      expect(out['session_id'], '01931d80-aaaa-bbbb-cccc-dddddddddddd');
      expect(out['seq'], 42);
    });

    test('scrubs nested maps recursively', () {
      final input = <String, Object?>{
        'event': <String, Object?>{
          'event_id': 'evt-1',
          'source_utterance': 'BP one thirty over eighty',
          'fields': <String, Object?>{
            'value': 130,
            'note_text': 'mild itching',
          },
        },
      };
      final out = AppLogger.maskPhi(input);
      final event = out['event']! as Map<String, Object?>;
      expect(event['event_id'], 'evt-1');
      expect(event['source_utterance'], '<scrubbed>');
      final fields = event['fields']! as Map<String, Object?>;
      expect(fields['value'], 130);
      expect(fields['note_text'], '<scrubbed>');
    });

    test('scrubs lists element-wise', () {
      final input = <String, Object?>{
        'allergies': <Map<String, Object?>>[
          <String, Object?>{'name': 'penicillin', 'severity': 'severe'},
        ],
        'medications': <Map<String, Object?>>[
          <String, Object?>{'rxnorm_code': '26225', 'name': 'Ondansetron'},
        ],
      };
      final out = AppLogger.maskPhi(input);
      // The `allergies` and `medications` keys themselves are PHI per our list.
      expect(out['allergies'], '<scrubbed>');
      expect(out['medications'], '<scrubbed>');
    });
  });
}
