---
title: "Permissions"
linkTitle: "Permissions"
description: "The default-deny policy for phones and plugins, and what each client is allowed to do."
group: "security"
weight: 50
---

DSH's default posture is **deny**: anything not explicitly allowed is refused.

## Session permission modes

| Mode | Scope |
| --- | --- |
| Plan | read-only exploration, produce a plan |
| Read-only | read files, search, browse |
| Workspace write | edit files and run commands inside the workspace |
| Full access | step outside the workspace, broader system actions |

## Per-client boundaries

| Client | Can | Cannot |
| --- | --- | --- |
| Phone (paired) | the RPC channel and a short allowlist of routes | plugin routes are default-deny; pairing and revocation return 403 |
| Chrome extension | browse and control using the current profile | upload cookies |
| Computer use | read the accessibility tree, screenshot, deliver background input | act irreversibly without asking |

## Why plugin routes are denied by default

The mobile channel uses an **exact route allowlist** (such as `/api/file`, `/api/session/uploadFileBinary`, `/api/remote.mux`); any unlisted plugin route returns 404. This came out of an adversarial security review: a reachable device used to get the whole of `/api`, and now gets only what it needs.

## Next

- [Auditability](/en/docs/auditability/) — how to check what it did.
- [Encryption and the security model](/en/docs/crypto/) — the channel itself.
