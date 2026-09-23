---
title: "Pairing and devices"
linkTitle: "Pairing and devices"
description: "How a phone pairs, where the online status comes from, and how to revoke a device."
group: "mobile"
weight: 30
---

A phone does not "log in" — it establishes its own encrypted channel to this Mac.

## The pairing flow

1. On the Mac, tap Add device to mint a single-use pairing token (valid five minutes, only one outstanding).
2. The QR code carries the relay address, the Mac's public key and name, and the token.
3. The phone scans it, generates a key pair, connects over Noise_IK and sends the token in its first message.
4. The Mac verifies the token in constant time, consumes it, and adds the device's public key to the allowlist.
5. The token is discarded; an unpaired device fails during the handshake itself.

## Device management

- Each device carries an expiry, **180 days** by default.
- Presence is **observed**: the bridge counts the streams a phone actually holds, rather than trusting a "last seen" timestamp.
- Revoking a device also hangs up the connections it already has, effective immediately.

| Action | Result |
| --- | --- |
| View paired devices | name, expiry and live presence |
| Revoke a device | removed from the allowlist, live connections dropped |
| Token expires | invalid after five minutes; pair again |

## No open port

The Mac listens on **nothing**, writes no state file and starts no extra process. It lives and dies with the DSH service.

## Next

- [Encryption and the security model](/en/docs/crypto/) — why that channel cannot be read.
