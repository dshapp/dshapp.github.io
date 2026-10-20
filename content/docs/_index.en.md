---
title: "DSH App documentation"
linkTitle: "Documentation"
description: "Install, use and secure the DSH extension suite: the macOS app, the Chrome extension & browser control, computer use and remote access (the Android app and the WeChat mini program)."
group: "start"
weight: 1
---

DSH App is a set of extensions built for DSH: native clients, plus the browser, desktop apps and phone that DSH can't reach on its own. They all connect to **the dsh service on your own computer** and share the same sessions, model config and plugins.

## Where to start

| You want to | Start here |
| --- | --- |
| Stop babysitting a terminal and a browser tab | [Install the macOS app](/en/docs/install-macos/) |
| Let the agent drive your signed-in Chrome | [Install the Chrome extension](/en/docs/install-chrome/) |
| Let the agent operate Mac apps that have no API | [Computer use](/en/docs/computer-use/) |
| Handle approvals and follow progress away from your desk | [Install the Android app](/en/docs/install-android/) |
| Do that on an iPhone, or without installing an app | [Set up the WeChat mini program](/en/docs/install-miniapp/) |
| Understand why remote access is safe | [Encryption and the security model](/en/docs/crypto/) |

## How each extension plugs into DSH

| Extension | How it connects |
| --- | --- |
| macOS app | Attaches to dsh on port 3080 (or starts / installs one) |
| Browser control | `dsh-chrome-control` plugin + Chrome extension |
| Computer use | `dsh-kimi-computer-use` plugin + KimiCU.app |
| Remote access · Android | `dsh-mobile-bridge` plugin + Android app |
| Remote access · WeChat | `dsh-mobile-bridge` plugin + WeChat mini program DSH Remote |

Plugins install in one click from the Mac app's Settings, or with `dsh plugin --profile web add <plugin>`. Browser control and remote access don't need the Mac app and work with dsh on Linux too.

## Three ground rules

- **Local first**: everything connects to the dsh on your own computer; phones and browsers are clients that connect in, not cloud copies.
- **Default deny**: phones reach only allowlisted endpoints, and the control channel accepts only the extension itself.
- **Say it before doing it**: computer use explains irreversible actions — sending, deleting, purchasing, publishing — before carrying them out.
