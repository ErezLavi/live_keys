import 'package:flutter/material.dart';
import 'package:piano_app/common/app_sizes.dart';
import 'package:piano_app/menu/chords_grid.dart';
import 'package:piano_app/menu/scales_grid.dart';
import 'package:piano_app/piano/piano_page_controller.dart';

class TopMenuBar extends StatelessWidget {
  final PianoPageController controller;
  final bool isCompact;

  const TopMenuBar({
    super.key,
    required this.controller,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isCompact ? 20.0 : 32.0;
    final iconPadding = EdgeInsets.all(
      isCompact ? AppSizes.space2 : AppSizes.space8,
    );

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.space4),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: isCompact ? 1 : AppSizes.space4,
          runSpacing: isCompact ? 1 : AppSizes.space4,
          children: [
            MenuAnchor(
              builder: (context, controller, _) {
                return IconButton(
                  icon: const Icon(Icons.music_note),
                  tooltip: 'Chords',
                  iconSize: iconSize,
                  padding: iconPadding,
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
                  onChordSelected: controller.onChordSelected,
                  onChordCleared: controller.clearSelectedChord,
                  initialRootPc: controller.selectedChordRootPc,
                  initialChordType: controller.selectedChordType,
                  initialInversion: controller.selectedChordInversion,
                  useFlats: controller.useFlats,
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
                  onScaleSelected: controller.onScaleSelected,
                  onScaleCleared: controller.clearSelectedScale,
                  initialRootPc: controller.selectedScaleRootPc,
                  initialScaleType: controller.selectedScaleType,
                  useFlats: controller.useFlats,
                ),
              ],
            ),
            MenuAnchor(
              builder: (context, controller, _) {
                return IconButton(
                  icon: const Icon(Icons.devices),
                  tooltip: 'MIDI Devices',
                  iconSize: iconSize,
                  padding: iconPadding,
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
                if (controller.connectedDeviceNames.isEmpty)
                  const MenuItemButton(
                    onPressed: null,
                    child: Text('No MIDI device connected'),
                  )
                else
                  for (final device in controller.connectedDeviceNames)
                    MenuItemButton(onPressed: () {}, child: Text(device)),
              ],
            ),
            MenuAnchor(
              builder: (context, controller, _) {
                return IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                  iconSize: iconSize,
                  padding: iconPadding,
                  onPressed: controller.open,
                );
              },
              menuChildren: [
                MenuAnchor(
                  builder: (context, controller, _) {
                    return MenuItemButton(
                      closeOnActivate: false,
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chevron_left, size: 18),
                          AppSizes.space6.sbWidth,
                          const Text('Choose Sound'),
                        ],
                      ),
                    );
                  },
                  menuChildren: [
                    for (final soundFont in controller.availableSoundFonts)
                      MenuItemButton(
                        onPressed: () => controller.setSoundFont(soundFont),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              soundFont.assetPath ==
                                      controller.selectedSoundFont.assetPath
                                  ? Icons.check
                                  : null,
                              size: 18,
                            ),
                            AppSizes.space8.sbWidth,
                            Text(soundFont.name),
                          ],
                        ),
                      ),
                  ],
                ),
                MenuItemButton(
                  closeOnActivate: false,
                  onPressed: controller.toggleMuted,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.isMuted ? Icons.volume_off : Icons.volume_up,
                        size: 18,
                      ),
                      AppSizes.space8.sbWidth,
                      Text(controller.isMuted ? 'Unmute' : 'Mute'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
