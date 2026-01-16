import 'package:flutter/material.dart';
import 'package:piano_app/menu/chords_grid.dart';
import 'package:piano_app/menu/scales_grid.dart';

class ChordMenuState {
  final OnChordSelected? onChordSelected;
  final VoidCallback? onChordCleared;
  final int initialRootPc;
  final String initialChordType;
  final int initialChordInversion;

  const ChordMenuState({
    this.onChordSelected,
    this.onChordCleared,
    this.initialRootPc = 0,
    this.initialChordType = '',
    this.initialChordInversion = 0,
  });
}

class ScaleMenuState {
  final OnScaleSelected? onScaleSelected;
  final VoidCallback? onScaleCleared;
  final int initialRootPc;
  final String initialScaleType;

  const ScaleMenuState({
    this.onScaleSelected,
    this.onScaleCleared,
    this.initialRootPc = 0,
    this.initialScaleType = 'major',
  });
}

class TopMenuBar extends StatelessWidget {
  final VoidCallback? onShowChordInversions;
  final VoidCallback? onShowScales;
  final VoidCallback? onKeyboardLayout;
  final VoidCallback? onColors;
  final ChordMenuState chordMenu;
  final ScaleMenuState scaleMenu;
  final List<String> deviceNames;
  final bool useFlats;

  const TopMenuBar({
    super.key,
    this.onShowChordInversions,
    this.onShowScales,
    this.onKeyboardLayout,
    this.onColors,
    this.chordMenu = const ChordMenuState(),
    this.scaleMenu = const ScaleMenuState(),
    required this.deviceNames,
    this.useFlats = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 840 || constraints.maxHeight < 500;
        final iconSize = isCompact ? 18.0 : 32.0;
        final iconPadding = EdgeInsets.all(isCompact ? 6 : 8);
        final buttonConstraints = BoxConstraints(
          minWidth: isCompact ? 36 : 48,
          minHeight: isCompact ? 36 : 48,
        );

        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: isCompact ? 2 : 4,
              runSpacing: isCompact ? 2 : 4,
              children: [
                MenuAnchor(
                  builder: (context, controller, _) {
                    return IconButton(
                      icon: const Icon(Icons.music_note),
                      tooltip: 'Chords',
                      iconSize: iconSize,
                      padding: iconPadding,
                      constraints: buttonConstraints,
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                    );
                  },
                  menuChildren: [
                    ChordsGrid(
                      onChordSelected: chordMenu.onChordSelected,
                      onChordCleared: chordMenu.onChordCleared,
                      initialRootPc: chordMenu.initialRootPc,
                      initialChordType: chordMenu.initialChordType,
                      initialInversion: chordMenu.initialChordInversion,
                      useFlats: useFlats,
                    ),
                  ],
                ),
                MenuAnchor(
                  builder: (context, controller, _) {
                    return IconButton(
                      icon: const Icon(Icons.piano),
                      tooltip: 'Scales',
                      iconSize: iconSize,
                      padding: iconPadding,
                      constraints: buttonConstraints,
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                    );
                  },
                  menuChildren: [
                    ScalesGrid(
                      onScaleSelected: scaleMenu.onScaleSelected,
                      onScaleCleared: scaleMenu.onScaleCleared,
                      initialRootPc: scaleMenu.initialRootPc,
                      initialScaleType: scaleMenu.initialScaleType,
                      useFlats: useFlats,
                    ),
                  ],
                ),
                MenuAnchor(
                  builder: (context, controller, _) {
                    return IconButton(
                      icon: const Icon(Icons.devices),
                      tooltip: 'Devices',
                      iconSize: iconSize,
                      padding: iconPadding,
                      constraints: buttonConstraints,
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                    );
                  },
                  menuChildren: [
                    for (final device in deviceNames)
                      MenuItemButton(
                        onPressed: () {},
                        child: Text(device),
                      ),
                  ],
                ),
                MenuAnchor(
                  builder: (context, controller, _) {
                    return IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                      iconSize: iconSize,
                      padding: iconPadding,
                      constraints: buttonConstraints,
                      onPressed: controller.open,
                    );
                  },
                  menuChildren: [
                    MenuItemButton(
                      onPressed: onKeyboardLayout,
                      child: const Text('Sound'),
                    ),
                    MenuItemButton(
                      onPressed: onColors,
                      child: const Text('Colors'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
