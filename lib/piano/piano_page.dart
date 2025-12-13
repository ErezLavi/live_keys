import 'package:flutter/material.dart';
import 'package:piano_app/piano/widgets/custom_interactive_piano.dart';
import 'package:piano_app/piano/piano_page_controller.dart';

class PianoPage extends StatefulWidget {
  const PianoPage({super.key, required this.controller});

  final PianoPageController controller;

  @override
  State<PianoPage> createState() => _PianoPageState();
}

//TODO: 1. *Create a small design prototype
//TODO: 2. re-examine the chord_detector algorithm
//TODO: 3. Show the clef widget
//TODO: 4. Show chords in all inversions + scales widget
//TODO: 5. games - play given chord/scale/note by its name/clef/sound.(3+)
//TODO: 6. more sound samples (rhodes etc..)
//TODO: 7. settings widget - adjust color, layout and more...

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
      appBar: AppBar(
        title: const Text('Live Keys'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                _controller .currentChord,
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
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
