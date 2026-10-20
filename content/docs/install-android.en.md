---
title: "Install the Android app"
linkTitle: "Install the Android app"
description: "Install the DSH Android app, scan to connect to your Mac, and check progress, approve steps and add requests from your phone."
group: "start"
platform: "android"
weight: 4
---

The Android app is the phone client for DSH on your computer: you see the same sessions on your phone, while tasks keep running on the computer. It connects through the `dsh-mobile-bridge` plugin, with no open ports on your computer.

## Requirements

| Item | Requirement |
| --- | --- |
| OS | Android 8.0 or later |
| Camera | To scan the pairing QR code |
| Storage | About 40 MB |
| Computer | dsh running with the `dsh-mobile-bridge` plugin (built into the Mac app) |

## Install

1. Open the [download page](/en/download/#android) in your phone's browser and download the `.apk` (or download on your computer and copy it over).
2. When prompted, allow your browser or file manager to install unknown apps.
3. If a locally built debug version is installed, its signature differs — uninstall it first.

## Connect to your computer

1. Open the pairing page: click **Mobile access** in the Mac app sidebar; without the Mac app, run `dsh plugin --profile web add dsh-mobile-bridge`, then open `/mobileaccess` in dsh web.
2. Open the Android app and scan it.
3. Your phone is now a trusted device for that computer and connects straight away next time — no codes to type.

QR codes are valid for 5 minutes and work once; just make a new one if it expires.

## Once connected

Phone and Mac talk over an end-to-end encrypted channel; the relay can't read anything. Your phone shows the **same sessions** and files — not a separate cloud copy.

## Next

- [Pairing and devices](/en/docs/pairing/) — expiry, presence and revocation.
- [Encryption and the security model](/en/docs/crypto/) — why this channel is safe.
- On an iPhone, or rather not install an app? Try the [WeChat mini program DSH Remote](/en/docs/install-miniapp/).
