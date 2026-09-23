---
title: "Troubleshooting"
linkTitle: "Troubleshooting"
description: "Common failures around installation, connections, pairing and permissions, and how to diagnose them."
group: "reference"
weight: 61
---

## The macOS app will not open

**Blocked by Gatekeeper**: go to System Settings → Privacy & Security and choose Open Anyway next to the block notice.

**Check the architecture**: the client is a native Apple Silicon (arm64) build and needs macOS 14+.

## The Chrome extension says it is not connected

1. Confirm the macOS client is running (the service lives with the app).
2. Confirm DSH has the [dsh-chrome-control](https://github.com/dshapp/dsh-chrome-control) plugin installed (`dsh plugin --profile web add dsh-chrome-control`, then restart `dsh web`). Without it the server has no `/chrome/ws` for the extension to connect to.
3. Check the service address entered in the extension popup.
4. The popup shows the WebSocket state — read the actual error there.

## The phone will not connect after scanning

| Symptom | Check |
| --- | --- |
| Nothing happens on scan | the QR code expires after five minutes — mint a new one |
| Pairing fails | phone and Mac must be on the same version; the token is single-use |
| It used to work | the device may have expired (180 days by default) — pair again |

## Computer use cannot hit a control

In System Settings → Privacy & Security, confirm **both** Accessibility and Screen Recording are granted. Without either one you either cannot read the control tree or cannot take screenshots.

## Permission denied

**Deny is the default**. If a feature is not in the allowlist, check [Permissions](/en/docs/permissions/) to see whether it is an allowed route, rather than retrying.

## Still stuck

- [FAQ](/en/docs/faq/)
- [Open source and audit](/en/opensource/) — check the repositories before filing an issue.
