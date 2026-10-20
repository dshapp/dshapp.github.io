---
title: "Troubleshooting"
linkTitle: "Troubleshooting"
description: "Common failures around installation, connections, pairing and permissions, and how to diagnose them."
group: "reference"
weight: 61
---

## The macOS app will not open

**"Can't verify the developer"**: this release isn't notarized by Apple yet. Control-click the app in Finder and choose Open, or choose Open Anyway in System Settings → Privacy & Security.

**Check your system and chip**: macOS 15 or later on Apple Silicon (M1 or later) is required; Intel Macs aren't supported yet.

## First launch is stuck preparing the runtime

The app needs network access to install Node.js and the DSH service. Make sure nodejs.org and npm are reachable, and finish Apple's installer (it asks for your login password) when it appears.

## The Chrome extension says it is not connected

1. Confirm the macOS app is running (the service lives with the app).
2. Open **Settings → Browser**: it checks whether the needed components are installed, shows the specific failure reason, and installs anything missing in one click.
3. Check the service address in the extension popup; the default is `http://127.0.0.1:3080`.
4. If you run DSH directly in a terminal, make sure the [dsh-chrome-control](https://github.com/dshapp/dsh-chrome-control) plugin is installed (`dsh plugin --profile web add dsh-chrome-control`, then restart `dsh web`).

## The phone will not connect after scanning

| Symptom | Check |
| --- | --- |
| Nothing happens on scan | the QR code expires after five minutes — mint a new one |
| Pairing fails | phone and Mac must be on the same version; the token is single-use |
| It used to work | the device may have expired (180 days by default) — pair again |

## The WeChat mini program will not connect

| Symptom | Check |
| --- | --- |
| WeChat's own Scan does nothing with the pairing code | scan inside the mini program: open DSH Remote and tap Scan QR Code |
| “That is not a DeepSeek Harness pairing code” | you scanned something other than the pairing page's code, or the pasted text is incomplete — mint a new code and retry |
| Camera unavailable | allow the camera for the mini program in WeChat settings, or tap Paste pairing text and paste the text starting with `dshm://` |
| “Connecting…” after switching back to WeChat | expected: the mini program doesn't stay connected in the background and reconnects and catches up when you return |
| Fails after changing the relay address | the mini program can only reach the official relay; use the Android app with a self-hosted relay |

## Computer use cannot hit a control

1. Make sure **KimiCU.app** is installed from Kimi's official channel and running; the agent also reminds you of this when the tools are unavailable.
2. Open **Settings → Computer use** and confirm **KimiCU.app** (not DSH) has both Accessibility and Screen Recording. Without either one it can't read the interface or can't take screenshots.
3. If you just installed the plugin, restart the dsh service for it to take effect.

## Permission denied

**Deny is the default**. If a feature is not in the allowlist, check [Permissions](/en/docs/permissions/) to see whether it is an allowed route, rather than retrying.

## Still stuck

- [FAQ](/en/docs/faq/)
- [Open source & security](/en/opensource/) — check the repositories before filing an issue.
