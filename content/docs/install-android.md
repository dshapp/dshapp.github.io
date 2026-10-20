---
title: "安装 Android App"
linkTitle: "安装 Android App"
description: "安装 DSH 的 Android 客户端，扫码连上你的 Mac，在手机上看进度、批准操作、追加要求。"
group: "start"
platform: "android"
weight: 4
---

Android App 是你电脑上 DSH 的手机客户端：手机上看到的是同一批会话，任务仍在电脑上运行。它通过 `dsh-mobile-bridge` 插件连回来，电脑不需要开放任何端口。

## 系统要求

| 项目 | 要求 |
| --- | --- |
| 系统 | Android 8.0 或更高 |
| 相机 | 用于扫描配对二维码 |
| 存储 | 约 40 MB |
| 电脑端 | 运行着 dsh，并安装了 `dsh-mobile-bridge` 插件（Mac App 已内置入口） |

## 安装步骤

1. 用手机浏览器打开[下载页](/download/#android)，下载 `.apk`（也可以在电脑上下载后传到手机）。
2. 首次安装时，按提示允许浏览器或文件管理器「安装未知应用」。
3. 如果手机上装过本地调试版，签名不同，需要先卸载旧版。

## 连上你的电脑

1. 打开配对页：在 Mac App 侧边栏点「**移动端访问**」；不用 Mac App 的话，先运行 `dsh plugin --profile web add dsh-mobile-bridge`，再在浏览器里打开 dsh web 的 `/mobileaccess` 页面。
2. 打开 Android App，扫描二维码。
3. 连上后，这台手机就是这台电脑的受信设备，之后打开直接用，不需要再输验证码。

二维码 5 分钟内有效、只能用一次；过期了重新生成即可。

## 连上之后

手机和 Mac 之间是端到端加密的通道，中转服务器看不到内容。手机上看到的是**同一批会话**、同一份文件，不是另一份云端副本。

## 下一步

- [配对与设备管理](/docs/pairing/) —— 有效期、在线状态与吊销。
- [加密与安全模型](/docs/crypto/) —— 这条通道为什么安全。
- 用 iPhone，或者不想装 App？试试[微信小程序 DSH Remote](/docs/install-miniapp/)。
