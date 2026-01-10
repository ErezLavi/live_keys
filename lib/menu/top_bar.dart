import 'package:flutter/material.dart';
import 'package:piano_app/menu/chords_grid.dart';

class TopMenuBar extends StatelessWidget {
  final VoidCallback? onShowChordInversions;
  final VoidCallback? onShowScales;
  final VoidCallback? onKeyboardLayout;
  final VoidCallback? onColors;
  final OnChordSelected? onChordSelected;
  final VoidCallback? onChordCleared;

  const TopMenuBar({
    super.key,
    this.onShowChordInversions,
    this.onShowScales,
    this.onKeyboardLayout,
    this.onColors,
    this.onChordSelected,
    this.onChordCleared,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MenuAnchor(
              builder: (context, controller, _) {
                return IconButton(
                  icon: const Icon(Icons.music_note),
                  tooltip: 'Chords',
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
                ChordsGrid(onChordSelected: onChordSelected, onChordCleared: onChordCleared),
              ],
            ),
            const SizedBox(width: 4),
            MenuAnchor(
              builder: (context, controller, _) {
                return IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
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
  }
}
