
import 'package:flutter/services.dart';

class Constants {
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
    "maj":    {0, 4, 7},
    "min":    {0, 3, 7},
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