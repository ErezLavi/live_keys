import 'package:flutter_test/flutter_test.dart';
import 'package:piano/piano.dart';
import 'package:piano_app/common/chord_detector.dart';

NotePosition n(
  Note note,
  int octave, [
  Accidental accidental = Accidental.None,
]) {
  return NotePosition(
    note: note,
    octave: octave,
    accidental: accidental,
  );
}

void main() {
  group('ChordDetector – valid chords', () {
    test('detects C major triad', () {
      final chord = ChordDetector.detect({
        n(Note.C, 4),
        n(Note.E, 4),
        n(Note.G, 4),
      });

      expect(chord, isNotNull);
      expect(chord!.name, 'C');
    });

    test('detects Cmaj7', () {
      final chord = ChordDetector.detect({
        n(Note.C, 4),
        n(Note.E, 4),
        n(Note.G, 4),
        n(Note.B, 4),
      });

      expect(chord, isNotNull);
      expect(chord!.name, 'Cmaj7');
    });

    test('uses slash for inversion bass', () {
      final chord = ChordDetector.detect({
        n(Note.E, 4),
        n(Note.G, 4),
        n(Note.C, 5),
      });

      expect(chord, isNotNull);
      expect(chord!.name, 'C/E');
    });
  });

  group('ChordDetector – invalid pitch sets', () {
    test('returns null for cluster without fifth (G#–B–C)', () {
      final chord = ChordDetector.detect({
        n(Note.G, 3, Accidental.Sharp),
        n(Note.B, 3),
        n(Note.C, 4),
      });

      expect(chord, isNull);
    });

    test('returns null when missing third', () {
      final chord = ChordDetector.detect({
        n(Note.C, 4),
        n(Note.G, 4),
        n(Note.B, 4),
      });

      expect(chord, isNull);
    });

    test('detects Cmaj7 without fifth (C-E-B)', () {
      final chord = ChordDetector.detect({
        n(Note.C, 4),
        n(Note.E, 4),
        n(Note.B, 4),
      });

      expect(chord, isNotNull);
      expect(chord!.name, 'Cmaj7');
    });
  });

  group('ChordDetector – edge cases', () {
    test('ignores duplicate pitch classes across octaves', () {
      final chord = ChordDetector.detect({
        n(Note.C, 3),
        n(Note.E, 4),
        n(Note.G, 5),
        n(Note.C, 6), // duplicate C
      });

      expect(chord, isNotNull);
      expect(chord!.name, 'C');
    });

    test('detects chord with wide voicing', () {
      final chord = ChordDetector.detect({
        n(Note.C, 2),
        n(Note.E, 5),
        n(Note.G, 7),
      });

      expect(chord, isNotNull);
      expect(chord!.name, 'C');
    });

    test('returns null for rootless voicing (E–G–B)', () {
      final chord = ChordDetector.detect({
        n(Note.E, 4),
        n(Note.G, 4),
        n(Note.B, 4),
      });

      expect(chord, isNull);
    });

    test('returns null for power chord (C–G)', () {
      final chord = ChordDetector.detect({
        n(Note.C, 4),
        n(Note.G, 4),
      });

      expect(chord, isNull);
    });

    test('detects chord with extra non-harmonic tone', () {
      final chord = ChordDetector.detect({
        n(Note.C, 4),
        n(Note.E, 4),
        n(Note.G, 4),
        n(Note.D, 4), // passing tone
      });

      expect(chord, isNotNull);
      expect(chord!.name, 'C');
    });

    test('detects slash chord with non-root bass', () {
      final chord = ChordDetector.detect({
        n(Note.D, 3), // bass
        n(Note.C, 4),
        n(Note.E, 4),
        n(Note.G, 4),
      });

      expect(chord, isNotNull);
      expect(chord!.name, 'C/D');
    });
  });
}
