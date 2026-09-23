---
title: "Browser tools"
linkTitle: "Browser tools"
description: "The 27 browser tools the Chrome extension and control capability expose to the agent, grouped by capability."
group: "browser"
weight: 21
---


Browser control is exposed to the agent as `mcp__chrome__*` tools. Once the extension connects there are **27** of them, grouped by capability rather than being one unrestricted interface.

The tools are published by the DSH plugin [dsh-chrome-control](https://github.com/dshapp/dsh-chrome-control) and executed by the Chrome extension; they only appear once both are installed — see [Install the Chrome extension](/en/docs/install-chrome/).

## Sessions and tabs

| Tool | What it does |
| --- | --- |
| `find_tab` | re-select a tab by URL, or borrow the one the user is viewing |
| `list_tabs` | list every tab in this session's group with id, URL and title |
| `close_tab` | close the current tab |
| `close_session` | close the whole tab group (only when explicitly asked) |

## Navigation and reading

| Tool | What it does |
| --- | --- |
| `navigate` | open a URL |
| `get_text` | extract readable text, stripping nav, header, footer and scripts |
| `snapshot` | read the accessibility tree for interactive elements and `@e` refs |

## Targeting and interaction

| Tool | What it does |
| --- | --- |
| `find` | locate a control from a plain-language query, returning reusable refs |
| `click` | click an element; falls back to real input when a widget ignores synthetic events |
| `fill` | set an input, textarea or rich editor (clear, insert, then read back) |
| `select` | choose a dropdown option: native `<select>` or an ARIA combobox |
| `hover` | real pointer hover, firing hover-only menus and tooltips |
| `focus` | focus without clicking, so you can type next |
| `key_type` | type text with real key events and verify by reading back |
| `send_keys` | press one key or chord (such as `Control+A`, `Enter`) |
| `mouse_click` | trusted mouse click by element or viewport coordinate |
| `upload` | set local file paths on an upload control |

## Scrolling

| Tool | What it does |
| --- | --- |
| `scroll` | scroll the page or one scrollable element, reporting whether it moved |
| `scroll_into_view` | bring an element into view and return its geometry |

## Scripting and evidence

| Tool | What it does |
| --- | --- |
| `evaluate` | run JavaScript in the page and return a serializable result |
| `screenshot` | capture the viewport, or one element |
| `save_as_pdf` | render the page to a PDF file on disk |
| `network` | list recent requests for this tab (method, URL, status) |
| `network_detail` | full record of one request, with headers and optional body |
| `dialog` | answer alert / confirm / beforeunload / prompt |

## Waiting

| Tool | What it does |
| --- | --- |
| `wait` | sleep a fixed interval (capped at three seconds) |
| `wait_for_selector` | poll until an element is visible, or gone |

## It reuses your session

These tools run inside the Chrome you are **already signed in to**, so reaching authenticated sites needs no extra login. The trade-off is worth stating plainly: the agent can see what you can see in that browser.

## Next

- [Permissions](/en/docs/permissions/) — default-deny and the allowlist for plugin routes.
