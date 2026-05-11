import 'package:flutter_test/flutter_test.dart';
import 'package:hst_scribe/core/errors/app_failure.dart';

void main() {
  group('AppFailure.fromWireError', () {
    test('maps known codes', () {
      final f = AppFailure.fromWireError(
        'session_not_found',
        'no such session',
      );
      expect(f, isA<WireAppFailure>());
      f.map(
        wire: (w) => expect(w.code, WireErrorCode.sessionNotFound),
        network: (_) => fail('expected wire variant'),
        unauthenticated: (_) => fail('expected wire variant'),
        platform: (_) => fail('expected wire variant'),
        unexpected: (_) => fail('expected wire variant'),
      );
    });

    test('unknown code falls back to internal', () {
      final f = AppFailure.fromWireError('???', 'mystery');
      f.map(
        wire: (w) => expect(w.code, WireErrorCode.internal),
        network: (_) => fail('expected wire variant'),
        unauthenticated: (_) => fail('expected wire variant'),
        platform: (_) => fail('expected wire variant'),
        unexpected: (_) => fail('expected wire variant'),
      );
    });
  });
}
