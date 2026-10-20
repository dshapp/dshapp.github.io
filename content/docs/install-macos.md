---
title: "安装 macOS App"
linkTitle: "安装 macOS App"
description: "安装 DSH 的 macOS 原生客户端：接入本机已在运行的 dsh，或由 App 帮你启动和安装；再在设置里开启各个扩展。"
group: "start"
platform: "macos"
weight: 2
---

macOS App 是 DSH 的原生桌面客户端，也是本机 dsh 服务的管家。它不是另一套 DSH：会话、模型配置、插件都和 `dsh web` 是同一份。

## 系统要求

| 项目 | 要求 |
| --- | --- |
| 系统 | macOS 15 或更高 |
| 芯片 | Apple Silicon（M1 及以上）；暂不支持 Intel Mac |
| DSH | 已安装的 `@deepseek-ai/dsh`；没有的话 App 会帮你装 |

## 安装步骤

1. 从[下载页](/download/#mac)获取 `.dmg`（约 15 MB）。
2. 打开磁盘映像，把 **DSH** 拖进「应用程序」。
3. 首次打开时，macOS 可能提示「无法验证开发者」，因为当前版本还没有经过 Apple 公证：在 Finder 里**按住 Control 点按 App，选「打开」**；或到「系统设置 → 隐私与安全性」点「仍要打开」。只需要做一次。

## 首次启动：它怎么找到你的 DSH

| 你的情况 | App 会怎么做 |
| --- | --- |
| 终端里已经在跑 `dsh web`（3080 端口） | 直接接入，不再另起服务 |
| 装了 dsh，但没在运行 | 用你已安装的那份 dsh 启动服务，随 App 起停 |
| 还没装 dsh | 征得你同意后安装 Node.js（来自 nodejs.org，会弹出 Apple 安装器）与 `@deepseek-ai/dsh` |

如果你的 DSH 还没配置过模型，App 会引导你添加一个 API Key；已经配置过的，直接就能用。之后有新版 dsh 时，App 会提示升级。

## 开启扩展

都在 App 里，一键完成：

- **设置 → 浏览器**：安装浏览器控制插件、检测 Chrome 扩展，见[安装 Chrome 扩展](/docs/install-chrome/)。
- **设置 → 电脑操作**：安装电脑操作插件、检查 KimiCU.app 与授权，见[电脑操作](/docs/computer-use/)。
- **设置 → 插件**：在「插件市场」与「内置插件」里启用、停用或移除插件。
- **侧栏 → 移动端访问**：生成配对二维码，见[安装 Android App](/docs/install-android/)或[安装微信小程序](/docs/install-miniapp/)。

## 回到 Web 端

按 `⇧⌘,` 用已登录状态在浏览器里打开 dsh 的 Web 界面。两边是同一个服务，随时切换。

## 更新

有新版本时 App 内会提示，也可以随时到[下载页](/download/#mac)下载覆盖安装。会话与设置都会保留。

## 下一步

- [快捷键](/docs/shortcuts/) —— 几乎一切都能在键盘上完成。
- [排错](/docs/troubleshooting/) —— 服务起不来、扩展连不上时看这里。
