---
title: "WeChat Mini Program"
linkTitle: "WeChat Mini Program"
tagline: "DSH Remote: scan once in WeChat and take over the DSH on your computer"
description: "DSH Remote is the WeChat mini program client for DSH: nothing to install, and it runs in WeChat on both iPhone and Android. It reaches your computer end-to-end encrypted through the dsh-mobile-bridge plugin, so you can follow progress, handle approvals and questions, and add instructions. No open ports."
icon: "wechat"
badge: "Plugin + mini program"
weight: 50
repo: "https://github.com/dshapp/dsh-mobile-bridge"
shot2: "/img/dsh-remote-qr.jpg"
shot2Qr: true
shot2Alt: "The DSH Remote mini program code: scan it with WeChat to open"
features:
  - title: "Nothing to install"
    body: "Scan the code or search for “DSH Remote” in WeChat. Works on iPhone and Android, with no installer and no “unknown sources” switch."
  - title: "Same pairing"
    body: "It scans the same pairing QR code as the Android app: Mobile access in the Mac app sidebar, or /mobileaccess in dsh web."
  - title: "End-to-end encrypted"
    body: "The mini program reaches the relay over WSS and runs a Noise_IK session with your computer inside it; the relay only unwraps frames and can't read them."
  - title: "Take it back any time"
    body: "Revoke the device on your computer and its live connections drop instantly, or cut off all phone access in one click."
related:
  - path: "/products/android/"
    title: "Android app"
    body: "Use the native app when you want system notifications and a background connection."
  - path: "/docs/install-miniapp/"
    title: "Set up the mini program"
    body: "Opening the mini program and pairing, step by step."
  - path: "/opensource/"
    title: "Open source & security"
    body: "How remote access is encrypted, and the security review results."
---

## The problem it solves

- **You're on an iPhone, or just don't want another app.** DSH's native phone client is Android only; the mini program opens straight inside WeChat on iPhone and Android.
- **Step away and the task stalls.** A long task needs one approval or one answer — open WeChat and handle it.
- **Remote access is fiddly and worrying.** No open ports, tunnels or VPN, and the connection is end-to-end encrypted.

## Open the mini program

Scan the mini program code on the right with WeChat, or search for **DSH Remote** in WeChat.

## What it's made of

| Component | Job | Get it |
| --- | --- | --- |
| dsh-mobile-bridge plugin | Installed into dsh; serves DSH to paired phones over an encrypted tunnel, with no open port, no state file and no extra process | `dsh plugin --profile web add dsh-mobile-bridge` |
| dsh-proxy relay | The only public component; forwards ciphertext by routing key | [GitHub](https://github.com/dshapp/dsh-proxy) |
| DSH Remote mini program | The DSH client inside WeChat | Scan the code or search “DSH Remote” in WeChat |

The plugin runs inside the dsh service, so **any computer running dsh web can use it** — not just the Mac app.

## What you can do in the mini program

It talks to **the same DSH on your computer** — the same sessions and files, not a cloud copy:

- Sessions grouped by workspace; pin, rename, fork, archive and restore.
- Follow the conversation, tool calls and each turn's changed files and diffs live.
- **Handle approvals and questions**, one question at a time, with custom answers.
- Start sessions, send messages and attachments, interject, view and stop background tasks.
- Manage automations and plugins (toggle, install, update), and adjust host settings and the model catalog.
- Pair several computers and switch between them in Settings.

## Connect in three steps

1. Install the plugin on your computer: the Mac app has it built in; from the command line run `dsh plugin --profile web add dsh-mobile-bridge`.
2. Open the pairing page: click **Mobile access** in the Mac app sidebar, or open `/mobileaccess` in dsh web.
3. Open DSH Remote and tap **Scan QR Code inside the mini program** (not WeChat's own Scan), confirm the computer name and connect.

Pairing codes last 5 minutes and work once; a paired phone doesn't need to re-pair for 180 days. Without a usable camera, choose **Paste pairing text** in the mini program and paste the text starting with `dshm://`.

## How it differs from the Android app

Both talk to the same plugin and the same sessions, with nearly the same features. The differences come from the WeChat mini program platform:

| | Android app | WeChat mini program |
| --- | --- | --- |
| Getting it | Download and install an .apk | Scan or search in WeChat, nothing to install |
| Phones | Android 8.0+ | WeChat on iPhone and Android |
| Task notifications | System push notifications | No system push; unread badges inside the mini program |
| Background connection | Stays connected while tasks run, even when locked | Disconnects in the background; reconnects and catches up when you return |
| Device private key | Android Keystore | WeChat local storage |
| External links | Opened in the system browser | Copy the link and open it yourself |
| Relay | Official relay or your own | Official relay only (mini program domain allowlist) |

## Security

- **End-to-end encryption**: the mini program connects to `wss://<relay>/tunnel`, and the WebSocket frames carry a Noise_IK session between your phone and your computer; the relay only unwraps frames and forwards bytes, without storing or logging them.
- **Least privilege**: phones reach only allowlisted endpoints; pairing and revoking can only be done on the computer.
- **Take it back any time**: revoke a device and its live connections drop immediately.

Technical details: [Encryption & security model](/en/docs/crypto/); the review: [Open source & security](/en/opensource/).

## Requirements

| Item | Requirement |
| --- | --- |
| Phone | WeChat on iPhone or Android; pairing by QR needs a camera (or paste the pairing text) |
| Computer | dsh web with the dsh-mobile-bridge plugin (macOS or Linux) |

[Set up the mini program](/en/docs/install-miniapp/) · [Pairing & devices](/en/docs/pairing/)
