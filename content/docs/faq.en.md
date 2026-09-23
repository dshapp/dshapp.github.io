---
title: "FAQ"
linkTitle: "FAQ"
description: "Common questions about installing DSH, sessions, remote access and the security model."
group: "reference"
weight: 60
---

## Where is session data stored

The DSH service runs on your machine, and session data stays there by default. The phone and the browser are clients that **connect in** — not another cloud copy.

## Does the phone see the same sessions

Yes: the same sessions, the same files, the same workspace.

## Why is there a relay at all

Because your Mac is usually behind NAT and has no publicly reachable address. The relay's only job is to **move bytes by routing key**; it cannot read them, keeps nothing on disk and logs nothing.

## Can the relay see my data

No. Phone and Mac speak Noise end-to-end; the relay reads only the 37-byte cleartext header for routing and copies bytes after that.

## Can I run my own relay

Yes. The relay is a single-port Rust implementation and can point at your own infrastructure — no dependency on our hosting.

## What if I lose my phone

**Revoke** that device in the Mac's device list. Revocation drops its live connections immediately, rather than waiting for its next connection.

## Which permission mode should I use

Pick per task and take it back when done. Do not enable writes for read-only research; return the level to its default afterwards.

## Which models are supported

Chosen per session. Models differ in reasoning depth, speed and tool-calling ability.

## Still stuck

- [Troubleshooting](/en/docs/troubleshooting/) — cannot connect, service not running.
- [Open source and audit](/en/opensource/) — read the code.
