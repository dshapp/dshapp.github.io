---
title: "Computer use"
linkTitle: "Computer use"
description: "Understand any macOS interface through the accessibility tree and screenshots, then act with background keyboard and mouse input."
group: "cu"
weight: 40
---

Computer use (CU) lets the agent operate **apps that have no API** — if it has an interface, the agent can read it and click it.

## The tools

Computer use is exposed as `mcp__cu__*` tools. With KimiCU connected there are **11**.

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

## Controls, not coordinates

Targeting is based on the control itself, so moving a window or changing resolution does not break it. Indices come from the most recent `get_app_state` — which is why reading state comes before acting.

## Two kinds of eyes

| Means | Provides |
| --- | --- |
| Accessibility tree | control structure, roles and text |
| Screenshot | visual information the tree cannot express |

Together they give both "this is a button" and "here is what it currently looks like".

## Controls, not coordinates

Targeting is based on the control itself rather than hard-coded coordinates, so moving a window or changing resolution does not break it. That is far more robust than "click (120, 480)".

## Background input, no window stealing

Input is delivered in the background: **no window is pulled to the front and your pointer is never touched**. You can keep using the machine for something else.

## Permissions to grant

On first use, grant DSH both of these in System Settings → Privacy & Security:

- **Accessibility** (read the control tree, deliver input)
- **Screen Recording** (screenshots)

## Irreversible actions ask first

Sending, deleting, buying or publishing is explained before it happens.

## Next

- [Permissions](/en/docs/permissions/) — CU's capability boundary.
