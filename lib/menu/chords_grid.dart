import 'package:flutter/material.dart';
import 'package:piano_app/common/constants.dart';

typedef OnChordSelected = void Function(
  int rootPc,
  String chordType,
  int inversion,
);
typedef OnChordCleared = void Function();

class ChordsGrid extends StatefulWidget {
  final OnChordSelected? onChordSelected;
  final OnChordCleared? onChordCleared;
  final int initialRootPc;
  final String initialChordType;
  final int initialInversion;
  final bool useFlats;

  const ChordsGrid({
    super.key,
    this.onChordSelected,
    this.onChordCleared,
    this.initialRootPc = 0,
    this.initialChordType = '',
    this.initialInversion = 0,
    this.useFlats = false,
  });

  @override
  State<ChordsGrid> createState() => _ChordsGridState();
}

class _ChordsGridState extends State<ChordsGrid> {
  late int _rootPc;
  late String _chordType;
  late int _inversion;

  @override
  void initState() {
    super.initState();
    _rootPc = widget.initialRootPc;
    _chordType = widget.initialChordType;
    _inversion = widget.initialInversion;
    _clampInversion();
  }

  @override
  void didUpdateWidget(covariant ChordsGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRootPc != widget.initialRootPc ||
        oldWidget.initialChordType != widget.initialChordType ||
        oldWidget.initialInversion != widget.initialInversion) {
      _rootPc = widget.initialRootPc;
      _chordType = widget.initialChordType;
      _inversion = widget.initialInversion;
      _clampInversion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rootNames = List<int>.generate(12, (index) => index)
        .map((pc) => Constants.noteName(pc, useFlats: widget.useFlats))
        .toList();
    final chordTypes = Constants.chordDB.keys
        .where((type) => (Constants.chordRank[type] ?? 999) <= 27)
        .toList();
    final maxInversion = _maxInversion();

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
                  TextButton.icon(
                    onPressed: _clearSelection,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
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
                    'Quality',
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
              const SizedBox(height: 12),
              Text(
                'Inversion',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(maxInversion + 1, (index) {
                  final label = index == 0 ? 'Root' : '$index';
                  final selected = _inversion == index;
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => _selectInversion(index),
                  );
                }),
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
    widget.onChordSelected?.call(_rootPc, _chordType, _inversion);
  }

  void _selectType(String chordType) {
    setState(() {
      _chordType = chordType;
      _clampInversion();
    });
    widget.onChordSelected?.call(_rootPc, _chordType, _inversion);
  }

  void _selectInversion(int inversion) {
    setState(() {
      _inversion = inversion;
    });
    widget.onChordSelected?.call(_rootPc, _chordType, _inversion);
  }

  void _clearSelection() {
    setState(() {
      _rootPc = 0;
      _chordType = '';
      _inversion = 0;
    });
    widget.onChordCleared?.call();
  }

  int _maxInversion() {
    final maxFromType = Constants.maxChordInversion(_chordType);
    return maxFromType.clamp(0, 3).toInt();
  }

  void _clampInversion() {
    final max = _maxInversion();
    if (_inversion > max) {
      _inversion = max;
    }
  }

  String _labelForChordType(String type) {
    if (type.isEmpty) return 'Maj';
    if (type == 'm') return 'Min';
    return type;
  }
}
