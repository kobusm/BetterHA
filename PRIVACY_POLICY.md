# Privacy Policy for BetterHA

**Effective date:** September 4, 2026

BetterHA ("the app") is a native iOS client for Home Assistant. This policy
explains what data the app handles and, just as importantly, what it doesn't.

## Summary

BetterHA does not collect, transmit, or sell any personal data. It has no
backend servers of its own, no analytics, no crash reporting, and no
advertising. The only network connections the app makes are the ones you
configure, directly to your own Home Assistant instance(s).

## What the app stores, and where

**Tab configuration.** The name, local address, and remote address you enter
for each of your four tabs are stored on-device using Apple's standard
`UserDefaults` storage, and also synced via Apple's iCloud Key-Value
storage so the same settings appear if you install BetterHA on another of
your own devices signed into the same iCloud account. This sync is handled
entirely by Apple's iCloud infrastructure under your own Apple ID — this
data is never sent to us or to any third party, and we have no access to
it. You can control iCloud sync for BetterHA (or disable it entirely) in
your device's iCloud settings.

**Home Assistant session data.** When you log into your Home Assistant
frontend inside the app, your session cookies and local storage are kept by
iOS's standard `WKWebsiteDataStore`, the same mechanism Safari uses. This
keeps you signed in between launches. That data is stored only on your
device and is only ever sent to the Home Assistant address you configured —
never to us.

## What the app sends over the network

BetterHA only communicates with the local and remote addresses you enter in
Settings. It does not talk to any BetterHA-operated server, because no such
server exists. We — the developer — never receive your Home Assistant
address, credentials, session data, or anything else from the app.

## Third parties

BetterHA does not integrate any third-party SDKs, analytics services, or
advertising networks. No data is shared with third parties because none is
collected in the first place.

## Children's privacy

BetterHA does not knowingly collect data from anyone, including children
under 13, because it does not collect data from anyone at all.

## Your Home Assistant instance

Anything you see or do inside the Home Assistant frontend loaded by the app
is governed by your own Home Assistant instance's configuration and
security — not by this app. BetterHA is simply a native window onto the web
interface you already run.

## Changes to this policy

If this policy changes, the updated version will be posted at this same
location with a revised effective date.

## Contact

Questions about this policy can be sent to: kobus@marneweck.com

---

*BetterHA is an independent app and is not affiliated with, endorsed by, or
sponsored by Home Assistant or Nabu Casa.*
