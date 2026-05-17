# Mac Fastmove

Mac Fastmove is a compact macOS menu bar utility for keyboard power users. It focuses on one polished idea: turning `Caps Lock` into a fast navigation layer for everyday cursor movement on macOS.

## What v1 includes

- A macOS 13+ menu bar app built with SwiftUI.
- A focused `Caps Navigation` preset:
  - single tap `Caps Lock` passes through to macOS for input-source switching
  - quick double tap toggles actual Caps Lock state
  - hold `Caps Lock` and use `W/A/S/D` as arrow keys
- Accessibility and Input Monitoring permission onboarding.
- Sparkle-ready direct-distribution scaffolding.
- DMG/notarization/appcast helper scripts.

## Current engineering notes

- The input engine uses `CGEventTap`, so remapping is global in the current build.
- Connected keyboards can be detected for diagnostics, but public v1 intentionally applies the preset globally instead of routing per device.
- Sparkle integration is wired in, but feed URL and public key are placeholders until you configure your release infrastructure.

## Local development

1. Generate the Xcode project:

```bash
./scripts/bootstrap.sh
```

2. Build the app:

```bash
./scripts/build-app.sh
```

3. Run tests:

```bash
xcodebuild \
  -project "Mac Fastmove.xcodeproj" \
  -scheme LayerKeys \
  -destination 'platform=macOS' \
  test
```

## Distribution setup checklist

- Replace `io.github.macfastmove.app` with your real bundle identifier.
- Update the placeholder repository URL in `LayerKeys/Sources/Support/Info.plist`.
- Set a real Sparkle feed URL and `SUPublicEDKey`.
- Sign the app with a Developer ID certificate.
- Notarize the release archive or DMG.
- Publish the Sparkle appcast and the direct-download DMG.

## License

MIT. See [LICENSE](LICENSE).
