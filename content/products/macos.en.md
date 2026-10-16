---
title: "macOS app"
linkTitle: "macOS app"
tagline: "DSH built natively for Mac users — system controls, full keyboard control and system notifications, like an app that came with your Mac"
description: "The native macOS client for DSH: built with SwiftUI and AppKit for Apple Silicon, in a download of about 14 MB. Menu bar, shortcuts, system notifications, Quick Look, Finder and a built-in terminal — plugged straight into your local dsh."
icon: "apple"
badge: "Mac native"
weight: 10
repo: "https://github.com/dshapp/dsh-macapp"
shot: "/img/shots/macos-app.jpg"
shotAlt: "The DSH macOS app main window"
shot2: "/img/shots/macos-shortcuts.jpg"
shot2Alt: "The shortcut panel in the DSH macOS app"
features:
  - title: "Native all the way down"
    body: "Built with SwiftUI and AppKit: sidebar, split views, lists and the composer are system controls, and scrolling, momentum and input methods behave like the system."
  - title: "Drive it from the keyboard"
    body: "Nearly everything is in the menu bar and common actions have shortcuts — switch models, adjust thinking effort, approve requests, interject."
  - title: "At home in macOS"
    body: "System notifications, Quick Look, Finder, drag-and-drop attachments, your editor of choice for the workspace, and a built-in terminal."
  - title: "Light and fast"
    body: "Built natively for Apple Silicon in about 14 MB; long streaming sessions stay smooth and steady."
related:
  - path: "/products/chrome/"
    title: "Chrome extension & browser control"
    body: "One click in Settings → Browser."
  - path: "/products/android/"
    title: "Remote access"
    body: "Pair from Mobile access in the sidebar."
---

## Why a native app

`dsh web` is a web page in a browser tab: it's buried among dozens of other tabs, has no menu bar, fights the browser for shortcuts, and never tells you when a task is done.

DSH for macOS takes a different approach — **not a wrapped web page, not a cross-platform framework**, but an app written from scratch for the Mac with SwiftUI and AppKit:

- **System controls**: the sidebar is a system split view, lists are system lists, the composer is a system text control. Habits you've built in other Mac apps just work.
- **System-grade feel**: scrolling and momentum match the system; the interface doesn't jump during streaming or multi-line input; input methods never send half-composed text.
- **Light**: built natively for Apple Silicon in about 14 MB, ready the moment you open it.

## Drive it from the keyboard

The menu bar is the map. Sessions, conversation, model, terminal, server — nearly every action is in a menu, with its shortcut shown:

- Switch models, raise or lower thinking effort, enter or leave Plan mode, set a goal.
- **Handle requests from the keyboard**: allow this request, deny it, or skip a question.
- Interject, stop generating, fork from the last message, copy the last reply.
- Expand or collapse all turns and step through trajectory entries.

| Action | Shortcut |
| --- | --- |
| Send / new line | ↩ / ⇧↩ |
| New session | ⌘N |
| Find in current view | ⌘F |
| Previous / next session | ⌥⌘← / ⌥⌘→ |
| Choose model / permission mode | ⇧⌘M / ⇧⌘P |
| Show / hide terminal | ⌘J |
| Open the web UI | ⇧⌘, |
| Shortcut panel | ⌘/ |

See [Shortcuts](/en/docs/shortcuts/) for the full list; the in-app panel (⌘/) is authoritative.

## At home in macOS

- **System notifications**: while you're busy elsewhere, macOS notifies you when a task finishes, fails, or needs your answer or approval; click to jump straight to that session.
- **Quick Look**: preview images and files from the conversation, just like in Finder.
- **Finder**: reveal deliverables in Finder in one click, or open the workspace there.
- **Your editor**: pick an app in Settings and the toolbar's Workspace button opens the session's folder with it.
- **Drag to attach**: drag files or images into the composer, or paste an image; files outside the workspace are really uploaded.
- **Built-in terminal**: ⌘J brings up a terminal panel with tabs, right below the conversation.
- **Follows your Mac**: light, dark or match the system, and it respects Reduce Motion.

## See every step

- **Changed-files card**: each turn ends with the files changed and lines added/removed; open any of them as a diff.
- **Turn rail**: jump between turns and page into earlier history; find has next / previous.
- **Trajectory inspector**: a timeline shows each step's timing and details, with zoom and drag-to-focus.
- **Session management**: pin, reorder by hand, group by workspace, archive and restore, export session logs.

## Plugs into your dsh, manages your extensions

It's not a separate DSH but **a native client of the same dsh service**:

1. On launch it probes port `3080`; if dsh is already running (say, `dsh web` in your terminal), it attaches.
2. If nothing is running, it starts and hosts your installed dsh; if there's no dsh at all, it installs Node.js and `@deepseek-ai/dsh` after asking you.
3. It tells you when a newer dsh is available.

Sessions, model config and plugins are fully shared with the web UI. Extensions are turned on here too:

| Where | What it does |
| --- | --- |
| Settings → Browser | Installs the browser control plugin, checks the Chrome extension, shows connection status and failure reasons |
| Settings → Computer use | Installs the computer-use plugin, checks KimiCU.app and its permissions, links to System Settings |
| Settings → Plugins | "Marketplace" and "Built-in" — enable, disable or remove plugins |
| Sidebar → Mobile access | Shows a pairing QR code so a phone can connect to this Mac |

## Requirements

| Item | Requirement |
| --- | --- |
| System | macOS 15 or later |
| Chip | Apple Silicon (M1 or later); Intel Macs aren't supported yet |
| DSH | An installed `@deepseek-ai/dsh`; the app installs it if missing |

[Download for macOS](/en/download/#mac) · [Install guide](/en/docs/install-macos/)
