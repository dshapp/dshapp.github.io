---
title: "Computer use"
linkTitle: "Computer use"
tagline: "Let DSH operate Mac apps that have no API — in the background, without taking your mouse"
description: "The dsh-kimi-computer-use plugin connects Kimi Computer Use to DSH as 11 mcp__cu__* tools: the agent understands Mac app interfaces through the accessibility tree and screenshots, then clicks, types and drags in the background, asking before irreversible actions."
icon: "cu"
badge: "Plugin"
weight: 30
repo: "https://github.com/dshapp/dsh-kimi-computer-use"
shot: "/img/shots/cu.jpg"
shotAlt: "DSH creating a Reminders list and adding to-dos through computer use"
features:
  - title: "Reaches desktop apps"
    body: "Mac apps with no API and no CLI become something the agent can read and operate."
  - title: "Leaves your mouse alone"
    body: "Input is delivered in the background without moving your pointer, even to covered windows, so you keep working."
  - title: "Checks every step"
    body: "A bundled skill re-reads the interface before and after each action and confirms the result before moving on."
  - title: "Asks before risky actions"
    body: "Before sending, deleting, purchasing or publishing, it explains what will happen and waits for your OK."
related:
  - path: "/products/chrome/"
    title: "Chrome extension & browser control"
    body: "Web work goes to browser control; desktop apps go to computer use."
  - path: "/products/macos/"
    title: "macOS app"
    body: "Settings → Computer use checks the plugin, KimiCU and permissions."
---

## The problem it solves

DSH is great with files, commands and web pages, but a lot of work happens in desktop apps with **no API and no command line** — Keynote, System Settings, Notes, assorted internal clients. And classic GUI automation takes over your mouse and front window, so you can't do anything while it runs.

## What it's made of

| Component | Job | Get it |
| --- | --- | --- |
| KimiCU.app | Does the actual work: reads the interface and delivers clicks and keystrokes in the background | Kimi's official channel |
| dsh-kimi-computer-use plugin | Connects KimiCU to DSH as 11 `mcp__cu__*` tools, plus an operating skill | `dsh plugin --profile web add dsh-kimi-computer-use` |

The plugin only connects: DSH starts and stops KimiCU's MCP process with the plugin, but never downloads, installs or updates KimiCU.app itself.

## What it can do for you

- "Left-align the four text boxes on slide 3 in Keynote."
- "Rename this Mac to Design-Mac in System Settings."
- "Copy this week's to-dos from Notes into Reminders."
- "This internal client has no export — copy its list into a spreadsheet."

## Two kinds of "eyes"

- **Accessibility tree**: windows, buttons, text and hierarchy. Precise and addressable — it knows what an element *is*.
- **Screenshots**: fill in what the tree can't describe, such as canvases, charts and custom-drawn UI.

Targeting is based on controls rather than coordinates, so moved windows and new resolutions don't throw it off; coordinates are still available for canvas-style interfaces.

## Stays out of your way

- **Doesn't move your pointer** — keep using your Mac normally.
- **Doesn't pull windows to the front** — even fully covered windows receive input.
- Only the rare app that truly needs foreground input is brought forward briefly.

## Setup

1. Install KimiCU.app from **Kimi's official channel** and keep it running.
2. In System Settings → Privacy & Security, grant **KimiCU.app** (not DSH) Accessibility and Screen Recording.
3. Install the plugin: with the Mac app, use Settings → Computer use, which also checks KimiCU and its permissions; from the command line, run `dsh plugin --profile web add dsh-kimi-computer-use` and restart the dsh service.
4. Back in DSH, ask it to "do X in app Y."

Details: [Computer use docs](/en/docs/computer-use/).

## Requirements

| Item | Requirement |
| --- | --- |
| System | macOS |
| Dependency | KimiCU.app installed and running |
| DSH | `@deepseek-ai/dsh` 0.1.1-rc.2 or later |
