# Chord Detector

This note describes the current chord-detection logic in [lib/common/chord_detector.dart](/Users/erezlavi/Personal%20projects/piano_app/lib/common/chord_detector.dart).

## What It Does

`ChordDetector.detect()` takes the pressed `NotePosition` set and returns a `DetectedChord` with:

- `name`: display name such as `C`, `Cm`, `Cmaj7`, or `C/E`
- `root`: root pitch class (`0-11`)
- `bass`: lowest played pitch class (`0-11`)

If fewer than 3 unique pitch classes are played, it returns `null`. (Doesn't support dyads/intervals as chords here)

Repeated notes in other octaves do not change detection. Only unique pitch classes are matched; absolute pitch is only used to find the bass note for slash-chord naming.

## Detection Rules

1. Convert pressed notes to unique pitch classes.
2. Find the bass from the lowest played note.
3. Try each played pitch class as a possible root.
4. Compare that root against every chord template in `Constants.chordDB`.
5. Keep only candidates that pass the filters:
   - quality-defining intervals must exist for the candidate root (`3` for minor, `4` for major, plus extra required tones for some chord types)
   - required color tones must exist for specific chord types in `Constants.chordRequiredIntervals`
   - at most one template tone may be missing
   - `sus` chords are rejected if a major or minor third is also present
6. Score each remaining candidate by mismatch count:
   - `score = -(extra tones + missing tones)`
7. Sort candidates by:
   - highest score
   - root position preference (`root == bass`)
   - lower `Constants.chordRank` value
   - lower root pitch class

The best candidate becomes the detected chord.

## Naming

Names use `Constants.noteName()` and the matched chord suffix from `Constants.chordDB`.

- Root position: `C`, `Cm7`, `Cadd9`
- Inversion or slash bass: `C/E`, `Cmaj7/B`

If `useFlats` is enabled, note names use flat spellings such as `Bb` instead of `A#`.

## Supported Chord Families

The current templates cover:

- triads: major, minor, diminished, augmented, suspended
- sevenths: `7`, `maj7`, `m7`, `mMaj7`, `mMaj7#5`, `dim7`, `m7b5`, `7sus4`, `maj7sus4`, `maj7#5`
- extensions: `9`, `11`, `13`, `maj9`, `m9`, `m11`, `m13`
- added-tone chords: `add2`, `add4`, `add9`, `m(add9)`, `m9(no7)`, `6`, `6/9`, `m6`
- altered chords: `7b9`, `7#9`, `7#11`, `7b13`, `7#5`, `7b5`, `add#11`, `addb6`

See [lib/common/constants.dart](/Users/erezlavi/Personal%20projects/piano_app/lib/common/constants.dart) for the exact template list.

## Current Test Coverage

The tests in [test/chord_detector_test.dart](/Users/erezlavi/Personal%20projects/piano_app/test/chord_detector_test.dart) currently verify:

- basic major, minor, and seventh chords
- shell voicings without the fifth
- added-color chords such as `Cadd9`, `Caddb6`, and `Cadd#11`
- richer voicings such as `C6/9`
- slash chords such as `C/E`
