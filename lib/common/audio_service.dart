import 'package:flutter_midi_pro/flutter_midi_pro.dart';

class AudioService {
  AudioService({MidiPro? midi}) : _midi = midi ?? MidiPro();

  final MidiPro _midi;
  int? _sfId;

  Future<void> loadSoundFont({
    required String assetPath,
    int bank = 0,
    int program = 0,
    int channel = 0,
  }) async {
    _sfId = await _midi.loadSoundfontAsset(
      assetPath: assetPath,
      bank: bank,
      program: program,
    );

    await _midi.selectInstrument(
      sfId: _sfId!,
      channel: channel,
      bank: bank,
      program: program,
    );
  }

  void playNote({
    required int key,
    int velocity = 100,
    int channel = 0,
  }) {
    final sfId = _sfId;
    if (sfId == null) return;
    _midi.playNote(
      channel: channel,
      key: key,
      velocity: velocity,
      sfId: sfId,
    );
  }

  void stopNote({
    required int key,
    int channel = 0,
  }) {
    final sfId = _sfId;
    if (sfId == null) return;
    _midi.stopNote(
      channel: channel,
      key: key,
      sfId: sfId,
    );
  }
}
