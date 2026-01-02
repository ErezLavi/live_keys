import 'package:flutter/material.dart';

class ChordViewer extends StatelessWidget {
  const ChordViewer({
    super.key,
    required this.chord,
    required this.splitChordName,
    this.rootFontSize = 84,
    this.suffixFontSize = 72,
    this.fontWeight = FontWeight.bold,
  });

  final String chord;
  final (String, String) Function(String) splitChordName;
  final double rootFontSize;
  final double suffixFontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final (root, suffix) = splitChordName(chord);
    if (root.isEmpty && suffix.isEmpty) {
      return const Text('');
    }

    return Align(
      alignment: Alignment.center,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: root,
              style: TextStyle(
                fontSize: rootFontSize,
                fontWeight: fontWeight,
              ),
            ),
            TextSpan(
              text: suffix,
              style: TextStyle(
                fontSize: suffixFontSize,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
