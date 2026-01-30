import 'package:flutter/material.dart';
import 'package:piano_app/menu/chords_grid.dart';
import 'package:piano_app/menu/scales_grid.dart';
import 'package:piano_app/piano/piano_page_controller.dart';

class TopMenuBar extends StatelessWidget {
  final PianoPageController controller;

  const TopMenuBar({
    super.key,
    required this.controller,
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
                    if (controller.connectedDeviceNames.isEmpty)
                      const MenuItemButton(
                        onPressed: null,
                        child: Text('No MIDI device connected'),
                      )
                    else
                      for (final device in controller.connectedDeviceNames)
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
                              const SizedBox(width: 6),
                              const Text('Choose Sound'),
                            ],
                          ),
                        );
                      },
                      menuChildren: [
                        for (final soundFont
                            in controller.availableSoundFonts)
                          MenuItemButton(
                            onPressed: () =>
                                controller.setSoundFont(soundFont),
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
                                const SizedBox(width: 8),
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
                            controller.isMuted
                                ? Icons.volume_off
                                : Icons.volume_up,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
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
      },
    );
  }
}
