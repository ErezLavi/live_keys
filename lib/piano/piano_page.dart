import 'package:flutter/material.dart';
import 'package:piano_app/piano/widgets/custom_interactive_piano.dart';
import 'package:piano_app/piano/piano_page_controller.dart';
import 'package:piano_app/piano/widgets/grand_stuff_viewer_widget.dart';
import 'package:piano_app/piano/widgets/chord_viewer.dart';
import 'package:piano_app/menu/top_bar.dart';

class PianoPage extends StatefulWidget {
  const PianoPage({super.key, required this.controller});

  final PianoPageController controller;

  @override
  State<PianoPage> createState() => _PianoPageState();
}

//TODO: 4. settings widget - adjust color, sf2, show keyboard mapping...
//TODO: 5. games - play given chord/scale/note by its name/clef/sound.(3+)

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
    final screenWidth = MediaQuery.of(context).size.width;
    final keyWidth = (screenWidth / 20).clamp(24.0, 60.0);

    return Scaffold(
      body: Stack(
        children: [
          Column(
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
                    chordHighlightedNotes: _controller.combinedHighlightedNotes,
                    naturalColor: Colors.white,
                    accidentalColor: Colors.black,
                    keyWidth: keyWidth,
                    noteRange: _controller.noteRange,
                    onNotePositionTapped: _controller.pressNote,
                    onNotePositionReleased: _controller.releaseNote,
                  ),
                ),
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: TopMenuBar(
                  onChordSelected: _controller.onChordSelected,
                  onChordCleared: _controller.clearSelectedChord,
                  onScaleSelected: _controller.onScaleSelected,
                  onScaleCleared: _controller.clearSelectedScale,
                  deviceNames: _controller.connectedDeviceNames,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
