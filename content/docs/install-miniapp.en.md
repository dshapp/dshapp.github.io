---
title: "Set up the WeChat mini program"
linkTitle: "Set up the WeChat mini program"
description: "Open DSH Remote in WeChat and scan to connect to your computer — works on iPhone and Android, with nothing to install."
group: "start"
platform: "miniapp"
weight: 5
---

DSH Remote is the WeChat mini program client for DSH: you see the same sessions as on your computer, while tasks keep running there. Like the Android app, it connects through the `dsh-mobile-bridge` plugin, with no open ports on your computer — and it's how iPhone users take over DSH remotely.

## Open the mini program

{{< miniapp-qr alt="DSH Remote mini program code" caption="Scan with WeChat, or search for “DSH Remote” in WeChat" >}}

There's nothing to install. Once opened, you'll find it under WeChat's recently used mini programs, and you can add it to My Mini Programs.

## Requirements

| Item | Requirement |
| --- | --- |
| Phone | WeChat on iPhone or Android |
| Camera | To scan the pairing QR code; without one, paste the pairing text instead |
| Computer | dsh running with the `dsh-mobile-bridge` plugin (built into the Mac app) |

## Connect to your computer

1. Open the pairing page: click **Mobile access** in the Mac app sidebar; without the Mac app, run `dsh plugin --profile web add dsh-mobile-bridge`, then open `/mobileaccess` in dsh web.
2. Open DSH Remote. The first time, it shows **Pair with your Desktop**; tap **Scan QR Code** and scan the code on the pairing page.
3. Confirm the computer name (it defaults to the name the computer reports and is only shown on this phone), then tap **Connect**.
4. Your phone is now a trusted device for that computer and connects straight away next time.

QR codes are valid for 5 minutes and work once; just make a new one if it expires.

> Scan the pairing code **inside the mini program**. WeChat's own Scan won't open the mini program from a pairing code.

**No usable camera?** Tap **Paste pairing text** at the top right of the pairing screen and paste the text starting with `dshm://`.

## What you can do

The mini program talks to the same DSH on your computer, with nearly the same features as the Android app:

- Sessions grouped by workspace; pin, rename, fork, archive and restore from the long-press menu.
- Follow the conversation, tool calls and each turn's changed files and diffs live.
- Handle approvals and questions; start sessions, send messages and attachments, interject.
- View and stop background tasks; manage automations and plugins, adjust host settings.
- Pair several computers and switch between them in Settings.

## How it differs from the Android app

| | Android app | WeChat mini program |
| --- | --- | --- |
| Task notifications | System push notifications | No system push; unread badges inside the mini program |
| Background connection | Stays connected while tasks run | Disconnects in the background; reconnects and catches up when you return |
| Device private key | Android Keystore | WeChat local storage |
| External links | Opened in the system browser | Shows the full address and copies it on confirm |
| Relay | Official relay or your own | Official relay only (mini program domain allowlist) |

If you want to be notified the moment a task finishes, or you run your own relay, use the [Android app](/en/docs/install-android/).

## Next

- [Pairing and devices](/en/docs/pairing/) — expiry, presence and revocation.
- [Encryption and the security model](/en/docs/crypto/) — why the mini program's channel is safe.
