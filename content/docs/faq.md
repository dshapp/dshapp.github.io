---
title: "常见问题"
linkTitle: "常见问题"
description: "关于 DSH 扩展的安装、与 dsh 的关系、浏览器控制、电脑操作与手机远程的常见问题。"
group: "reference"
weight: 60
---

## 需要先安装 DSH 吗

用 macOS App 的话不需要：它会接入你已经装好的 dsh；还没装，就在征得你同意后装好 Node.js 与 `@deepseek-ai/dsh`。只用命令行装插件的话，需要先有 dsh。

## 会和我正在跑的 dsh web 冲突吗

不会。Mac App 启动时先探测 3080 端口，已有 dsh 服务就直接接入，不会再起一个。会话、模型配置、插件都是同一份，按 `⇧⌘,` 还能直接打开 Web 端。

## 不用 Mac App，能用这些扩展吗

可以。浏览器控制（`dsh-chrome-control`）和手机远程（`dsh-mobile-bridge`）都是普通的 dsh 插件，用 `dsh plugin --profile web add <插件名>` 安装即可，Linux 上的 dsh 同样可用。电脑操作需要 macOS。

## 这些扩展收费吗

不收费。插件与中转以 MIT 许可开源。模型调用的费用照旧取决于你在 DSH 里配置的模型服务商。

## 支持 Intel Mac 或 Windows 吗

macOS App 目前只支持 Apple Silicon（M1 及以上）、macOS 15 或更高。浏览器控制的后台服务提供 macOS、Linux 与 Windows 版本。手机端有两种：Android 8.0 及以上的 Android App，以及 iPhone 和 Android 上都能用的微信小程序 DSH Remote。

## 浏览器控制会影响我正在用的 Chrome 吗

Cookie 不会被上传。Agent 优先复用你已打开的页面，真实输入在后台标签页执行，任务结束也不会关掉你自己的标签页。不想让它碰浏览器时，在 Chrome 里停用扩展即可。

## 电脑操作为什么要装 KimiCU.app

真正执行界面操作的是 KimiCU.app，`dsh-kimi-computer-use` 插件只负责把它接入 DSH。辅助功能与屏幕录制权限也是授予 KimiCU.app，而不是 DSH。

## Android App 和微信小程序有什么区别

两者连的是同一个 `dsh-mobile-bridge` 插件、扫的是同一个二维码，功能基本一致。主要区别在于：小程序没有系统推送，切到后台后会断开、回到前台自动重连；Android App 能推送通知，任务运行时在后台保持连接。iPhone 用户请用小程序。详见[安装微信小程序](/docs/install-miniapp/)。

## 手机连上后看到的是同一批会话吗

是。手机连的是你电脑上的同一个 DSH，看到的是同一批会话、同一份文件、同一个工作区。

## 为什么需要一个中转服务器

因为你的电脑通常在 NAT 后面，手机没有能直接访问它的地址。中转的作用只是**按路由信息把字节搬过去**，它读不到内容、不落盘、不记日志。

## 中转能看到我的数据吗

看不到。手机与电脑之间是 Noise 端到端加密，中转只读连接开头的路由信息，之后只搬运密文。

## 我能自己搭中转吗

可以。中转 `dsh-proxy` 是单端口的 Rust 实现，在 `dsh-mobile-bridge` 的配置里指向你自己的地址即可。注意微信小程序只能连登记在它合法域名里的中转，自建中转目前只能配合 Android App 使用。

## 手机丢了怎么办

在电脑上的设备列表里**吊销**那台手机。吊销会立即挂断它已经建立的连接，不是等下次连接才生效。也可以一键断开与中转的连接，临时停止所有手机访问。

## 还有问题

- [排错](/docs/troubleshooting/) —— 服务起不来、扩展连不上等问题。
- [开源与安全](/opensource/) —— 看代码与安全评审。
