# CamCunt

> **Attribution:** This project is based on <a href="https://github.com/itaybre/CameraController">CameraController</a> by <a href="https://github.com/itaybre">@itaybre</a> (Itay Brenner). Forked, renamed, and extended by <a href="https://github.com/dweebzxx">@dweebzxx</a>.

Control your USB webcam settings — exposure, white balance, focus, zoom, crop, and more — without vendor software.

## Features

- Multi-camera detection and switching
- Live camera preview with real-time crop overlay
- Universal software crop (works with any camera — USB, built-in, virtual)
- Exposure control (manual/auto mode, exposure time, gain)
- Image adjustment (brightness, contrast, saturation, sharpness)
- White balance (auto/manual with temperature slider)
- Powerline frequency filtering (disabled/50Hz/60Hz/auto)
- Backlight compensation toggle
- Zoom control
- Pan & tilt control
- Focus control (auto/manual)
- Settings profiles (save, load, update, delete)
- Camera Default reset
- Per-device settings persistence
- Open at login
- Configurable periodic read/write polling
- Hot-plug camera detection
- Native Apple Silicon support
- macOS 12+ compatible

## System Requirements

- macOS 12 (Monterey) or later
- Apple Silicon (M1/M2/M3/M4) native support
- Intel Mac support
- Works with USB webcams that support <a href="https://www.usb.org/document-library/video-class-v15-document-set">UVC</a>
- Crop feature works with ALL cameras (USB, built-in, virtual)

## Installation

### From Source

Clone the repository and open `CamCunt.xcodeproj` in Xcode:
```sh
git clone https://github.com/dweebzxx/CamCunt.git
cd CamCunt
open CamCunt.xcodeproj
```

Build and run (⌘R).

### Requirements to Build

- Xcode 14+ (for macOS 12 deployment target)
- <a href="https://github.com/realm/SwiftLint">SwiftLint</a> (optional)

## Feature Details

### Crop (NEW)
Universal software crop that works with any camera. Located in the Advanced settings tab. Adjust top, bottom, left, and right insets. Crop settings persist per-camera and are included in saved profiles.

### UVC Controls
Exposure (manual/auto, time, gain), image (brightness, contrast, saturation, sharpness), white balance (auto/manual), powerline frequency, backlight compensation, zoom, pan, tilt, and focus (auto/manual).

### Profiles
Save, load, update, and delete named settings profiles. Apply "Camera Default" to reset to factory values.

## FAQ

- **Does it work with Apple's FaceTime camera?**
  On older Macs, yes. On Macs with T1/T2/Apple Silicon security chips, UVC controls are restricted by Apple. The crop feature will still work.

- **Does it work with virtual cameras (e.g., OBS)?**
  UVC controls will not work, but the crop feature will.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

**Note:** This project is a fork of the original CameraController by Itay Brenner. All modifications and extensions are also licensed under GPL v3.0.

## Contributors

- <a href="https://github.com/itaybre">@itaybre</a> — Original CameraController
- <a href="https://github.com/herrerajeff">@herrerajeff</a> — Icons
- <a href="https://github.com/dweebzxx">@dweebzxx</a> — Fork maintainer, crop feature, rebrand
