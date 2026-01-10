
import 'package:flutter/services.dart';

class Constants {

  static const String rhodesSoundFontAsset = 'assets/sf2/Rhodes.sf2';

  static const Color playedNoteColor = Color(0xFF6E026F);
  static const Color highlightedNoteColor = Color(0xFFF29AAE);

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
    "":       {4, 7},
    "m":      {3, 7},
    "7":      {4, 7, 10},
    "maj7":   {4, 7, 11},
    "m7":     {3, 7, 10},
    "mMaj7":  {3, 7, 11},
    "mMaj7#5": {3, 8, 11},
    "sus2":   {2, 7},
    "sus4":   {5, 7},
    "dim":    {3, 6},
    "dim7":   {3, 6, 9},
    "aug":    {4, 8},

    // Extensions:
    "9":      {4, 7, 10, 2},
    "11":     {4, 7, 10, 2, 5},
    "13":     {4, 7, 10, 2, 5, 9},

    // Altered
    "7b9":    {4, 7, 10, 1},
    "7#9":    {4, 7, 10, 3},
    "7#11":   {4, 7, 10, 6},
    "7b13":   {4, 7, 10, 8},

    // --- Additions ---
    "add4":   {4, 7, 5},
    "add9":   {4, 7, 2},    
    "6":      {4, 7, 9},
    "m9":     {3, 7, 10, 2},
    "m11":    {3, 7, 10, 2, 5},
    "m13":    {3, 7, 10, 2, 5, 9},
    "m9(no7)":{3, 7, 2},
    "m6":     {3, 7, 9},
    "m7b5":   {3, 6, 10},
    "7sus4":  {5, 7, 10},
    "7b5":    {4, 6, 10},
    "7#5":    {4, 8, 10},
    "maj7#5": {4, 8, 11},

    "maj9":   {4, 7, 11, 2},
  };

  // Required intervals that must be explicitly present to allow a chord type.
  static final Map<String, Set<int>> chordRequiredIntervals = {
    // Suspensions
    "sus2": {2},
    "sus4": {5},
    "7sus4": {5},

    // Altered fifths
    "aug": {8},
    "7#5": {8},
    "maj7#5": {8},
    "mMaj7#5": {8},

    // Altered extensions
    "7b9": {1},
    "7#9": {3},
    "7#11": {6},
    "7b13": {8},
  };

  // Lower is simpler / preferred in tie-breaks.
  static const Map<String, int> chordRank = {
    "": 0,
    "m": 1,
    "7": 2,
    "maj7": 3,
    "m7": 4,
    "maj9": 7,
    "sus2": 8,
    "sus4": 9,
    "dim": 10,
    "dim7": 11,
    "aug": 12,
    "9": 13,
    "11": 14,
    "13": 15,
    "add4": 20,
    "add9": 21,
    "6": 22,
    "m9": 23,
    "m11": 24,
    "m13": 25,
    "m6": 26,
    "m7b5": 27,
    "7sus4": 28,
    "7b5": 29,
    "7#5": 30,
    "maj7#5": 31,
    "m9(no7)": 32,
    "mMaj7": 33,
    "mMaj7#5": 34,
    "7b9": 35,
    "7#9": 36,
    "7#11": 37,
    "7b13": 38,
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
