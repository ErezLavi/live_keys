import 'package:flutter/material.dart';
import 'package:piano_app/common/constants.dart';

typedef OnChordSelected = void Function(int rootPc, String chordType);
typedef OnChordCleared = void Function();

class ChordsGrid extends StatefulWidget {
  final OnChordSelected? onChordSelected;
  final OnChordCleared? onChordCleared;
  final int initialRootPc;
  final String initialChordType;

  const ChordsGrid({
    super.key,
    this.onChordSelected,
    this.onChordCleared,
    this.initialRootPc = 0,
    this.initialChordType = '',
  });

  @override
  State<ChordsGrid> createState() => _ChordsGridState();
}

class _ChordsGridState extends State<ChordsGrid> {
  late int _rootPc;
  late String _chordType;

  @override
  void initState() {
    super.initState();
    _rootPc = widget.initialRootPc;
    _chordType = widget.initialChordType;
  }

  @override
  Widget build(BuildContext context) {
    final rootNames =
        List<int>.generate(12, (index) => index).map(Constants.noteName).toList();
    final chordTypes = Constants.chordDB.keys
        .where((type) => (Constants.chordRank[type] ?? 999) <= 27)
        .toList();

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 8),
              Row(
                children: [
                  Spacer(),
                  TextButton(
                    onPressed: widget.onChordCleared,
                    child: const Text('Clear'),
                  ),
                ],
              ),
              Text(
                'Root',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(rootNames.length, (index) {
                  final selected = _rootPc == index;
                  return ChoiceChip(
                    label: Text(rootNames[index]),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => _selectRoot(index),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Type',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: chordTypes.map((type) {
                  final selected = _chordType == type;
                  return ChoiceChip(
                    label: Text(_labelForChordType(type)),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => _selectType(type),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectRoot(int rootPc) {
    setState(() {
      _rootPc = rootPc;
    });
    widget.onChordSelected?.call(_rootPc, _chordType);
  }

  void _selectType(String chordType) {
    setState(() {
      _chordType = chordType;
    });
    widget.onChordSelected?.call(_rootPc, _chordType);
  }

  String _labelForChordType(String type) {
    if (type.isEmpty) return 'Maj';
    if (type == 'm') return 'Min';
    if (type == 'm7b5') return 'm7b5';
    return type;
  }
}
