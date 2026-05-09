# Live Keys 🎹

Live Keys is a Flutter piano app with real time chord detection,
MIDI input support and a playable keyboard. Fully supported in MacOs, Windows and Android.

## Downloads

[![macOS](https://img.shields.io/badge/macOS-Download-black?logo=apple)](https://github.com/ErezLavi/live_keys/releases/latest)
[![Windows](https://img.shields.io/badge/Windows-Download-0078D6?logo=windows)](https://github.com/ErezLavi/live_keys/releases/latest)
[![Android](https://img.shields.io/badge/Android-Download-3DDC84?logo=android&logoColor=white)](https://github.com/ErezLavi/live_keys/releases/latest)


## Features

- Chord detection with a large chord name display
- Grand staff view of currently pressed notes
- Chord and scales highlighting from the top-right menu
- Hardware MIDI input (auto-connects to the first device found)
- SoundFont playback via bundled SF2 assets

## Controls

- Computer keyboard mapping:
  - `Z S X D C V G B H N J M , L . ; /`
  - `[` and `]` to shift the keyboard octave

## SoundFonts

The app ships with SF2 files in `assets/sf2`. The default soundfont is set in
`lib/common/constants.dart` (`rhodesSoundFontAsset`). Swap this to change the
instrument.

## Getting Started

1. Install Flutter (SDK 3.9+).
2. Clone the repository:
   ```bash
   git clone https://github.com/ErezLavi/live_keys.git
   cd piano_app
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```
