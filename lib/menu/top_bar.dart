import 'package:flutter/material.dart';
import 'package:piano_app/menu/chords_grid.dart';
import 'package:piano_app/menu/scales_grid.dart';

class TopMenuBar extends StatelessWidget {
  final VoidCallback? onShowChordInversions;
  final VoidCallback? onShowScales;
  final VoidCallback? onKeyboardLayout;
  final VoidCallback? onColors;
  final OnChordSelected? onChordSelected;
  final VoidCallback? onChordCleared;
  final OnScaleSelected? onScaleSelected;
  final VoidCallback? onScaleCleared;

  const TopMenuBar({
    super.key,
    this.onShowChordInversions,
    this.onShowScales,
    this.onKeyboardLayout,
    this.onColors,
    this.onChordSelected,
    this.onChordCleared,
    this.onScaleSelected,
    this.onScaleCleared,
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
                      onChordSelected: onChordSelected,
                      onChordCleared: onChordCleared,
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
                      onScaleSelected: onScaleSelected,
                      onScaleCleared: onScaleCleared,
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
