---
title: "Encryption and the security model"
linkTitle: "Encryption and the security model"
description: "One Noise_IK handshake provides encryption, mutual authentication and replay protection, and the relay cannot read a byte."
group: "mobile"
weight: 31
---

Conventional designs separate encryption (TLS), authentication (a token) and replay protection (timestamps plus a dedup table). DSH folds them into **one** Noise_IK handshake.

## Three problems, one handshake

| Property | Provided by |
| --- | --- |
| Encrypted channel | Noise transport (ChaChaPoly) |
| The phone is authenticated | the device's static public key in the handshake — that key *is* the device id |
| The Mac is authenticated | the phone already knows the Mac's public key and verifies it |
| Forward secrecy | the ephemeral key of each handshake |
| Replay protection | the monotonic transport nonce |

The result: **no certificate, no CA, no domain dependency, no bearer token, and no time-window check.**

## The relay cannot read a byte

The only public component is a minimal relay:

1. Read the **37-byte** cleartext header at the start of each connection (magic + version + routing key).
2. Look up the Mac's long-lived connection by that key.
3. From then on, **copy bytes only** — never parse.

It does not decrypt, does not touch disk and does not log. The routing key is an identifier, not a secret — it is already in the pairing QR code.

## What a phone may reach

Once connected it reaches **only what it needs**: the RPC channel is open, plugin routes are default-deny, and only an explicit handful of routes are allowlisted. The pairing and revocation endpoints answer a phone with **403** — they belong to the Mac side only.

## Known residual risk

- The RPC channel is still a full RPC surface: a paired device is by design a full harness client, so narrowing is not elimination. Revoking a lost phone is the intended remedy, and it is now immediate.
- The relay and its clients must be **upgraded together**: releasing capacity depends on the bridge's timeout.
- The per-IP gateway cap dislikes shared egress: behind a large NAT you must raise it deliberately.

The full review is on [open source and audit](/en/opensource/).
