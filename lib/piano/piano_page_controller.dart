import 'dart:async';
import 'package:flutter/foundation.dart';
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
  List<String> _connectedDeviceNames = ['Computer Keyboard'];

  // Variables
  int _keyboardOctave = 4;
  String currentChord = '';
  List<NotePosition> _selectedChordNotes = [];
  int? _selectedChordRootPc;
  String _selectedChordType = '';
  int _selectedChordInversion = 0;
  List<NotePosition> _selectedScaleNotes = [];
  int? _selectedScaleRootPc;
  String _selectedScaleType = 'major';

  // Getters
  List<NotePosition> get pressedNotes => _pressedNotes.toList();
  List<NotePosition> get selectedChordNotes => _selectedChordNotes;
  List<NotePosition> get selectedScaleNotes => _selectedScaleNotes;
  NoteRange get noteRange => fullRange;
  int get keyboardOctave => _keyboardOctave;
  int get selectedChordInversion => _selectedChordInversion;
  List<String> get connectedDeviceNames =>
      List.unmodifiable(_connectedDeviceNames);
  List<NotePosition> get combinedHighlightedNotes {
    final combined = <NotePosition>{};
    combined.addAll(_selectedChordNotes);
    combined.addAll(_selectedScaleNotes);
    return combined.toList();
  }

  void _updateChord() {
    final detected = ChordDetector.detect(_pressedNotes);
    currentChord = detected?.name ?? "";
  }

  (String, String) splitChordName(String chord) {
    if (chord.isEmpty) return ('', '');
    int rootLen = 1;
    if (chord.length > 1) {
      final accidental = chord[1];
      if (accidental == '#' || accidental == 'b') {
        rootLen = 2;
      }
    }
    return (chord.substring(0, rootLen), chord.substring(rootLen));
  }

  void handleKeyboardKey(KeyEvent event) {
    var updated = false;
    var octaveChanged = false;
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.bracketLeft) {
        final newOctave = (_keyboardOctave - 1).clamp(0, 8).toInt();
        if (newOctave != _keyboardOctave) {
          _keyboardOctave = newOctave;
          updated = true;
          octaveChanged = true;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.bracketRight) {
        final newOctave = (_keyboardOctave + 1).clamp(0, 8).toInt();
        if (newOctave != _keyboardOctave) {

          _keyboardOctave = newOctave;
          updated = true;
          octaveChanged = true;
        }
      } else {
        final offset = Constants.keyboardKeyOffsets[event.logicalKey];
        if (offset != null && !_activeKeyNotes.containsKey(event.logicalKey)) {
          final semitone = _keyboardOctave * 12 + offset;
          final note = noteFromOffset(semitone);

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
      if (octaveChanged) {
        _rebuildSelectedHighlights();
      }
      notifyListeners();
      _updateChord();
    }
  }

  NotePosition noteFromOffset(int semitone) {
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

  List<NotePosition> buildChordNotesForOctave(
    int rootPc,
    String chordType,
    int octave,
    int inversion,
  ) {
    final intervals = Constants.chordDB[chordType];
    if (intervals == null) return [];

    final rootPitch = octave * 12 + rootPc;
    final orderedIntervals = _normalizeChordIntervals(chordType, intervals);
    final invertedIntervals =
        Constants.applyChordInversion(orderedIntervals, inversion);
    final selectedNotes = <NotePosition>[];
    final usedPitches = <int>{};

    for (final interval in invertedIntervals) {
      final pitch = rootPitch + interval;
      if (!usedPitches.add(pitch)) continue;
      final note = noteFromOffset(pitch);
      if (fullRange.contains(note)) {
        selectedNotes.add(note);
      }
    }

    return selectedNotes;
  }

  void onChordSelected(int rootPc, String chordType, int inversion) {
    _selectedChordRootPc = rootPc;
    _selectedChordType = chordType;
    _selectedChordInversion = inversion;
    _selectedChordNotes = buildChordNotesForOctave(
      rootPc,
      chordType,
      _keyboardOctave,
      _selectedChordInversion,
    );
    notifyListeners();
  }

  void clearSelectedChord() {
    _selectedChordRootPc = null;
    _selectedChordType = '';
    _selectedChordInversion = 0;
    _selectedChordNotes = [];
    notifyListeners();
  }

  List<NotePosition> buildScaleNotesForOctave(
    int rootPc,
    String scaleType,
    int octave,
  ) {
    final intervals = Constants.scaleDB[scaleType];
    if (intervals == null) return [];

    final rootPitch = octave * 12 + rootPc;
    final orderedIntervals = intervals.toList()..sort();
    final selectedNotes = <NotePosition>[];
    final usedPitches = <int>{};

    for (final interval in orderedIntervals) {
      final pitch = rootPitch + interval;
      if (!usedPitches.add(pitch)) continue;
      final note = noteFromOffset(pitch);
      if (fullRange.contains(note)) {
        selectedNotes.add(note);
      }
    }

    return selectedNotes;
  }

  void onScaleSelected(int rootPc, String scaleType) {
    _selectedScaleRootPc = rootPc;
    _selectedScaleType = scaleType;
    _selectedScaleNotes = buildScaleNotesForOctave(
      rootPc,
      scaleType,
      _keyboardOctave,
    );
    notifyListeners();
  }

  void clearSelectedScale() {
    _selectedScaleRootPc = null;
    _selectedScaleType = 'major';
    _selectedScaleNotes = [];
    notifyListeners();
  }

  void _rebuildSelectedHighlights() {
    if (_selectedChordRootPc != null) {
      _selectedChordNotes = buildChordNotesForOctave(
        _selectedChordRootPc!,
        _selectedChordType,
        _keyboardOctave,
        _selectedChordInversion,
      );
    }
    if (_selectedScaleRootPc != null) {
      _selectedScaleNotes = buildScaleNotesForOctave(
        _selectedScaleRootPc!,
        _selectedScaleType,
        _keyboardOctave,
      );
    }
  }

  List<int> _normalizeChordIntervals(String chordType, Set<int> intervals) {
    final extensionIntervals = <int>{};

    if (chordType.contains('9')) {
      extensionIntervals.add(2);
    }
    if (chordType.contains('11')) {
      extensionIntervals.addAll([2, 5]);
    }
    if (chordType.contains('13')) {
      extensionIntervals.addAll([2, 5, 9]);
    }
    if (chordType.contains('b9')) extensionIntervals.add(1);
    if (chordType.contains('#9')) extensionIntervals.add(3);
    if (chordType.contains('#11')) extensionIntervals.add(6);
    if (chordType.contains('b13')) extensionIntervals.add(8);

    final normalized = <int>{0, ...intervals}.map((interval) {
      if (interval != 0 && extensionIntervals.contains(interval)) {
        return interval + 12;
      }
      return interval;
    }).toList()
      ..sort();

    return normalized;
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
        _setConnectedDeviceNames(null);
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
        _setConnectedDeviceNames(devices);
        return;
      }

      if (!target.connected) {
        await midiCommand.connectToDevice(target);
        debugPrint('Connected to MIDI device: ${target.name}');
      }
      _setConnectedDeviceNames(devices, ensureName: target.name);
    } catch (e) {
      debugPrint('Failed to connect to MIDI device: $e');
    }
  }

  void _setConnectedDeviceNames(
    List<MidiDevice>? devices, {
    String? ensureName,
  }) {
    final names = <String>['Computer Keyboard'];
    if (devices != null) {
      for (final device in devices) {
        if (device.connected) {
          names.add(device.name);
        }
      }
    }
    if (ensureName != null && !names.contains(ensureName)) {
      names.add(ensureName);
    }
    if (!listEquals(_connectedDeviceNames, names)) {
      _connectedDeviceNames = names;
      notifyListeners();
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
    final note = noteFromOffset(key);
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
