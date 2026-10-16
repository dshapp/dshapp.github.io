---
title: "Chrome extension & browser control"
linkTitle: "Chrome extension"
tagline: "Give DSH your signed-in Chrome, and use DSH right from the browser side panel"
description: "The dsh-chrome-control plugin gives DSH's agent 27 browser tools, and the Chrome extension carries them out in your signed-in Chrome. The extension's side panel is a full DSH client, with element picking and page context."
icon: "chrome"
badge: "Extension + plugin"
weight: 20
repo: "https://github.com/dshapp/dsh-chrome-control"
shot: "/img/shots/chrome-picker.jpg"
shotAlt: "Picking an element on a page and annotating it"
shot2: "/img/shots/chrome-sidepanel.jpg"
shot2Alt: "The DSH client in Chrome's side panel"
features:
  - title: "Your logins"
    body: "The same profile, logins and open tabs — admin panels and internal tools just work, and cookies never leave the browser."
  - title: "Runs in the background"
    body: "Real clicks and keystrokes run in background tabs; it reuses pages you already have open and never closes your own tabs."
  - title: "Pick + annotate"
    body: "Pick an element on the page and jot down what you want — it lands in DSH's composer. Or bring the current page in as context."
  - title: "The side panel is a DSH client"
    body: "Sessions, Git branches and changes, plugin management, background tasks and subagents — without leaving the page."
related:
  - path: "/products/macos/"
    title: "macOS app"
    body: "Install and diagnose from Settings → Browser."
  - path: "/products/cu/"
    title: "Computer use"
    body: "Desktop apps outside the browser go to computer use."
---

## The problem it solves

- **The agent can't get past a login.** Admin panels, internal tools and sites with two-factor auth are out of DSH's reach by default.
- **A separate browser means signing in again.** Playwright-style setups launch a clean browser, so you log in to every site all over again.
- **"Which element do you mean?"** You end up taking screenshots, describing positions and copying selectors back into DSH.
- **Switching back and forth.** Reading a page and want to ask DSH? Switch windows, copy the URL, copy the content.

## Two parts

| Component | Job | Get it |
| --- | --- | --- |
| dsh-chrome-control plugin | Installed into dsh; publishes browser capabilities as `mcp__chrome__*` tools and starts a separate native background service | `dsh plugin --profile web add dsh-chrome-control` |
| Chrome extension (listed as "DeepSeek Harness APP") | Carries out actions in your Chrome and provides the DSH client in the side panel | [Chrome Web Store](https://chromewebstore.google.com/detail/deepseek-harness-app/kgjjicancjnedmappjhefngdjaommpop) |

Browser control needs both; the extension alone still works as a side-panel DSH client. With the Mac app, Settings → Browser installs the plugin and checks the extension in one click. See [Install the Chrome extension](/en/docs/install-chrome/).

## Browser control: the agent uses your Chrome

Once connected, the agent gets 27 `mcp__chrome__*` tools covering:

- **Navigation and tabs**: open any address (web pages, local files, `about:`, `data:` and more) and move between tabs.
- **Understanding pages**: accessibility snapshots, readable text, semantic element search.
- **Interaction**: click, fill, select, upload, hover, keyboard and mouse, scrolling, dialogs.
- **Inspection**: screenshots, PDF export, network requests and responses, script execution.

Details that matter day to day:

- **Doesn't interrupt you**: real mouse and keyboard input runs in background tabs, never stealing the page you're on.
- **Doesn't make a mess**: it reuses a page you already have open, and doesn't close your own tabs when it's done.
- **Shortcuts that work**: it picks ⌘ or Ctrl for the OS Chrome runs on; select-all, copy, paste and undo work in every kind of input and report honestly whether they took effect.
- **Big pages stay smooth**: a separate native service does the heavy lifting, so huge pages don't freeze DSH — on macOS, Linux and Windows.
- **The extension can wake dsh**: if dsh isn't running, the extension can start `dsh web`.

## The side panel: DSH inside your browser

The side panel is more than a remote — it's a full DSH client:

- Sessions and conversations, sorted by recency, status or by hand, with status lights.
- **Bring the current page**: flip the switch and your next message tells the agent which page you're looking at.
- **Git**: current branch and change count; switch or create branches, push and pull.
- **Plugins**: install, update and remove plugins; restart or update DSH in one click.
- **Background tasks and subagents**: view and stop them.

## Pick + annotate

1. Click "Pick element" in the side panel.
2. Hover over the page — candidates highlight as you go.
3. Click once and an annotation box opens right there; write what you want and submit, or move on to the next one.

The element joins the conversation as a key-value card, and the agent can click, fill or read it directly.

## Boundaries

- Cookies stay in your browser and are never uploaded.
- Only the extension itself can connect to the control channel; ordinary pages can't, even if they find the address.
- No telemetry; uploads only ever include local files you explicitly name.
- To keep the agent out of your browser, disable the extension in Chrome; removing the plugin from your profile turns browser tools off entirely.

Full tool list: [Browser tools](/en/docs/browser-tools/).
