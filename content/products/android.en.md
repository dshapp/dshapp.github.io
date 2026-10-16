---
title: "Remote access"
linkTitle: "Remote access"
tagline: "The mobile-bridge plugin + Android app: take over DSH from your phone when you step away"
description: "The dsh-mobile-bridge plugin hands the DSH on your computer to paired phones over an end-to-end encrypted channel, and the Android app is DSH in your pocket: follow progress, handle approvals and questions, add instructions, get notified. No open ports."
icon: "android"
badge: "Plugin + client"
weight: 40
repo: "https://github.com/dshapp/dsh-mobile-bridge"
aliases:
  - /products/remote/
shot: "/img/shots/android-app.png"
shotPortrait: true
shotAlt: "The DSH Android app session list"
shot2: "/img/shots/remote-pairing.jpg"
shot2Alt: "The Mobile Access page next to a question card on the phone"
features:
  - title: "Tasks don't stall on approvals"
    body: "When the agent needs an approval or an answer, handle it on your phone; progress, completion and failures are pushed as notifications."
  - title: "No ports, no tunnels"
    body: "Your computer dials out to a public relay and your phone reaches it through that — no public IP, router setup or VPN."
  - title: "End-to-end encrypted"
    body: "One Noise handshake handles encryption and mutual authentication; the relay forwards ciphertext it can't read and stores nothing."
  - title: "Take it back any time"
    body: "Revoking a device drops its live connections instantly, or cut off all phone access in one click without unpairing."
related:
  - path: "/products/macos/"
    title: "macOS app"
    body: "Mobile access in the sidebar is where pairing starts."
  - path: "/opensource/"
    title: "Open source & security"
    body: "How remote access is encrypted, and the security review results."
---

## The problem it solves

- **Step away and the task stalls.** A long task needs one approval or one answer while you're in a meeting or on the road.
- **No idea whether it finished.** Done, failed or stuck — you only find out back at your desk.
- **Remote access is fiddly and worrying.** Reaching DSH on your home or office machine means opening ports, tunneling or a VPN.

## What it's made of

| Component | Job | Get it |
| --- | --- | --- |
| dsh-mobile-bridge plugin | Installed into dsh; serves DSH to paired phones over an encrypted tunnel, with no open port, no state file and no extra process | `dsh plugin --profile web add dsh-mobile-bridge` |
| dsh-proxy relay | The only public component; forwards ciphertext by routing key. The relay address is in the pairing QR code, and you can run your own | [GitHub](https://github.com/dshapp/dsh-proxy) |
| Android app | The DSH client on your phone | [Download](/en/download/#android) |

The plugin runs inside the dsh service, so **any computer running dsh web can use it** — not just the Mac app.

## What you can do from your phone

Your phone talks to **the same DSH on your computer** — the same sessions and files, not a cloud copy:

- Follow sessions, tool calls and each turn's changed files and diffs live.
- **Handle approvals and questions**, one question at a time, with custom answers.
- Start sessions, send messages and attachments, interject, edit queued messages, stop background tasks.
- Get progress notifications; the app stays connected in the background while tasks run, even with the screen locked.
- Pair several computers and switch between them; search within a session, preview files and images, archive sessions.

## Connect in three steps

1. Install the plugin on your computer: the Mac app has it built in; from the command line run `dsh plugin --profile web add dsh-mobile-bridge`.
2. Open the pairing page: click **Mobile access** in the Mac app sidebar, or open `/mobileaccess` in dsh web.
3. Scan the QR code with the Android app. Done.

Pairing codes last 5 minutes and work once, and a new code voids the old one; a paired phone doesn't need to re-pair for 180 days.

## Device management

- The device list shows whether each phone is online **right now** — observed from actual connections, not guessed.
- Rename phones to tell them apart.
- **Revoke** a phone and its live connections drop immediately.
- **Disconnect / resume** the relay link in one click to pause all phone access without unpairing.

## Security

- **End-to-end encryption**: one Noise_IK handshake handles encryption and mutual authentication; the relay reads only the routing header, then forwards ciphertext without storing or logging it.
- **Least privilege**: phones reach only allowlisted endpoints; pairing and revoking can only be done on the computer.
- **Weak-network friendly**: all requests share one long-lived, compressed connection, and retries after a reconnect are never executed twice.

Technical details: [Encryption & security model](/en/docs/crypto/); the review: [Open source & security](/en/opensource/).

## Requirements

| Item | Requirement |
| --- | --- |
| Phone | Android 8.0 or later, with a camera |
| Computer | dsh web with the dsh-mobile-bridge plugin (macOS or Linux) |

[Download for Android](/en/download/#android) · [Pairing & devices](/en/docs/pairing/)
