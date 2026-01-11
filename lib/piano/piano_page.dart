import 'package:flutter/material.dart';
import 'package:piano_app/piano/custom_piano/custom_interactive_piano.dart';
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
//TODO: fork piano package and delete custom piano widgets
//TODO: add change octave buttons
//TODO: add b support based on the chord root
//TODO: settings widget - choose color and sf2's
//TODO: games - play given chord/scale/note by its name/clef/sound.(3+)

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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final keyWidth = (screenWidth / 20).clamp(24.0, 60.0);
    final horizontalPadding = (screenSize.width * 0.04).clamp(12.0, 32.0);
    final verticalPadding = (screenSize.height * 0.02).clamp(8.0, 16.0);

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
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: TopMenuBar(
                  chordMenu: ChordMenuState(
                    onChordSelected: _controller.onChordSelected,
                    onChordCleared: _controller.clearSelectedChord,
                    initialRootPc: _controller.selectedChordRootPc,
                    initialChordType: _controller.selectedChordType,
                    initialChordInversion: _controller.selectedChordInversion,
                  ),
                  scaleMenu: ScaleMenuState(
                    onScaleSelected: _controller.onScaleSelected,
                    onScaleCleared: _controller.clearSelectedScale,
                    initialRootPc: _controller.selectedScaleRootPc,
                    initialScaleType: _controller.selectedScaleType,
                  ),
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
