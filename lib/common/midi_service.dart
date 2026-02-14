import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

class MidiService {
  MidiService({MidiCommand? midiCommand})
    : _midiCommand = midiCommand ?? MidiCommand();

  final MidiCommand _midiCommand;
  StreamSubscription<MidiPacket>? _midiDataSubscription;
  StreamSubscription<String>? _midiSetupSubscription;
  List<String> _connectedDeviceNames = [];

  void Function(int midiKey)? _onNoteOn;
  void Function(int midiKey)? _onNoteOff;
  VoidCallback? _onDeviceNamesChanged;

  List<String> get connectedDeviceNames => List.unmodifiable(_connectedDeviceNames);

  Future<void> startListening({
    required void Function(int midiKey) onNoteOn,
    required void Function(int midiKey) onNoteOff,
    VoidCallback? onDeviceNamesChanged,
  }) async {
    _onNoteOn = onNoteOn;
    _onNoteOff = onNoteOff;
    _onDeviceNamesChanged = onDeviceNamesChanged;

    _midiDataSubscription ??=
        _midiCommand.onMidiDataReceived?.listen(_handleMidiPacket);

    _midiSetupSubscription ??=
        _midiCommand.onMidiSetupChanged?.listen((_) => _connectToFirstDevice());

    await _connectToFirstDevice();
  }

  Future<void> _connectToFirstDevice() async {
    try {
      final devices = await _midiCommand.devices;
      if (devices == null) {
        _setConnectedDeviceNames(null);
        debugPrint('No MIDI devices detected');
        return;
      }

      MidiDevice? target;
      for (final device in devices) {
        if (device.connected) {
          target = device;
          break;
        }
        target ??= device;
      }

      if (target == null) {
        _setConnectedDeviceNames(devices);
        return;
      }

      if (!target.connected) {
        await _midiCommand.connectToDevice(target);
        debugPrint('Connected to MIDI device: ${target.name}');
      }
      _setConnectedDeviceNames(devices, ensureName: target.name);
    } catch (e) {
      debugPrint('Failed to connect to MIDI device: $e');
    }
  }

  void _setConnectedDeviceNames(
    List<MidiDevice>? devices, {
    String? ensureName,
  }) {
    final names = <String>[];
    if (devices != null) {
      for (final device in devices) {
        if (device.connected) {
          names.add(device.name);
        }
      }
    }
    if (ensureName != null && !names.contains(ensureName)) {
      names.add(ensureName);
    }
    if (!listEquals(_connectedDeviceNames, names)) {
      _connectedDeviceNames = names;
      _onDeviceNamesChanged?.call();
    }
  }

  void _handleMidiPacket(MidiPacket packet) {
    final data = packet.data;
    if (data.length < 3) return;
    debugPrint('MIDI data: ${data.join(', ')}');
    final status = data[0] & 0xF0;
    final key = data[1];
    final velocity = data[2];

    if (status == 0x90 && velocity > 0) {
      _onNoteOn?.call(key);
    } else if (status == 0x80 || (status == 0x90 && velocity == 0)) {
      _onNoteOff?.call(key);
    }
  }

  void dispose() {
    _midiDataSubscription?.cancel();
    _midiSetupSubscription?.cancel();
  }
}
