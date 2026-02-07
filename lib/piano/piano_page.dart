import 'package:flutter/material.dart';
import 'package:piano_app/custom_piano/custom_interactive_piano.dart';
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
//TODO: refactoring - split controller into smaller controllers and this page to smaller widgets
//TODO: chord detection fixes
//TODO: games - play given chord/scale by its name/clef/sound.(3+)

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
    final horizontalPadding = (screenSize.width * 0.04).clamp(4.0, 32.0);
    final verticalPadding = (screenSize.height * 0.02).clamp(2.0, 16.0);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  child: Row(
                    children: [
                      GrandStaffViewerWidget(
                        pressedNotes: _controller.pressedNotes,
                        useAlternativeAccidentals: _controller.useFlats,
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
                    useAlternativeAccidentals: _controller.useFlats,
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 840 || constraints.maxHeight < 500;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                tooltip: 'Decrease Octave',
                                iconSize: isCompact ? 12 : 22,
                                padding: EdgeInsets.all(isCompact ? 1 : 12),
                                onPressed: _controller.decrementOctave,
                              ),
                              Text(
                                '${_controller.keyboardOctave}',
                                style: TextStyle(
                                  fontSize: isCompact ? 12 : 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                tooltip: 'Increase Octave',
                                iconSize: isCompact ? 12 : 22,
                                padding: EdgeInsets.all(isCompact ? 1 : 12),
                                onPressed: _controller.incrementOctave,
                              ),
                            ],
                          ),
                        ),
                        isCompact ? const SizedBox(width: 12) : const SizedBox(width: 36),
                        Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(12),
                          child: ToggleButtons(
                            borderRadius: BorderRadius.circular(12),
                            isSelected: [
                              !_controller.useFlats,
                              _controller.useFlats
                            ],
                            onPressed: (index) =>
                                _controller.setUseFlats(index == 1),
                            children: [
                              Text(
                                '#',
                                style: TextStyle(
                                  fontSize: isCompact ? 14 : 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'b',
                                style: TextStyle(
                                  fontSize: isCompact ? 14 : 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        isCompact
                            ? const SizedBox(width: 12)
                            : const SizedBox(width: 36),
                        TopMenuBar(
                          controller: _controller,
                          isCompact: isCompact,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
