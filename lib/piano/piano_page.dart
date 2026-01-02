import 'package:flutter/material.dart';
import 'package:piano_app/piano/widgets/custom_interactive_piano.dart';
import 'package:piano_app/piano/piano_page_controller.dart';
import 'package:piano_app/piano/widgets/grand_stuff_viewer_widget.dart';
import 'package:piano_app/piano/widgets/chord_viewer.dart';

class PianoPage extends StatefulWidget {
  const PianoPage({super.key, required this.controller});

  final PianoPageController controller;

  @override
  State<PianoPage> createState() => _PianoPageState();
}

//TODO: 1. re-examine the chord_detector algorithm
//TODO: 2. Show chords in all inversions + scales widget
//TODO: 3. switch between 2 sound samples on menu
//TODO: 4. games - play given chord/scale/note by its name/clef/sound.(3+)
//TODO: 5. settings widget - adjust color, layout and more...

class _PianoPageState extends State<PianoPage> {
  late final PianoPageController _controller;

  void _onControllerUpdated() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.loadSoundFont();
    _controller.startHardwareMidiListening();
    _controller.addListener(_onControllerUpdated);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdated);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GrandStaffViewerWidget(
                    pressedNotes: _controller.pressedNotes,
                  ),
                  Expanded(
                    child: ChordViewer(
                      chord: _controller.currentChord,
                      splitChordName: _controller.splitChordName,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: KeyboardListener(
              focusNode: _controller.focusNode,
              autofocus: true,
              onKeyEvent: _controller.handleKeyboardKey,
              child: CustomInteractivePiano(
                highlightedNotes: _controller.pressedNotes,
                naturalColor: Colors.white,
                accidentalColor: Colors.black,
                keyWidth: 40,
                noteRange: _controller.noteRange,
                onNotePositionTapped: _controller.pressNote,
                onNotePositionReleased: _controller.releaseNote,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
