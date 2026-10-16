---
title: "DSH App 文档"
linkTitle: "文档概览"
description: "DSH 扩展套件的安装、使用与安全说明：macOS App、Chrome 扩展与浏览器控制、电脑操作、手机远程。"
group: "start"
weight: 1
---

DSH App 是一套为 DSH 打造的扩展：原生客户端，加上浏览器、桌面应用和手机这几种 DSH 原本够不着的能力。它们都接入**你自己电脑上的 dsh 服务**，共享同一套会话、模型配置与插件。

## 从哪开始

| 你想要 | 从这里开始 |
| --- | --- |
| 不再守着终端和浏览器标签页用 DSH | [安装 macOS App](/docs/install-macos/) |
| 让 Agent 操作你已登录的 Chrome | [安装 Chrome 扩展](/docs/install-chrome/) |
| 让 Agent 操作没有 API 的 Mac 应用 | [电脑操作](/docs/computer-use/) |
| 离开电脑也能处理审批、看进度 | [安装 Android App](/docs/install-android/) |
| 了解远程访问为什么安全 | [加密与安全模型](/docs/crypto/) |

## 每个扩展是怎么接入 DSH 的

| 扩展 | 接入方式 |
| --- | --- |
| macOS App | 接入本机 3080 端口上的 dsh（没有就启动或安装一个） |
| 浏览器控制 | `dsh-chrome-control` 插件 + Chrome 扩展 |
| 电脑操作 | `dsh-kimi-computer-use` 插件 + KimiCU.app |
| 手机远程 | `dsh-mobile-bridge` 插件 + Android App |

插件既可以在 Mac App 的设置里一键安装，也可以用 `dsh plugin --profile web add <插件名>` 安装。浏览器控制与手机远程不依赖 Mac App，在 Linux 上的 dsh 同样可用。

## 三个约定

- **本机优先**：一切都连到你自己电脑上的 dsh；手机和浏览器是连进来的客户端，不是另一份云端副本。
- **默认拒绝**：手机只能访问白名单里的接口，控制通道只接受扩展本身的连接。
- **先说再做**：电脑操作遇到发送、删除、购买、发布这类不可逆操作，会先说明再执行。
