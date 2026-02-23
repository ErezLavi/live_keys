import 'package:flutter/material.dart';
import 'package:piano_app/common/app_sizes.dart';

class OctaveButtonsWidget extends StatelessWidget {
  const OctaveButtonsWidget({
    super.key,
    required this.isCompact,
    required this.keyboardOctave,
    required this.onIncrement,
    required this.onDecrement,
  });

  final bool isCompact;
  final int keyboardOctave;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final size = isCompact ? AppSizes.space12 : AppSizes.space22;
    final iconPadding = isCompact ? AppSizes.space2 : AppSizes.space12;

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            tooltip: 'Decrease Octave',
            iconSize: size,
            padding: EdgeInsets.all(iconPadding),
            onPressed: onDecrement,
          ),
          Text(
            '$keyboardOctave',
            style: TextStyle(fontSize: size, fontWeight: FontWeight.w700),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Increase Octave',
            iconSize: size,
            padding: EdgeInsets.all(iconPadding),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}
