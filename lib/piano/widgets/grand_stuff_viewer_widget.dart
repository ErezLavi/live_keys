import 'package:flutter/material.dart';
import 'package:piano/piano.dart';

class GrandStaffViewerWidget extends StatelessWidget {
  final Color clefColor;
  final Color noteColor;
  final List<NotePosition> pressedNotes;

  const GrandStaffViewerWidget({
    super.key,
    this.clefColor = Colors.black,
    this.noteColor = Colors.black,
    this.pressedNotes = const [],
  });

  List<NoteImage> _filterNotesForClef(Clef clef, NoteRange range) {
    return pressedNotes
        .where((note) => range.contains(note))
        .map((note) => NoteImage(notePosition: note))
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
            child: ClefImage(
              clef: Clef.Treble,
              noteRange: trebleRange,
              noteImages: trebleNotes,
              clefColor: clefColor,
              noteColor: noteColor,
              size: Size(400, 150),
            ),
          ),
          Expanded(
            child: ClefImage(
              clef: Clef.Bass,
              noteRange: bassRange,
              noteImages: bassNotes,
              clefColor: clefColor,
              noteColor: noteColor,
              size: Size(400, 150),
            ),
          ),
        ],
      ),
    );
  }
}