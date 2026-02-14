import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piano/piano.dart';
import 'package:piano_app/common/audio_service.dart';
import 'package:piano_app/common/chord_detector.dart';
import 'package:piano_app/common/constants.dart';
import 'package:piano_app/common/midi_service.dart';

class PianoPageController extends ChangeNotifier {
  PianoPageController();

  static final NoteRange fullRange = NoteRange(
    from: NotePosition(note: Note.A, octave: 0),
    to: NotePosition(note: Note.C, octave: 8),
  );

  final FocusNode focusNode = FocusNode();
  final Set<NotePosition> _pressedNotes = {};
  final Map<LogicalKeyboardKey, NotePosition> _activeKeyNotes = {};
  final MidiService _midiService = MidiService();
  final AudioService _audioService = AudioService();

  // Variables
  int _keyboardOctave = 4;
  bool _useFlats = false;
  bool _isMuted = false;
  SoundFontOption _soundFont = Constants.soundFonts.first;
  String currentChord = '';
  final SelectedChord _selectedChord = SelectedChord();
  final SelectedScale _selectedScale = SelectedScale();

  // Getters
  List<NotePosition> get pressedNotes => _pressedNotes.toList();
  List<NotePosition> get selectedChordNotes => _selectedChord.notes;
  List<NotePosition> get selectedScaleNotes => _selectedScale.notes;
  NoteRange get noteRange => fullRange;
  int get keyboardOctave => _keyboardOctave;
  bool get useFlats => _useFlats;
  bool get isMuted => _isMuted;
  SoundFontOption get selectedSoundFont => _soundFont;
  List<SoundFontOption> get availableSoundFonts =>
      List.unmodifiable(Constants.soundFonts);
  List<NotePosition> get combinedHighlightedNotes {
    final combined = <NotePosition>{};
    combined.addAll(_selectedChord.notes);
    combined.addAll(_selectedScale.notes);
    return combined.toList();
  }
  // Selected chord
  int get selectedChordInversion => _selectedChord.inversion;
  int get selectedChordRootPc => _selectedChord.rootPc ?? 0;
  String get selectedChordType => _selectedChord.type;
  // Selected scale
  int get selectedScaleRootPc => _selectedScale.rootPc ?? 0;
  String get selectedScaleType => _selectedScale.type;
  // Connected devices
  List<String> get connectedDeviceNames => _midiService.connectedDeviceNames;

  void _updateChord() {
    final detected =
        ChordDetector.detect(_pressedNotes, useFlats: _useFlats);
    currentChord = detected?.name ?? "";
  }

  void setUseFlats(bool value) {
    if (_useFlats == value) return;
    _useFlats = value;
    _updateChord();
    notifyListeners();
  }

  void setMuted(bool value) {
    if (_isMuted == value) return;
    _isMuted = value;
    if (_isMuted) {
      for (final note in _pressedNotes) {
        _audioService.stopNote(key: note.pitch);
      }
    }
    notifyListeners();
  }
  void toggleMuted() => setMuted(!_isMuted);

  void incrementOctave() {
    final newOctave = (_keyboardOctave + 1).clamp(0, 8).toInt();
    if (newOctave != _keyboardOctave) {
      _keyboardOctave = newOctave;
      _rebuildSelectedHighlights();
      notifyListeners();
    }
  }

