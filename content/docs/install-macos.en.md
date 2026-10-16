---
title: "Install the macOS app"
linkTitle: "Install the macOS app"
description: "Install the native macOS client for DSH: it attaches to the dsh already running on your Mac, or starts and installs one; then turn on extensions in Settings."
group: "start"
weight: 2
---

The macOS app is the native desktop client for DSH and the caretaker of your local dsh service. It's not a separate DSH: sessions, model config and plugins are the same as in `dsh web`.

## Requirements

| Item | Requirement |
| --- | --- |
| OS | macOS 15 or later |
| Chip | Apple Silicon (M1 or later); Intel Macs aren't supported yet |
| DSH | An installed `@deepseek-ai/dsh`; the app installs it if missing |

## Install

1. Get the `.dmg` (about 15 MB) from the [download page](/en/download/#mac).
2. Open the disk image and drag **DSH** into Applications.
3. The first time, macOS may say it can't verify the developer — this release isn't notarized by Apple yet. **Control-click the app in Finder and choose Open**, or click Open Anyway in System Settings → Privacy & Security. You only need to do this once.

## First launch: how it finds your DSH

| Your situation | What the app does |
| --- | --- |
| `dsh web` already running in a terminal (port 3080) | Attaches to it; no second service |
| dsh installed but not running | Starts the service with your installed dsh, tied to the app's lifetime |
| No dsh yet | Installs Node.js (from nodejs.org, via Apple's installer) and `@deepseek-ai/dsh` after asking you |

If your DSH has no model configured yet, the app walks you through adding an API key; if it does, you're ready to go. Later, the app tells you when a newer dsh is available.

## Turn on extensions

All one-click, in the app:

- **Settings → Browser**: install the browser control plugin and check the Chrome extension — see [Install the Chrome extension](/en/docs/install-chrome/).
- **Settings → Computer use**: install the computer-use plugin and check KimiCU.app and its permissions — see [Computer use](/en/docs/computer-use/).
- **Settings → Plugins**: enable, disable or remove plugins from the Marketplace and Built-in lists.
- **Sidebar → Mobile access**: show a pairing QR code — see [Install the Android app](/en/docs/install-android/).

## Back to the web

Press `⇧⌘,` to open dsh's web UI in your browser, already signed in. It's the same service; switch whenever you like.

## Updates

The app tells you when a new version is available, or download it any time from the [download page](/en/download/#mac) and replace the app. Sessions and settings are kept.

## Next

- [Keyboard shortcuts](/en/docs/shortcuts/) — almost everything is on the keyboard.
- [Troubleshooting](/en/docs/troubleshooting/) — when the service won't start or an extension won't connect.
