import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hst_scribe/core/audio/audio_capture.dart';

void main() {
  group('PcmFormat.clinical', () {
    test('matches contract: 16kHz mono PCM16 @ 250ms', () {
      const fmt = PcmFormat.clinical;
      expect(fmt.sampleRate, 16000);
      expect(fmt.channels, 1);
      expect(fmt.bytesPerSample, 2);
      expect(fmt.chunkMs, 250);
      // 16000 samples/s * 0.25s * 1 ch * 2 bytes = 8000 bytes/chunk
      expect(fmt.bytesPerChunk, 8000);
    });
  });

  group('PcmChunkAssembler', () {
    test('emits nothing until the buffer reaches bytesPerChunk', () {
      final assembler = PcmChunkAssembler(bytesPerChunk: 8000);
      // Feed 4kB — half a chunk.
      final out = assembler.add(Uint8List(4000));
      expect(out, isEmpty);
      expect(assembler.pendingBytes, 4000);
    });

    test('emits one chunk when exactly bytesPerChunk bytes arrive', () {
      final assembler = PcmChunkAssembler(bytesPerChunk: 8000);
      final out = assembler.add(Uint8List(8000));
      expect(out.length, 1);
      expect(out.first.length, 8000);
      expect(assembler.pendingBytes, 0);
    });

    test('emits multiple chunks when a large buffer arrives', () {
      final assembler = PcmChunkAssembler(bytesPerChunk: 8000);
      // 2.5 chunks worth in one shot.
      final out = assembler.add(Uint8List(20000));
      expect(out.length, 2);
      expect(out.every((Uint8List c) => c.length == 8000), isTrue);
      expect(assembler.pendingBytes, 4000);
    });

    test('preserves byte ordering across chunk boundaries', () {
      final assembler = PcmChunkAssembler(bytesPerChunk: 4);
      // Feed two 3-byte buffers (= 6 bytes total → 1 chunk of 4, 2 left).
      final first = assembler.add(Uint8List.fromList(<int>[1, 2, 3]));
      expect(first, isEmpty);
      final second = assembler.add(Uint8List.fromList(<int>[4, 5, 6]));
      expect(second.length, 1);
      expect(second.first, Uint8List.fromList(<int>[1, 2, 3, 4]));
      expect(assembler.pendingBytes, 2);
      // Drain the remainder with two more bytes.
      final third = assembler.add(Uint8List.fromList(<int>[7, 8]));
      expect(third.length, 1);
      expect(third.first, Uint8List.fromList(<int>[5, 6, 7, 8]));
      expect(assembler.pendingBytes, 0);
    });

    test('typical mic plugin cadence: re-frames 1024-byte buffers to 8000', () {
      // Simulates a plugin that emits ~1024 bytes per platform callback.
      // After ~8 callbacks we expect exactly 1 chunk; then keeps going.
      final assembler = PcmChunkAssembler(bytesPerChunk: 8000);
      final emitted = <Uint8List>[];
      for (var i = 0; i < 16; i++) {
        emitted.addAll(assembler.add(Uint8List(1024)));
      }
      // 16 * 1024 = 16384 bytes -> 2 full chunks of 8000, 384 left.
      expect(emitted.length, 2);
      expect(emitted.every((Uint8List c) => c.length == 8000), isTrue);
      expect(assembler.pendingBytes, 16384 - 16000);
    });

    test('reset clears pending bytes', () {
      final assembler = PcmChunkAssembler(bytesPerChunk: 8000);
      assembler.add(Uint8List(4000));
      expect(assembler.pendingBytes, 4000);
      assembler.reset();
      expect(assembler.pendingBytes, 0);
    });

    test('empty input is a no-op', () {
      final assembler = PcmChunkAssembler(bytesPerChunk: 8000);
      final out = assembler.add(Uint8List(0));
      expect(out, isEmpty);
      expect(assembler.pendingBytes, 0);
    });
  });

  group('FakeAudioCapture', () {
    test('start/stop lifecycle', () async {
      final cap = FakeAudioCapture();
      expect(cap.isCapturing, isFalse);
      await cap.start();
      expect(cap.isCapturing, isTrue);
      expect(cap.isPaused, isFalse);
      await cap.pause();
      expect(cap.isPaused, isTrue);
      await cap.resume();
      expect(cap.isPaused, isFalse);
      await cap.stop();
      expect(cap.isCapturing, isFalse);
      await cap.dispose();
    });

    test('emits clinical-format chunks via capture()', () async {
      final cap = FakeAudioCapture();
      await cap.start();
      // First subscriber gets emissions through the broadcast stream.
      final first = await cap.capture().first.timeout(
        const Duration(milliseconds: 600),
      );
      expect(first.length, PcmFormat.clinical.bytesPerChunk);
      await cap.dispose();
    });
  });
}
