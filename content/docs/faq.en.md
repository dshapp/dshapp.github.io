---
title: "FAQ"
linkTitle: "FAQ"
description: "Common questions about installing the DSH extensions, how they relate to dsh, browser control, computer use and remote access."
group: "reference"
weight: 60
---

## Do I need DSH installed first

Not with the macOS app — it attaches to the dsh you already have, or installs Node.js and `@deepseek-ai/dsh` after asking you. If you install plugins from the command line, you need dsh first.

## Will it clash with the dsh web I'm already running

No. The Mac app probes port 3080 first and attaches to a running dsh instead of starting another. Sessions, model config and plugins are shared, and `⇧⌘,` opens the web UI.

## Can I use the extensions without the Mac app

Yes. Browser control (`dsh-chrome-control`) and remote access (`dsh-mobile-bridge`) are ordinary dsh plugins — install them with `dsh plugin --profile web add <plugin>`, including on Linux. Computer use needs macOS.

## Do the extensions cost anything

No. The plugins and relay are MIT-licensed open source. Model costs are whatever your DSH model provider charges.

## Intel Macs or Windows

The macOS app currently requires Apple Silicon (M1 or later) and macOS 15 or later. Browser control's background service ships for macOS, Linux and Windows. The phone app supports Android 8.0 and later.

## Will browser control mess with the Chrome I'm using

Cookies are never uploaded. The agent reuses pages you already have open, sends real input to background tabs, and doesn't close your own tabs when it's done. To keep it out of your browser, disable the extension in Chrome.

## Why does computer use need KimiCU.app

KimiCU.app does the actual interface work; the `dsh-kimi-computer-use` plugin only connects it to DSH. Accessibility and Screen Recording are granted to KimiCU.app, not to DSH.

## Does the phone see the same sessions

Yes. The phone talks to the same DSH on your computer: the same sessions, files and workspace.

## Why is there a relay at all

Because your computer is usually behind NAT, with no address a phone can reach directly. The relay's only job is to **move bytes by routing key**; it can't read them, keeps nothing on disk and logs nothing.

## Can the relay see my data

No. Phone and computer speak Noise end-to-end; the relay reads only the routing header at the start of a connection and forwards ciphertext after that.

## Can I run my own relay

Yes. The relay `dsh-proxy` is a single-port Rust implementation; point `dsh-mobile-bridge`'s config at your own address.

## What if I lose my phone

**Revoke** it in the device list on your computer. Revocation drops its live connections immediately rather than at its next connection. You can also cut the relay link in one click to pause all phone access.

## Still stuck

- [Troubleshooting](/en/docs/troubleshooting/) — the service won't start, an extension won't connect.
- [Open source & security](/en/opensource/) — the code and the security review.
