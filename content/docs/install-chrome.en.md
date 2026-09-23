---
title: "Install the Chrome extension"
linkTitle: "Install the Chrome extension"
description: "Install the DSH Chrome extension to chat in the side panel and let the agent reuse your logged-in browser."
group: "start"
weight: 4
---

The Chrome extension lets the agent work in **the Chrome you actually use** — the same profile, the same logins, the same open tabs.

## Requirements

| Item | Requirement |
| --- | --- |
| Browser | Chrome 120+ |
| Extension platform | Manifest V3 |
| Server | DSH running locally with the [dsh-chrome-control](https://github.com/dshapp/dsh-chrome-control) plugin installed |

## Install the dsh-chrome-control plugin first

The extension is only the browser half and **does not work on its own**. It connects to the [dsh-chrome-control](https://github.com/dshapp/dsh-chrome-control) plugin inside DSH, which mounts `/chrome/mcp` and `/chrome/ws` on `dsh web` and publishes the extension's abilities to the agent as `mcp__chrome__*` tools. You need both.

```bash
dsh plugin --profile web add dsh-chrome-control
dsh web          # listens on http://127.0.0.1:3080 by default
```

Without the plugin the extension has nothing to connect to, and every browser tool call reports that no Chrome extension is attached.

## Install

1. Open [DeepSeek Harness APP on the Chrome Web Store](https://chromewebstore.google.com/detail/deepseek-harness-app/kgjjicancjnedmappjhefngdjaommpop) and click **Add to Chrome**.
2. Open the popup from the toolbar and enter your local DSH service address (the `dsh web` URL, `http://127.0.0.1:3080` by default); the extension connects to its `/chrome/ws` endpoint.
3. The popup shows the WebSocket status; once connected you are ready.
4. Open the side panel and start chatting.

## Why not a clean browser

A fresh incognito browser means **no logins** — you would have to sign in to every site again. Reusing your logged-in Chrome lets the agent continue from your real context, and no cookie ever has to be uploaded.

## Next

- [Picking elements](/en/docs/element-picker/) — point at things instead of describing them.
- [Browser tools](/en/docs/browser-tools/) — what the extension actually exposes.
