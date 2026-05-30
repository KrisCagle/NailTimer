# Manicure Masterpiece

A Flutter app for at-home nail technicians. Plan every set, time every step, and save every routine with photos.

Built with the spa aesthetic in mind: serif typography, cream and mauve palette, soft cards, light and dark modes.

## What it does

**Plan**
- 11 nail design types: solid, cat eye, matte and gloss, french tip, chrome powder, glitter, ombre, marble, polka dots, stripes, glazed donut
- All-same or per-nail mode (each nail can have its own design and color)
- Curated mood presets and a daily nail horoscope card
- 10-color base palette plus unlimited custom colors via hex picker
- Extract a color palette from any photo

**Time**
- Guided countdown that auto-builds based on the designs you pick
- Haptic feedback at every step transition
- Three-second countdown ticks before each step ends
- Screen stays awake during a session
- Reorder steps, add custom steps, edit times per step
- One-handed mode with big button and swipe gestures

**Save**
- Session history with optional photos, notes, and per-nail color memory
- Look book for inspiration images with notes and tags
- Save and re-load any design as a preset
- Share presets with friends via QR code
- Share beautiful 1080x1080 cards directly to Instagram and other apps

**Library**
- Product library for your gels, polishes, and chromes
- Barcode scanner to add new bottles
- Assign products to specific routine steps

**Try-on**
- Photo-based virtual try-on with per-nail transforms
- Map your hand by tapping each fingertip and dragging toward the nail base
- Slider controls for size and rotation per nail
- Save the composite to your look book

## Stack

- Flutter 3.38
- Plugins: shared_preferences, image_picker, mobile_scanner, qr_flutter, share_plus, palette_generator, flutter_colorpicker, wakelock_plus, google_fonts, package_info_plus
- Local-only storage via SharedPreferences and the device file system
- No backend, no accounts, no analytics

## Privacy

Everything stays on your device. The full policy is published at <https://kriscagle.github.io/NailTimer/> and shipped in-app under Settings, About, Privacy policy.

## Getting started

Clone the repo, install dependencies, and run on a connected device or emulator.

```bash
git clone https://github.com/KrisCagle/NailTimer.git
cd NailTimer
flutter pub get
flutter run
```

To build a release App Bundle for the Play Store:

```bash
flutter build appbundle --release
```

See `store/RELEASE.md` for the full keystore and signing setup.

## Project layout

```
lib/main.dart           App code (theme, models, pages, painters)
assets/                 Icons and splash images
android/                Android platform config
ios/                    iOS platform config
macos/ linux/ web/      Other platform targets
store/                  Play Store launch kit (listing, privacy.html, RELEASE.md, tester email)
test/                   Widget tests
```

## Status

Pre-release. Targeting Google Play Internal Testing first, then closed and open testing tracks.

Current version: see `pubspec.yaml`.
