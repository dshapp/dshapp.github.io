---
title: "安装 macOS App"
linkTitle: "安装 macOS App"
description: "在 macOS 14+ 与 Apple Silicon 上安装 DSH 原生客户端，并在本机启动 DSH 服务。"
group: "start"
weight: 2
---

macOS 客户端是 DSH 的主场：它既是界面，也是本机 DSH 服务的宿主。

## 系统要求

| 项目 | 要求 |
| --- | --- |
| 系统 | macOS 14 (Sonoma) 或更高 |
| 芯片 | Apple Silicon（arm64 原生构建） |
| 磁盘 | 约 120 MB |

## 安装步骤

1. 从[下载页](/download/#mac)获取 `.dmg`。
2. 打开磁盘映像，把 **DSH** 拖进「应用程序」。
3. 首次启动若被 Gatekeeper 拦下，到「系统设置 → 隐私与安全性」点「仍要打开」。
4. 启动后按向导完成初始化，服务会随应用一起起来。

## 不用手动开服务

macOS 客户端会在本机启动并托管 DSH 服务，**不需要**开终端、不需要手动跑命令。关闭窗口不等于退出服务：服务随应用生命周期起停。

## 下一步

- [会话与工作区](/docs/sessions/) —— 认识会话、工作区与输入区。
- [快捷键](/docs/shortcuts/) —— 几乎一切都能在键盘上完成。
