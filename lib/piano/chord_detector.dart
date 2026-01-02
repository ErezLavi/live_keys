import 'package:piano_app/common/constants.dart';
import 'package:piano/piano.dart';

class DetectedChord {
  final String name;
  final int root;
  final int bass;

  DetectedChord({required this.name, required this.root, required this.bass});
}
class Candidate {
  final int root;
  final String type;
  final int score;

  Candidate(this.root, this.type, this.score);
}

class ChordDetector {
  /// Main entry point
  static DetectedChord? detect(Set<NotePosition> pressed) {
    // Convert to pitch classes 0–11 with deterministic order
    final List<int> pcs = pressed
        .map((e) => e.pitch % 12)
        .toSet()
        .toList()
      ..sort();

    final pcsSet = pcs.toSet();
    if (pcsSet.length < 3) return null;

    // True bass (lowest real pitch)
    final bassPc =
        pressed.reduce((a, b) => a.pitch < b.pitch ? a : b).pitch % 12;

    final candidates = <Candidate>[];

    for (final rootPc in pcs) {
      final playedIntervals = _intervalsFromRoot(pcsSet, rootPc);

      for (final entry in Constants.chordDB.entries) {
        final chordType = entry.key;
        final template = entry.value;

        // Reject wrong triad roots:
        if (!_acceptableRoot(template, playedIntervals)) continue;

        final required = Constants.chordRequiredIntervals[chordType];
        if (required != null &&
            !required.every(playedIntervals.contains)) {
          continue;
        }

        final isSus = chordType.contains("sus");
        if (isSus &&
            (playedIntervals.contains(3) || playedIntervals.contains(4))) {
          continue;
        }

        final score = _scoreChord(template, playedIntervals);
        candidates.add(Candidate(rootPc, chordType, score));
      }
    }
    if (candidates.isEmpty) return null;

    candidates.sort((a, b) {
      if (a.score != b.score) {
        return b.score.compareTo(a.score);
      }

      final aRank = Constants.chordRank[a.type] ?? 9999;
      final bRank = Constants.chordRank[b.type] ?? 9999;
      if (aRank != bRank) {
        return aRank.compareTo(bRank);
      }

      if (a.root == bassPc && b.root != bassPc) return -1;
      if (b.root == bassPc && a.root != bassPc) return 1;

      return a.root.compareTo(b.root);
    });

    final best = candidates.first;
    final playedIntervals = _intervalsFromRoot(pcsSet, best.root);

    return DetectedChord(
      name: _buildName(
        best.root,
        bassPc,
        best.type,
        playedIntervals,
        Constants.chordDB[best.type]!,
      ),
      root: best.root,
      bass: bassPc,
    );
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
    final hasFifth = playedIntervals.contains(7) || playedIntervals.contains(8);
    final bassIsMaj7 = (bassPc - rootPc + 12) % 12 == 11;
    if (bassIsMaj7 && !hasFifth) {
      return "${Constants.noteName(bassPc)}/${Constants.noteName(rootPc)}";
    }

    final rootName = Constants.noteName(rootPc);
    String name = "$rootName$chordType";

    if (bassPc == rootPc) return name;
    int bassInt = (bassPc - rootPc + 12) % 12;

    // Show slash only for unusual basses (sus chords, 7th chords, add chords)
    bool showSlash = false;

    // 1st inversion: 3rd in bass → optional
    if (bassInt == 3 || bassInt == 4) {
      showSlash = true; 
    }

    // 2nd inversion: 5th in bass → usually shown
    else if (bassInt == 7) {
      showSlash = true; 
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
