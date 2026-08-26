# BetterHA — Handoff

Custom native iOS (SwiftUI) app that replaces the stock Home Assistant companion
app with a 4-tab WKWebView shell + Settings screen. Requirements interview is
**closed** — no open product questions. All Swift source and test files are
written, `xcodegen generate` has been run, and the project **builds and passes
all 17 unit tests** (`xcodebuild build` / `test`, iPhone 17 Simulator, iOS
26.5 runtime). Manually verified in the Simulator: 5-tab layout, unconfigured
placeholder, Settings list, tab config editor with live URL-formatting
preview, and the connect → timeout → "Can't connect" + Retry flow.

Not a git repo yet — consider initializing one now that the scaffold is
verified.

## Locked requirements (from user, not to be re-litigated)

1. WKWebView browser view displays the HA web UI.
2. 4 tabs, each pointing at a different HA instance/location.
3. Settings screen: set an IP + custom name per tab. App auto-prepends
   `http://` and auto-appends `:8123` to the address (exact locked behavior).

## Spec from requirements interview (all approved via "go ahead")

- Per tab: **local address** + optional **remote address**. Same
  http:// + :8123 auto-formatting applies to both fields.
- Auth: plain HA frontend login inside WKWebView, relying on the default
  persistent `WKWebsiteDataStore.default()` (cookies/localStorage persist like
  Safari). No app-level token handling.
- Connection resolution: try local URL first (~3s timeout via HEAD request),
  fall back to remote URL, else show a "can't connect" + Retry screen.
- Kiosk mode **out of scope** for v1 — HA's own sidebar/chrome shown as-is, no
  CSS/JS injection.
- All 4 WKWebViews stay alive concurrently (not destroyed/recreated on tab
  switch) to preserve scroll/page state.
- Standard bottom `TabView` (not the wireframe's top button row) — deliberate,
  confirmed divergence from the original wireframe image.
- Settings is a 5th bottom tab.
- App remembers the last active tab across launches (`@AppStorage`).
- All 4 tabs ship unconfigured by default: "Tap to configure in Settings"
  placeholder.
- Devices: iPhone + iPad, iOS 17+.
- Pull-to-refresh: in scope for v1. Face ID/Touch ID app lock: out of scope
  for v1.
- Testing: pure logic (URL formatting, connection resolution) always unit
  tested; UI/hardware-interfacing code only tested where practical (per
  user's global CLAUDE.md).

## Toolchain / environment

- xcodegen (`/opt/homebrew/bin/xcodegen`) scaffolds the Xcode project from
  `project.yml`.
- Xcode 26.6 (Build 17F113), Swift 6.3.3 installed. `SWIFT_VERSION: "5.0"` is
  deliberately pinned in `project.yml` to avoid Swift 6 strict-concurrency
  friction with WKWebView delegates / `ObservableObject`.
- Bundle ID: `com.marneweck.BetterHA` (inferred reverse-DNS placeholder —
  change once a code-signing team is set up).
- ATS: `NSAllowsArbitraryLoads: true` in Info.plist (local HA instances run
  on plain http://, IPs unknown at build time so can't scope via
  `NSExceptionDomains`).
- `NSLocalNetworkUsageDescription` added defensively to Info.plist.
- Not a git repo yet.

## File status

### Written to disk

- [project.yml](project.yml) — xcodegen project spec (targets: `BetterHA`
  app + `BetterHATests`).
- [BetterHA/Models/HAURLFormatter.swift](BetterHA/Models/HAURLFormatter.swift)
  — pure function implementing the locked http://+:8123 auto-formatting.
- [BetterHA/Models/ConnectionResolver.swift](BetterHA/Models/ConnectionResolver.swift)
  — `ConnectionTarget` enum (`.local`/`.remote`) + local-first/remote-fallback
  resolver, probe injected as a closure for testability.
- [BetterHA/Models/ConnectionProbe.swift](BetterHA/Models/ConnectionProbe.swift)
  — real networking probe (ephemeral `URLSession`, HEAD request, 200..<500
  treated as reachable) satisfying the resolver's probe closure type.
- [BetterHA/Models/TabConfig.swift](BetterHA/Models/TabConfig.swift) — per-tab
  `Codable, Identifiable, Equatable` model (`id`, `name`, `localAddress`,
  `remoteAddress`) with computed `isConfigured`, `displayName`, `localURL`,
  `remoteURL`.

Directory skeleton also exists: `BetterHA/App/`, `BetterHA/Store/`,
`BetterHA/Views/`, `BetterHA/Resources/Assets.xcassets/AppIcon.appiconset/`,
`BetterHA/Resources/Assets.xcassets/AccentColor.colorset/`, `BetterHATests/`.

### Done

All items from the original next-steps list are complete: `TabConfigStore`,
the full SwiftUI view layer, asset catalog `Contents.json` files, all three
test files, `xcodegen generate`, build, unit tests, and manual Simulator
verification.

### Possible next steps (no open requirements questions)

- Initialize git and make an initial commit.
- Set up a real code-signing team / bundle ID if this will run on a physical
  device (current bundle ID `com.marneweck.BetterHA` is a placeholder).
- Add an app icon (currently empty `AppIcon.appiconset`).
- Everything else in the locked spec is implemented; no further product
  decisions are pending.
