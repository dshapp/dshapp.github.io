---
title: "Computer use"
linkTitle: "Computer use"
description: "Let DSH operate Mac apps that have no API: it understands the interface through the accessibility tree and screenshots, then acts with background keyboard and mouse input."
group: "cu"
platform: "macos"
weight: 40
---

Computer use (CU) lets DSH's agent operate **Mac apps that have no API** — if it has an interface, it can read it and click it. It has two parts:

| Component | Job |
| --- | --- |
| KimiCU.app | Does the actual work: reads the interface and delivers clicks and keystrokes in the background. Installed from Kimi's official channel |
| `dsh-kimi-computer-use` plugin | Connects KimiCU to DSH as `mcp__cu__*` tools, plus an operating skill |

DSH starts and stops KimiCU's MCP process with the plugin, but never downloads, installs or updates KimiCU.app itself.

## Turning it on

1. Install KimiCU.app from **Kimi's official channel** and keep it running.
2. In System Settings → Privacy & Security, grant **KimiCU.app** (not DSH):
   - **Accessibility** (read the interface structure, deliver input)
   - **Screen Recording** (screenshots)
3. Install the plugin, either way:
   - Mac app: open **Settings → Computer use** and install in one click. The tab also shows whether KimiCU is installed or has an update, plus both permissions, and links to System Settings.
   - Command line: `dsh plugin --profile web add dsh-kimi-computer-use`, then restart the dsh service.
4. Back in DSH, ask it to "do X in app Y."

You can revoke the permissions in System Settings at any time. KimiCU updates itself with its own updater, which verifies the signature and Apple notarization before replacing anything.

## The tools

Once enabled, the agent gets these **11** `mcp__cu__*` tools.

| Tool | What it does |
| --- | --- |
| `list_apps` | list running apps (name, bundle id, pid) |
| `get_app_state` | screenshot and/or accessibility tree; returns indexed nodes |
| `click` | click by node index or screenshot coordinate; never moves the real pointer |
| `drag` | drag from one point to another |
| `drag_paths` | post many mouse paths in one call, for drawing and gestures |
| `scroll` | scroll by page or line, or scroll to a given node |
| `type_text` | type Unicode text, optionally clearing first, optionally submitting |
| `set_value` | set a control's value (native via AXValue, web via background replacement) |
| `press_key` | press a key or chord (written like `cmd+a`, `return`) |
| `select_text` | select text in a text element, or place the cursor |
| `perform_secondary_action` | perform an element's secondary AX action, such as showing its menu |

## Two kinds of eyes

| Means | Provides |
| --- | --- |
| Accessibility tree | control structure, roles and text |
| Screenshot | visual information the tree cannot express |

Together they give both "this is a button" and "here is what it currently looks like".

## Controls, not coordinates

Targeting is based on the control itself rather than hard-coded coordinates, so moving a window or changing resolution does not break it — far more robust than "click (120, 480)". Indices come from the most recent `get_app_state`, which is why it always reads state before acting.

## Background input, no window stealing

Input is delivered in the background: **no window is pulled to the front and your pointer is never touched**. You can keep using the machine for something else.

## Irreversible actions ask first

Sending, deleting, buying or publishing is explained before it happens.

## Next

- [Permissions](/en/docs/permissions/) — CU's capability boundary.
