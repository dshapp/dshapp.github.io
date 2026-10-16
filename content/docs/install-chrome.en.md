---
title: "Install the Chrome extension"
linkTitle: "Install the Chrome extension"
description: "Let DSH work in your signed-in Chrome: install the components from the Mac app's Settings in one click, then add the extension from the Chrome Web Store."
group: "start"
weight: 4
---

Browser control lets DSH's agent use **the Chrome you already use** — the same logins and the same open tabs. It has two parts: the `dsh-chrome-control` plugin and the Chrome extension; the extension alone also works as a DSH client in the side panel.

## Requirements

| Item | Requirement |
| --- | --- |
| Browser | Chrome 120 or later |
| Mac | The [DSH macOS app](/en/docs/install-macos/) installed and running |

## Install (recommended)

1. In the Mac app, open **Settings → Browser**. It checks what browser control needs and installs anything missing in one click.
2. Open the [extension on the Chrome Web Store](https://chromewebstore.google.com/detail/deepseek-harness-app/kgjjicancjnedmappjhefngdjaommpop) (listed as "DeepSeek Harness APP") and click Add to Chrome.
3. Back in Settings → Browser, "Connected" means you're ready. If not, Settings shows the specific reason.
4. Pin the extension to the toolbar; open the side panel to chat with it right inside Chrome.

The extension connects to the local DSH service (`http://127.0.0.1:3080`) by default — usually nothing to change.

## Not using the Mac app? Install from the command line

If you run DSH directly in a terminal instead of through the Mac app, install the browser control plugin [dsh-chrome-control](https://github.com/dshapp/dsh-chrome-control) yourself:

```bash
dsh plugin --profile web add dsh-chrome-control
dsh web          # listens on http://127.0.0.1:3080 by default
```

Then install the extension as in step 2 and confirm the service address in its popup, which shows the connection state. Without the plugin the extension can't connect, and browser actions report "no connected Chrome extension."

## Why not a clean browser

A fresh browser means **no logins** — you'd have to sign in to every site again. Reusing your signed-in Chrome lets it pick up right where you are, and your cookies stay in your browser, never uploaded.

## Next

- [Picking elements](/en/docs/element-picker/) — point at things on the page.
- [Browser tools](/en/docs/browser-tools/) — what it can do in the browser.
