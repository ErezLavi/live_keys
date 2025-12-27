
import 'package:flutter/services.dart';

class Constants {

  static const String rhodesSoundFontAsset = 'assets/sf2/Rhodes.sf2';

  static final Map<LogicalKeyboardKey, int> keyboardKeyOffsets = {
    LogicalKeyboardKey.keyZ: 0,
    LogicalKeyboardKey.keyS: 1,
    LogicalKeyboardKey.keyX: 2,
    LogicalKeyboardKey.keyD: 3,
    LogicalKeyboardKey.keyC: 4,
    LogicalKeyboardKey.keyV: 5,
    LogicalKeyboardKey.keyG: 6,
    LogicalKeyboardKey.keyB: 7,
    LogicalKeyboardKey.keyH: 8,
    LogicalKeyboardKey.keyN: 9,
    LogicalKeyboardKey.keyJ: 10,
    LogicalKeyboardKey.keyM: 11,
    LogicalKeyboardKey.comma: 12,
    LogicalKeyboardKey.keyL: 13,
    LogicalKeyboardKey.period: 14,
    LogicalKeyboardKey.semicolon: 15,
    LogicalKeyboardKey.slash: 16,
  };

  static Map<String, Set<int>> chordDB = {
    "":       {0, 4, 7},
    "m":      {0, 3, 7},
    "7":      {0, 4, 7, 10},
    "maj7":   {0, 4, 7, 11},
    "m7":     {0, 3, 7, 10},
    "mMaj7":  {0, 3, 7, 11},
    "sus2":   {0, 2, 7},
    "sus4":   {0, 5, 7},
    "dim":    {0, 3, 6},
    "dim7":   {0, 3, 6, 9},
    "aug":    {0, 4, 8},

    // Extensions:
    "9":      {0, 4, 7, 10, 2},
    "11":     {0, 4, 7, 10, 2, 5},
    "13":     {0, 4, 7, 10, 2, 5, 9},

    // Altered
    "7b9":    {0, 4, 7, 10, 1},
    "7#9":    {0, 4, 7, 10, 3},
    "7#11":   {0, 4, 7, 10, 6},
    "7b13":   {0, 4, 7, 10, 8},

    // --- Additions ---

    "add4":   {0, 4, 7, 5},    // add 4
    "add9":   {0, 4, 7, 2},    // could be add2

    "6":      {0, 4, 7, 9},    // maj6
    "m9(no7)":{0, 3, 7, 2},
    "m6":     {0, 3, 7, 9},    // minor 6

    "m7b5":   {0, 3, 6, 10},   // half-diminished / ø7
    "7sus4":  {0, 5, 7, 10},   // 7sus
    "7b5":    {0, 4, 6, 10},
    "7#5":    {0, 4, 8, 10},   // 7aug
    "maj7#5": {0, 4, 8, 11},   // M7#5 / augMaj7
  };

  // Lower is simpler / preferred in tie-breaks.
  static const Map<String, int> chordRank = {
    "": 0,
    "m": 1,
    "7": 2,
    "maj7": 3,
    "m7": 4,
    "mMaj7": 5,
    "sus2": 6,
    "sus4": 7,
    "dim": 8,
    "dim7": 9,
    "aug": 10,
    "9": 11,
    "11": 12,
    "13": 13,
    "7b9": 14,
    "7#9": 15,
    "7#11": 16,
    "7b13": 17,
    "add4": 18,
    "add9": 19,
    "6": 20,
    "m9(no7)": 21,
    "m6": 22,
    "m7b5": 23,
    "7sus4": 24,
    "7b5": 25,
    "7#5": 26,
    "maj7#5": 27,
  };

  static const sharpNames = [
    "C", "C#", "D", "D#", "E", "F",
    "F#", "G", "G#", "A", "A#", "B"
  ];

  static const flatNames = [
    "C", "Db", "D", "Eb", "E", "F",
    "Gb", "G", "Ab", "A", "Bb", "B"
  ];

  static String noteName(int pc, {bool useFlats = false}) {
    return useFlats ? flatNames[pc] : sharpNames[pc];
  }
}
