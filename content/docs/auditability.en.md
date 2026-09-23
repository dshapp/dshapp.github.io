---
title: "Auditability"
linkTitle: "Auditability"
description: "Per-call trajectories, a published security review and readable protocol code — why this system can be checked."
group: "security"
weight: 51
---

A security claim you cannot check is just a slogan. DSH is auditable at three levels.

## 1. Every tool call is on the record

Each tool call leaves an expandable trajectory: **the command, the diff and the output** can all be read back. You do not have to trust "it is fixed" — you can look at what changed.

## 2. The protocol code is readable

Encryption and the relay are in the repositories: readable, self-hostable, buildable. The only public component of mobile access is `dsh-proxy`: a single-port Rust implementation with **no TLS, no certificate, no config file and no disk state**.

## 3. The security review is published

We ran a full **adversarial** review of our own remote-access path, and all eight findings are fixed and published:

- it includes reproducible attack scripts and measurements, not a paper exercise;
- every finding records its fix and the measurement afterwards;
- it also records what was verified *not* vulnerable, and states residual risk honestly.

The full report, the finding list and the repositories are on [open source and audit](/en/opensource/).

## Next

- [FAQ](/en/docs/faq/)
- [Troubleshooting](/en/docs/troubleshooting/)
