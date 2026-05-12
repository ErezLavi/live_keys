import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:piano_app/common/app_sizes.dart';
import 'package:piano_app/custom_piano/custom_interactive_piano.dart';
import 'package:piano_app/piano/piano_page_controller.dart';
import 'package:piano_app/piano/widgets/grand_stuff_viewer_widget.dart';
import 'package:piano_app/piano/widgets/chord_viewer.dart';
import 'package:piano_app/piano/widgets/octave_buttons_widget.dart';
import 'package:piano_app/menu/top_bar.dart';

class PianoPage extends StatefulWidget {
  const PianoPage({super.key, required this.controller});

  final PianoPageController controller;

  @override
  State<PianoPage> createState() => _PianoPageState();
}
//TODO: improve layout for tablet/mobile view
//TODO: fix #/b with regular on same note display
class _PianoPageState extends State<PianoPage> {
  late final PianoPageController _controller;
  bool get _showOctaveControls =>
    defaultTargetPlatform != TargetPlatform.android || _controller.connectedDeviceNames.isNotEmpty;

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
    final keyWidth = AppSizes.keyWidth(screenSize.width);
    final horizontalPadding = AppSizes.overlayHorizontalPadding(screenSize.width,);
    final verticalPadding = AppSizes.overlayVerticalPadding(screenSize.height);
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSizes.space16,
                    horizontal: AppSizes.space12,
                  ),
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
                    final isCompact = AppSizes.isCompactLayout(constraints);
                    final toggleTextSize = isCompact ? AppSizes.space16 : AppSizes.space20;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_showOctaveControls) ...[
                          OctaveButtonsWidget(
                            isCompact: isCompact,
                            keyboardOctave: _controller.keyboardOctave,
                            onIncrement: _controller.incrementOctave,
                            onDecrement: _controller.decrementOctave,
                          ),
                          isCompact ? AppSizes.space12.sbWidth : AppSizes.space36.sbWidth
                        ],
                        if (!isCompact) ... [
                          Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            child: ToggleButtons(
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                              isSelected: [
                                !_controller.useFlats,
                                _controller.useFlats,
                              ],
                              onPressed: (index) =>
                                  _controller.setUseFlats(index == 1),
                              children: [
                                Text(
                                  '#',
                                  style: TextStyle(
                                    fontSize: toggleTextSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'b',
                                  style: TextStyle(
                                    fontSize: toggleTextSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],  
                        isCompact ? AppSizes.space12.sbWidth : AppSizes.space36.sbWidth,
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
