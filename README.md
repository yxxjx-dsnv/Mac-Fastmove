# Mac Fastmove

Mac Fastmove is a compact macOS menu bar utility for keyboard power users. It follows the same broad product model as tools like Mac Mouse Fix: direct download distribution, a small one-time price, a short free trial, and a polished focused experience instead of a giant remapping toolbox.

## What v1 includes

- A macOS 13+ menu bar app built with SwiftUI.
- A focused `Caps Navigation` preset:
  - single tap `Caps Lock` passes through to macOS for input-source switching
  - quick double tap toggles actual Caps Lock state
  - hold `Caps Lock` and use `W/A/S/D` as arrow keys
- Accessibility and Input Monitoring permission onboarding.
- A 7-day local trial stored in Keychain and Application Support.
- Honest-user licensing with a local purchase token field.
- Sparkle-ready direct-distribution scaffolding.
- DMG/notarization/appcast helper scripts.

## Current engineering notes

- The input engine uses `CGEventTap`, so remapping is global in the current build.
- Connected keyboards are enumerated and persisted by `vendor_id/product_id`, but true per-device routing needs a lower-level event pipeline than `CGEventTap`.
- Sparkle integration is wired in, but feed URL and public key are placeholders until you configure your release infrastructure.
- Gumroad activation is intentionally lightweight. v1 validates token shape and stores it locally; it does not do strong server-backed verification.

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
- Update the placeholder URLs in `LayerKeys/Sources/Support/Info.plist`.
- Set a real Sparkle feed URL and `SUPublicEDKey`.
- Sign the app with a Developer ID certificate.
- Notarize the release archive or DMG.
- Publish the Sparkle appcast and the direct-download DMG.

## License

MIT. See [LICENSE](LICENSE).
