import 'dart:math' as math;

import 'package:flutter/material.dart';

class ChordViewer extends StatelessWidget {
  const ChordViewer({
    super.key,
    required this.chord,
    required this.splitChordName,
    this.fontWeight = FontWeight.bold,
  });

  final String chord;
  final (String, String) Function(String) splitChordName;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final (root, suffix) = splitChordName(chord);
    if (root.isEmpty && suffix.isEmpty) {
      return const Text('');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizeBasis = math.min(
          constraints.maxWidth,
          constraints.maxHeight * 1.7,
        );
        final scaledRootSize = (sizeBasis * 0.25).clamp(48.0, 130.0);
        final scaledSuffixSize = (sizeBasis * 0.25).clamp(36.0, 115.0);

        return Align(
          alignment: Alignment.center,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: root,
                  style: TextStyle(
                    fontSize: scaledRootSize,
                    fontWeight: fontWeight,
                  ),
                ),
                TextSpan(
                  text: suffix,
                  style: TextStyle(
                    fontSize: scaledSuffixSize,
                    fontWeight: fontWeight,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