  void decrementOctave() {
    final newOctave = (_keyboardOctave - 1).clamp(0, 8).toInt();
    if (newOctave != _keyboardOctave) {
      _keyboardOctave = newOctave;
      _rebuildSelectedHighlights();
      notifyListeners();
    }
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
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.bracketLeft) {
        decrementOctave();
        return;
      } else if (event.logicalKey == LogicalKeyboardKey.bracketRight) {
        incrementOctave();
        return;
      } else {
        final offset = Constants.keyboardKeyOffsets[event.logicalKey];
        if (offset != null && !_activeKeyNotes.containsKey(event.logicalKey)) {
          final semitone = _keyboardOctave * 12 + offset;
          final note = noteFromOffset(semitone);

          if (fullRange.contains(note)) {
            _pressedNotes.add(note);
            _activeKeyNotes[event.logicalKey] = note;

            if (!_isMuted) {
              _audioService.playNote(key: note.pitch);
            }
            updated = true;
          }
        }
      }
    } else if (event is KeyUpEvent) {
      final note = _activeKeyNotes.remove(event.logicalKey);
      if (note != null) {
        _pressedNotes.remove(note);
        if (!_isMuted) {
          _audioService.stopNote(key: note.pitch);
        }
        updated = true;
      }
    }

    if (updated) {
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
    _selectedChord.rootPc = rootPc;
    _selectedChord.type = chordType;
    _selectedChord.inversion = inversion;
    _selectedChord.notes = buildChordNotesForOctave(
      rootPc,
      chordType,
      _keyboardOctave,
      _selectedChord.inversion,
    );
    notifyListeners();
  }

  void clearSelectedChord() {
    _selectedChord.reset();
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
    _selectedScale.rootPc = rootPc;
    _selectedScale.type = scaleType;
    _selectedScale.notes = buildScaleNotesForOctave(
      rootPc,
      scaleType,
      _keyboardOctave,
    );
    notifyListeners();
  }

  void clearSelectedScale() {
    _selectedScale.reset();
    notifyListeners();
  }

  void _rebuildSelectedHighlights() {
    if (_selectedChord.rootPc != null) {
      _selectedChord.notes = buildChordNotesForOctave(
        _selectedChord.rootPc!,
        _selectedChord.type,
        _keyboardOctave,
        _selectedChord.inversion,
      );
    }
    if (_selectedScale.rootPc != null) {
      _selectedScale.notes = buildScaleNotesForOctave(
        _selectedScale.rootPc!,
        _selectedScale.type,
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

  void pressNote(NotePosition position) {
    if (!_pressedNotes.contains(position)) {
      _pressedNotes.add(position);

      if (!_isMuted) {
        _audioService.playNote(key: position.pitch);
      }

      _updateChord();
      notifyListeners();
    }
  }

  void releaseNote(NotePosition position) {
    if (_pressedNotes.contains(position)) {
      _pressedNotes.remove(position);

      if (!_isMuted) {
        _audioService.stopNote(key: position.pitch);
      }
      _updateChord();
      notifyListeners();
    }
  }
  //*** Audio handling***
  Future<void> setSoundFont(SoundFontOption soundFont) async {
    if (_soundFont.assetPath == soundFont.assetPath) return;
    _soundFont = soundFont;
    for (final note in _pressedNotes) {
      _audioService.stopNote(key: note.pitch);
    }
    await _audioService.loadSoundFont(assetPath: soundFont.assetPath);
    notifyListeners();
  }
  Future<void> loadSoundFont() async {
    await _audioService.loadSoundFont(assetPath: _soundFont.assetPath);
  }

  //*** Midi handling ***
  Future<void> startHardwareMidiListening() async {
    await _midiService.startListening(
      onNoteOn: (midiKey) {
        final notePosition = _noteFromMidiKey(midiKey);
        if (notePosition != null) {
          pressNote(notePosition);
        }
      },
      onNoteOff: (midiKey) {
        final notePosition = _noteFromMidiKey(midiKey);
        if (notePosition != null) {
          releaseNote(notePosition);
        }
      },
      onDeviceNamesChanged: notifyListeners,
    );
  }

  NotePosition? _noteFromMidiKey(int key) {
    if (key < 0 || key > 127) return null;
    final note = noteFromOffset(key);
    if (!fullRange.contains(note)) return null;
    return note;
  }

  @override
  void dispose() {
    _midiService.dispose();
    focusNode.dispose();
    super.dispose();
  }
}

class SelectedChord {
  int? rootPc;
  String type;
  int inversion;
  List<NotePosition> notes;

  SelectedChord({
    this.rootPc,
    this.type = '',
    this.inversion = 0,
    List<NotePosition>? notes,
  }) : notes = notes ?? [];

  void reset() {
    rootPc = null;
    type = '';
    inversion = 0;
    notes = [];
  }
}

class SelectedScale {
  int? rootPc;
  String type;
  List<NotePosition> notes;

  SelectedScale({
    this.rootPc,
    this.type = 'major',
    List<NotePosition>? notes,
  }) : notes = notes ?? [];

  void reset() {
    rootPc = null;
    type = 'major';
    notes = [];
  }
}
