---
title: "Install the macOS app"
linkTitle: "Install the macOS app"
description: "Install the native DSH client on macOS 14+ and Apple Silicon, and start the DSH service locally."
group: "start"
weight: 2
---

The macOS client is where DSH lives: it is both the interface and the host of your local DSH service.

## Requirements

| Item | Requirement |
| --- | --- |
| OS | macOS 14 (Sonoma) or later |
| Chip | Apple Silicon (native arm64 build) |
| Disk | about 120 MB |

## Install

1. Get the `.dmg` from the [download page](/en/download/#mac).
2. Open the disk image and drag **DSH** into Applications.
3. If Gatekeeper blocks the first launch, go to System Settings → Privacy & Security and choose Open Anyway.
4. Follow the setup wizard; the service starts with the app.

## No service to start by hand

The macOS client launches and hosts the DSH service for you — **no terminal, no commands to run**. Closing the window is not quitting: the service lives and dies with the app.

## Next

- [Sessions and workspaces](/en/docs/sessions/) — sessions, workspaces, the composer.
- [Keyboard shortcuts](/en/docs/shortcuts/) — almost everything is on the keyboard.
