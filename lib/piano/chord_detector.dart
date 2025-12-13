import 'package:piano_app/common/constants.dart';
import 'package:piano/piano.dart';


//TODO: need to be examined / rewritten.

class DetectedChord {
  final String name;
  final int root;
  final int bass;

  DetectedChord({required this.name, required this.root, required this.bass});
}

class ChordDetector {
  /// Main entry point
  static DetectedChord? detect(Set<NotePosition> pressed) {
    if (pressed.length < 3) return null;

    // Convert to pitch classes 0–11
    final pcs = pressed.map((e) => e.pitch % 12).toSet();

    // True bass (lowest real pitch)
    final bassPc =
        pressed.reduce((a, b) => a.pitch < b.pitch ? a : b).pitch % 12;

    DetectedChord? best;
    int bestScore = -99999;

    for (final rootPc in pcs) {
      final playedIntervals = _intervalsFromRoot(pcs, rootPc);

      for (final entry in Constants.chordDB.entries) {
        final chordType = entry.key;
        final template = entry.value;

        final score = _scoreChord(template, playedIntervals);

        // Reject wrong triad roots:
        if (!_acceptableRoot(template, playedIntervals)) continue;

        if (score > bestScore) {
          bestScore = score;
          best = DetectedChord(
            name: _buildName(rootPc, bassPc, chordType, playedIntervals, template),
            root: rootPc,
            bass: bassPc,
          );
        }
      }
    }

    return best;
  }

  /// Convert played notes to interval set
  static Set<int> _intervalsFromRoot(Set<int> pcs, int root) {
    final out = <int>{};
    for (final p in pcs) {
      int i = (p - root + 12) % 12;
      if (i != 0) out.add(i);
    }
    return out;
  }

  /// Score poorly matching chords lower
  static int _scoreChord(Set<int> template, Set<int> played) {
    int extra = played.difference(template).length;
    int missing = template.difference(played).length;

    return -(extra + missing * 2); // missing is worse than extra
  }

  /// Ensure we don't pick impossible triad roots
  static bool _acceptableRoot(Set<int> template, Set<int> played) {
    bool templateIsTriad =
        template.contains(4) && template.contains(7) ||
            template.contains(3) && template.contains(7);

    bool playedHasTriad =
        played.contains(4) && played.contains(7) ||
            played.contains(3) && played.contains(7);

    // If the chord template is a triad but player did NOT play triad intervals → reject this root
    if (templateIsTriad && !playedHasTriad) return false;

    return true;
  }

  /// Naming logic including slash/inversion rules
  static String _buildName(
      int rootPc,
      int bassPc,
      String chordType,
      Set<int> playedIntervals,
      Set<int> template,
      ) {
    final rootName = Constants.noteName(rootPc);
    String name = "$rootName$chordType";

    // If bass == root → no inversion
    if (bassPc == rootPc) return name;

    int bassInt = (bassPc - rootPc + 12) % 12;

    // Show slash only for unusual basses (sus chords, 7th chords, add chords)
    bool showSlash = false;

    // 1st inversion: 3rd in bass → optional
    if (bassInt == 3 || bassInt == 4) {
      showSlash = true; // choose true if you want Am/E etc.
    }

    // 2nd inversion: 5th in bass → usually HIDDEN
    else if (bassInt == 7) {
      showSlash = false; // keep as root position chord
    }

    // Other bass notes ALWAYS slash
    else {
      showSlash = true;
    }

    if (showSlash) {
      final bassName = Constants.noteName(bassPc);
      return "$name/$bassName";
    }

    return name;
  }
}
