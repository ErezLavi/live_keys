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
        final scaledRootSize = (constraints.maxWidth * 0.2).clamp(48.0, 140.0);
        final scaledSuffixSize = (constraints.maxWidth * 0.18).clamp(36.0, 120.0);
        
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