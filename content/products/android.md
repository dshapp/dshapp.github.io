---
title: "Android App"
linkTitle: "Android App"
tagline: "mobile-bridge 插件 + Android App：离开电脑，也能在手机上接管 DSH"
description: "dsh-mobile-bridge 插件把你电脑上的 DSH 经端到端加密通道交给已配对的手机，Android App 就是口袋里的 DSH 客户端：看进度、处理审批与提问、追加指令、收到通知。电脑不开端口。"
icon: "android"
badge: "插件 + 客户端"
weight: 40
repo: "https://github.com/dshapp/dsh-mobile-bridge"
aliases:
  - /products/remote/
shot: "/img/shots/android-app.png"
shotPortrait: true
shotAlt: "DSH Android App 会话列表"
shot2: "/img/shots/remote-pairing.jpg"
shot2Alt: "电脑上的移动端访问页与手机上的提问卡片"
features:
  - title: "任务不再卡在审批上"
    body: "Agent 需要你批准或回答问题时，手机上直接处理；任务有进展、完成或失败都会推送通知。"
  - title: "不开端口、不做内网穿透"
    body: "电脑主动连到公网中转，手机经中转连回来；不需要公网 IP、路由器设置或 VPN。"
  - title: "端到端加密"
    body: "一次 Noise 握手同时完成加密与双向认证，中转只转发密文，读不到内容、不落盘。"
  - title: "随时收回"
    body: "吊销设备立即断开已有连接；也可以一键临时切断所有手机访问，不必取消配对。"
related:
  - path: "/products/macos/"
    title: "macOS App"
    body: "侧栏「移动端访问」就是配对入口。"
  - path: "/products/miniapp/"
    title: "微信小程序"
    body: "不想装 App，或者用 iPhone：微信里的 DSH Remote，同一套配对。"
  - path: "/opensource/"
    title: "开源与安全"
    body: "远程访问的加密设计与安全评审结果。"
---

## 解决什么问题

- **人一离开，任务就卡住。** 长任务跑到一半需要审批或回答一个问题，你却在会议室、在路上。
- **不知道跑完没有。** 完成了、失败了、卡住了，只有回到电脑前才知道。
- **远程访问又麻烦又不放心。** 想从外面连回家里或公司电脑上的 DSH，得开端口、做内网穿透或连 VPN。

## 由什么组成

| 组件 | 作用 | 获取 |
| --- | --- | --- |
| dsh-mobile-bridge 插件 | 装在 dsh 里，把 DSH 经加密隧道提供给已配对的手机；不开端口、不写状态文件、不额外起进程 | `dsh plugin --profile web add dsh-mobile-bridge` |
| dsh-proxy 中转 | 唯一的公网组件，只按路由信息转发密文；中转地址写在配对二维码里，可以自己部署 | [GitHub](https://github.com/dshapp/dsh-proxy) |
| Android App | 手机上的 DSH 客户端 | [下载页](/download/#android) |

插件随 dsh 服务一起运行，**任何跑着 dsh web 的电脑都能用**，不限于 Mac App。

不想装 App，或者用的是 iPhone？同一个插件也服务微信小程序 [DSH Remote](/products/miniapp/)，扫的是同一个二维码。

## 手机上能做什么

手机连的是**你电脑上的同一个 DSH**，看到的是同一批会话和文件，不是云端副本：

- 实时查看会话、工具调用与每轮的改动文件和 diff。
- **处理审批与提问**：多道提问逐题作答，也可以自定义答案。
- 新建会话、发送消息和附件、插话、编辑排队消息、停止后台任务。
- 任务进展推送通知；任务运行时 App 在后台保持连接，锁屏也不中断。
- 配对多台电脑，在列表里切换；会话内查找、预览文件与图片、归档会话。

## 三步连上

1. 在电脑上安装插件：Mac App 用户已经内置入口；命令行用户运行 `dsh plugin --profile web add dsh-mobile-bridge`。
2. 打开配对页：Mac App 侧栏点「**移动端访问**」，或在浏览器里打开 dsh web 的 `/mobileaccess` 页面。
3. 用 Android App 扫描二维码，完成。

配对码 5 分钟内有效、只能用一次，生成新码会让旧码作废；配对后 180 天内无需重新配对。

## 设备管理

- 设备列表显示每台手机**实时**是否在线（按实际连接观测，不是猜测）。
- 可以给手机重命名，方便区分多台设备。
- **吊销**某台手机，它已有的连接会立即断开。
- 一键**断开 / 恢复**与中转的连接，临时停止所有手机访问而不必取消配对。

## 安全

- **端到端加密**：手机与电脑之间一次 Noise_IK 握手同时完成加密与双向认证；中转只读连接开头的路由信息，之后只转发密文，不落盘、不记日志。
- **最小权限**：手机只能访问白名单里的接口；配对、吊销等管理操作只能在电脑上进行。
- **弱网友好**：所有请求走同一条长连接并自动压缩；断线重连后重试的操作不会被执行两次。

技术细节见[加密与安全模型](/docs/crypto/)，安全评审见[开源与安全](/opensource/)。

## 系统要求

| 项目 | 要求 |
| --- | --- |
| 手机 | Android 8.0 或更高，带相机 |
| 电脑 | 运行 dsh web 并安装 dsh-mobile-bridge 插件（macOS、Linux 均可） |

[下载 Android App](/download/#android) · [配对与设备管理](/docs/pairing/)
