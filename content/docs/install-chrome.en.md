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

## Not using the Mac app? Check and install with one command

The setup script checks, in order, Node.js (≥ 22.19), pnpm (≥ 10 — dsh installs plugins with it), dsh and the browser control plugin [dsh-chrome-control](https://github.com/dshapp/dsh-chrome-control), installs whatever is missing, then starts `dsh web` once in the background so the plugin registers Chrome's local launcher. Finished steps are skipped, so it is safe to run again.

**macOS / Linux** — paste into Terminal ([view script](/install/chrome.sh)):

```bash
curl -fsSL https://dshapp.github.io/install/chrome.sh | bash
```

**Windows 10 / 11** — paste into Command Prompt (cmd) or PowerShell ([view script](/install/chrome.ps1)):

```bat
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=3072; iex ([Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData('https://dshapp.github.io/install/chrome.ps1')))"
```

- Check only, install nothing: on macOS / Linux append `-s -- --check` (`… | bash -s -- --check`); on Windows run `set DSH_CHECK_ONLY=1` first (`$env:DSH_CHECK_ONLY='1'` in PowerShell).
- When Node.js is missing: macOS uses Homebrew if present, otherwise the official LTS package from nodejs.org, verified by SHA-256 and installed with Apple's installer (asks for your password); Windows prefers winget and falls back to the official MSI (shows an admin prompt); on Linux install it with your package manager or nvm first.
- If `dsh web` was already running before the plugin was installed, the script won't stop it for you; it tells you to stop it and run the script again.

Or run the same steps by hand:

```bash
npm install -g pnpm
npm install -g @deepseek-ai/dsh
dsh plugin --profile web add dsh-chrome-control
dsh web          # listens on http://127.0.0.1:3080 by default
```

Then install the extension as in step 2 and confirm the service address in its popup, which shows the connection state. Without the plugin the extension can't connect, and browser actions report "no connected Chrome extension."

## Why not a clean browser

A fresh browser means **no logins** — you'd have to sign in to every site again. Reusing your signed-in Chrome lets it pick up right where you are, and your cookies stay in your browser, never uploaded.

## Next

- [Picking elements](/en/docs/element-picker/) — point at things on the page.
- [Browser tools](/en/docs/browser-tools/) — what it can do in the browser.
