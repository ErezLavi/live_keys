import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piano/piano.dart';
import 'package:piano_app/common/constants.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';
import 'chord_detector.dart';

class PianoPageController extends ChangeNotifier {
  PianoPageController();

  static final NoteRange fullRange = NoteRange(
    from: NotePosition(note: Note.A, octave: 0),
    to: NotePosition(note: Note.C, octave: 8),
  );

  final FocusNode focusNode = FocusNode();
  final Set<NotePosition> _pressedNotes = {};
  final Map<LogicalKeyboardKey, NotePosition> _activeKeyNotes = {};

  int _keyboardOctave = 4;
  String currentChord = '';

  List<NotePosition> get pressedNotes => _pressedNotes.toList();
  NoteRange get noteRange => fullRange;

  void handleKey(KeyEvent event) {
    var updated = false;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.bracketLeft) {
        final newOctave = (_keyboardOctave - 1).clamp(0, 8).toInt();
        if (newOctave != _keyboardOctave) {
          _keyboardOctave = newOctave;
          updated = true;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.bracketRight) {
        final newOctave = (_keyboardOctave + 1).clamp(0, 8).toInt();
        if (newOctave != _keyboardOctave) {

          _keyboardOctave = newOctave;
          updated = true;
        }
      } else {
        final offset = Constants.keyboardKeyOffsets[event.logicalKey];
        if (offset != null && !_activeKeyNotes.containsKey(event.logicalKey)) {
          final semitone = _keyboardOctave * 12 + offset;
          final note = _noteFromOffset(semitone);

          if (fullRange.contains(note)) {
            _pressedNotes.add(note);
            _activeKeyNotes[event.logicalKey] = note;

            midi.playNote(
              channel: 0,
              key: note.pitch,
              velocity: 100,
              sfId: sfId!,
            );
            updated = true;
          }
        }
      }
    } else if (event is KeyUpEvent) {
      final note = _activeKeyNotes.remove(event.logicalKey);
      if (note != null) {
        _pressedNotes.remove(note);
        midi.stopNote(
          channel: 0,
          key: note.pitch,
          sfId: sfId!,
        );
        updated = true;
      }
    }

    if (updated) {
      notifyListeners();
      _updateChord();
    }
  }

  void toggleNote(NotePosition position) {
    if (_pressedNotes.contains(position)) {
      _pressedNotes.remove(position);

      midi.stopNote(
        channel: 0,
        key: position.pitch,
        sfId: sfId!,
      );
    } else {
      _pressedNotes.add(position);

      midi.playNote(
        channel: 0,
        key: position.pitch,
        velocity: 100,
        sfId: sfId!,
      );
    }
    _updateChord();
    notifyListeners();
  }


  NotePosition _noteFromOffset(int semitone) {
    final octave = semitone ~/ 12;
    switch (semitone % 12) {
      case 0:
        return NotePosition(note: Note.C, octave: octave);
      case 1:
        return NotePosition(
            note: Note.C, octave: octave, accidental: Accidental.Sharp);
      case 2:
        return NotePosition(note: Note.D, octave: octave);
      case 3:
        return NotePosition(
            note: Note.D, octave: octave, accidental: Accidental.Sharp);
      case 4:
        return NotePosition(note: Note.E, octave: octave);
      case 5:
        return NotePosition(note: Note.F, octave: octave);
      case 6:
        return NotePosition(
            note: Note.F, octave: octave, accidental: Accidental.Sharp);
      case 7:
        return NotePosition(note: Note.G, octave: octave);
      case 8:
        return NotePosition(
            note: Note.G, octave: octave, accidental: Accidental.Sharp);
      case 9:
        return NotePosition(note: Note.A, octave: octave);
      case 10:
        return NotePosition(
            note: Note.A, octave: octave, accidental: Accidental.Sharp);
      case 11:
      default:
        return NotePosition(note: Note.B, octave: octave);
    }
  }

  void _updateChord() {
    final detected = ChordDetector.detect(_pressedNotes);
    currentChord = detected?.name ?? "";
  }

  final MidiPro midi = MidiPro();
  int? sfId;

  Future<void> loadSoundFont() async {
    sfId = await midi.loadSoundfontAsset(
      assetPath: 'assets/sf2/yamaha_piano.sf2',
      bank: 0,
      program: 0,
    );

    await midi.selectInstrument(
      sfId: sfId!,
      channel: 0,
      bank: 0,
      program: 0,
    );
  }


  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

}
