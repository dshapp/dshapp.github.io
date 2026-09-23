---
title: "DSH documentation"
linkTitle: "Documentation"
description: "Install, use and audit DSH: from your first client to handing the agent your browser and your phone."
group: "start"
weight: 1
---

DSH is **one** agent that runs on **your own** machine, and you reach it through native clients, a browser extension and your phone. This documentation is ordered as "get it running, then use it well, then understand why it is safe".

## Where to start

| Where you are | Start here |
| --- | --- |
| Nothing installed yet | [Install the macOS app](/en/docs/install-macos/) |
| Installed, unsure what to say | [Sessions and workspaces](/en/docs/sessions/) |
| Want the agent to drive a page | [Picking elements](/en/docs/element-picker/) |
| Want your phone to reach your Mac | [Pairing and devices](/en/docs/pairing/) |
| Care where the data goes | [Encryption and the security model](/en/docs/crypto/) |

## Four clients, one set of sessions

The macOS app, the Android app, the Chrome extension and computer use share the same sessions, models and tools. Start a session on your Mac and your phone continues it after a scan; ask something in the browser side panel and the full trajectory is there on the desktop.

## Three ground rules

- **Local first**: the DSH service runs on your machine, and session data does not leave it by default.
- **Default deny**: a phone or plugin reaches only what is explicitly allowed, and nothing else.
- **Always a way back**: anything irreversible — sending, deleting, buying, publishing — is explained before it happens.
