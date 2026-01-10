import 'package:flutter/material.dart';
import 'package:piano_app/common/constants.dart';

typedef OnScaleSelected = void Function(int rootPc, String scaleType);
typedef OnScaleCleared = void Function();

class ScalesGrid extends StatefulWidget {
  final OnScaleSelected? onScaleSelected;
  final OnScaleCleared? onScaleCleared;
  final int initialRootPc;
  final String initialScaleType;

  const ScalesGrid({
    super.key,
    this.onScaleSelected,
    this.onScaleCleared,
    this.initialRootPc = 0,
    this.initialScaleType = 'major',
  });

  @override
  State<ScalesGrid> createState() => _ScalesGridState();
}

class _ScalesGridState extends State<ScalesGrid> {
  late int _rootPc;
  late String _scaleType;

  @override
  void initState() {
    super.initState();
    _rootPc = widget.initialRootPc;
    _scaleType = widget.initialScaleType;
  }

  @override
  Widget build(BuildContext context) {
    final rootNames =
        List<int>.generate(12, (index) => index).map(Constants.noteName).toList();
    final scaleTypes = Constants.scaleDB.keys.toList();

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 8),
              Row(
                children: [
                  Spacer(),
                  TextButton.icon(
                    onPressed: widget.onScaleCleared,
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
                    'Scale',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: scaleTypes.map((type) {
                  final selected = _scaleType == type;
                  return ChoiceChip(
                    label: Text(_labelForScaleType(type)),
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
    widget.onScaleSelected?.call(_rootPc, _scaleType);
  }

  void _selectType(String scaleType) {
    setState(() {
      _scaleType = scaleType;
    });
    widget.onScaleSelected?.call(_rootPc, _scaleType);
  }

  String _labelForScaleType(String type) {
    return type
        .split('_')
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
