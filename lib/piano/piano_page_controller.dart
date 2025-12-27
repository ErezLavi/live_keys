import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piano/piano.dart';
import 'package:piano_app/common/constants.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
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

  void _updateChord() {
    final detected = ChordDetector.detect(_pressedNotes);
    currentChord = detected?.name ?? "";
  }

  void handleKeyboardKey(KeyEvent event) {
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

  final MidiPro midi = MidiPro();
  int? sfId;

  void pressNote(NotePosition position) {
    if (!_pressedNotes.contains(position)) {
      _pressedNotes.add(position);

      midi.playNote(
        channel: 0,
        key: position.pitch,
        velocity: 100,
        sfId: sfId!,
      );

      _updateChord();
      notifyListeners();
    }
  }

  void releaseNote(NotePosition position) {
    if (_pressedNotes.contains(position)) {
      _pressedNotes.remove(position);

      midi.stopNote(
        channel: 0,
        key: position.pitch,
        sfId: sfId!,
      );

      _updateChord();
      notifyListeners();
    }
  }

  //*** MIDI sound ***
  Future<void> loadSoundFont() async {
    sfId = await midi.loadSoundfontAsset(
      assetPath: Constants.rhodesSoundFontAsset,
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

  // *** MIDI hardware ***
  StreamSubscription<MidiPacket>? _midiDataSubscription;
  StreamSubscription<String>? _midiSetupSubscription;
  final MidiCommand midiCommand = MidiCommand();


  Future<void> startHardwareMidiListening() async {
    _midiDataSubscription ??=
        midiCommand.onMidiDataReceived?.listen(_handleMidiPacket);

    _midiSetupSubscription ??=
        midiCommand.onMidiSetupChanged?.listen((_) => _connectToFirstDevice());

    await _connectToFirstDevice();
  }

  Future<void> _connectToFirstDevice() async {
    try {
      final devices = await midiCommand.devices;
      if (devices == null) {
        debugPrint('No MIDI devices detected');
        return;
      }

      MidiDevice? target;
      for (final device in devices) {
        if (device.connected) {
          target = device;
          break;
        }
        target ??= device;
      }

      if (target == null) {
        return;
      }

      if (!target.connected) {
        await midiCommand.connectToDevice(target);
        debugPrint('Connected to MIDI device: ${target.name}');
      }
    } catch (e) {
      debugPrint('Failed to connect to MIDI device: $e');
    }
  }

  void _handleMidiPacket(MidiPacket packet) {
    final data = packet.data;
    if (data.length < 3) return;

    final status = data[0] & 0xF0;
    final key = data[1];
    final velocity = data[2];
    final notePosition = _noteFromMidiKey(key);

    if (notePosition == null) return;

    if (status == 0x90 && velocity > 0) {
      pressNote(notePosition);
    } else if (status == 0x80 || (status == 0x90 && velocity == 0)) {
      releaseNote(notePosition);
    }
  }

  NotePosition? _noteFromMidiKey(int key) {
    if (key < 0 || key > 127) return null;
    final note = _noteFromOffset(key);
    if (!fullRange.contains(note)) return null;
    return note;
  }

  @override
  void dispose() {
    _midiDataSubscription?.cancel();
    _midiSetupSubscription?.cancel();
    focusNode.dispose();
    super.dispose();
  }
}
