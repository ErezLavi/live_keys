import 'package:flutter/material.dart';
import 'package:piano/piano.dart';
import 'package:piano_app/custom_piano/custom_clef_image.dart';

class GrandStaffViewerWidget extends StatelessWidget {
  final Color clefColor;
  final Color noteColor;
  final List<NotePosition> pressedNotes;
  final bool useAlternativeAccidentals;

  const GrandStaffViewerWidget({
    super.key,
    this.clefColor = Colors.black,
    this.noteColor = Colors.black,
    this.pressedNotes = const [],
    this.useAlternativeAccidentals = false,
  });

  List<NoteImage> _filterNotesForClef(Clef clef, NoteRange range) {
    return pressedNotes
        .where((note) => range.contains(note))
        .map((note) {
          final displayNote = useAlternativeAccidentals
              ? note.alternativeAccidental ?? note
              : note;
          return NoteImage(notePosition: displayNote);
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final trebleRange = NoteRange.forClefs([Clef.Treble]);
    final bassRange = NoteRange.forClefs([Clef.Bass]);

    final middleC = NotePosition(note: Note.C, octave: 4);
    final trebleNotes = _filterNotesForClef(Clef.Treble, trebleRange);
    final bassNotes = _filterNotesForClef(Clef.Bass, bassRange)
        .where((note) => note.notePosition != middleC)
        .toList();

    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 8/3,
              child: CustomClefImage(
                clef: Clef.Treble,
                noteRange: trebleRange,
                noteImages: trebleNotes,
                clefColor: clefColor,
                noteColor: noteColor,
                useAlternativeAccidentals: useAlternativeAccidentals,
              ),
            ),
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 8/3,
              child: CustomClefImage(
                clef: Clef.Bass,
                noteRange: bassRange,
                noteImages: bassNotes,
                clefColor: clefColor,
                noteColor: noteColor,
                useAlternativeAccidentals: useAlternativeAccidentals,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
