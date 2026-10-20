---
title: "微信小程序"
linkTitle: "微信小程序"
tagline: "DSH Remote：微信里扫一扫，就能接管电脑上的 DSH"
description: "DSH Remote 是 DSH 的微信小程序客户端：不用安装 App，iPhone 和 Android 上的微信都能用。经 dsh-mobile-bridge 插件端到端加密连回你的电脑，看进度、处理审批与提问、追加指令。电脑不开端口。"
icon: "wechat"
badge: "插件 + 小程序"
weight: 50
repo: "https://github.com/dshapp/dsh-mobile-bridge"
shot2: "/img/dsh-remote-qr.jpg"
shot2Qr: true
shot2Alt: "DSH Remote 小程序码：用微信扫一扫打开"
features:
  - title: "不用装 App"
    body: "微信扫码或搜索「DSH Remote」就能打开，iPhone 和 Android 都能用，没有安装包、不用开「未知来源」。"
  - title: "同一套配对"
    body: "和 Android App 扫的是同一个配对二维码：Mac App 侧栏「移动端访问」或 dsh web 的 /mobileaccess 页面。"
  - title: "端到端加密"
    body: "小程序经 WSS 连到中转，里面跑的是和电脑之间的 Noise_IK 会话；中转只拆帧转发，读不到内容。"
  - title: "随时收回"
    body: "在电脑上吊销设备，它已有的连接立即断开；也可以一键临时切断所有手机访问。"
related:
  - path: "/products/android/"
    title: "Android App"
    body: "需要系统推送、后台常驻连接时用原生 App。"
  - path: "/docs/install-miniapp/"
    title: "安装微信小程序"
    body: "打开小程序、扫码配对的完整步骤。"
  - path: "/opensource/"
    title: "开源与安全"
    body: "远程访问的加密设计与安全评审结果。"
---

## 解决什么问题

- **用 iPhone，或者不想装 App。** DSH 的原生手机客户端只有 Android 版；小程序在 iPhone 和 Android 上的微信里都能直接打开。
- **人一离开，任务就卡住。** 长任务跑到一半需要审批或回答一个问题，打开微信就能处理。
- **远程访问又麻烦又不放心。** 不用开端口、做内网穿透或连 VPN，连接全程端到端加密。

## 打开小程序

用微信扫描右侧的小程序码，或在微信里搜索「**DSH Remote**」。

## 由什么组成

| 组件 | 作用 | 获取 |
| --- | --- | --- |
| dsh-mobile-bridge 插件 | 装在 dsh 里，把 DSH 经加密隧道提供给已配对的手机；不开端口、不写状态文件、不额外起进程 | `dsh plugin --profile web add dsh-mobile-bridge` |
| dsh-proxy 中转 | 唯一的公网组件，只按路由信息转发密文 | [GitHub](https://github.com/dshapp/dsh-proxy) |
| DSH Remote 小程序 | 微信里的 DSH 客户端 | 微信扫码或搜索「DSH Remote」 |

插件随 dsh 服务一起运行，**任何跑着 dsh web 的电脑都能用**，不限于 Mac App。

## 小程序上能做什么

小程序连的是**你电脑上的同一个 DSH**，看到的是同一批会话和文件，不是云端副本：

- 会话列表按工作区分组，置顶、重命名、Fork、归档与恢复。
- 实时查看对话、工具调用，以及每轮改动的文件与 diff。
- **处理审批与提问**：多道提问逐题作答，也可以自定义答案。
- 新建会话、发送消息和附件、插话、查看与停止后台任务。
- 管理自动化任务与插件（开关、安装、更新），调整宿主设置与模型目录。
- 配对多台电脑，在设置里切换。

## 三步连上

1. 在电脑上安装插件：Mac App 用户已经内置入口；命令行用户运行 `dsh plugin --profile web add dsh-mobile-bridge`。
2. 打开配对页：Mac App 侧栏点「**移动端访问**」，或在浏览器里打开 dsh web 的 `/mobileaccess` 页面。
3. 打开 DSH Remote，**在小程序里**点「扫描二维码」（不是微信主界面的「扫一扫」），确认电脑名称后连接。

配对码 5 分钟内有效、只能用一次；配对后 180 天内无需重新配对。没有可用相机时，可以在小程序里选「手动输入配对串」，粘贴 `dshm://` 开头的配对文本。

## 与 Android App 的区别

两者连的是同一个插件、同一套会话，功能基本一致。区别来自微信小程序平台本身：

| | Android App | 微信小程序 |
| --- | --- | --- |
| 获取方式 | 下载 .apk 安装 | 微信扫码或搜索，无需安装 |
| 支持的手机 | Android 8.0+ | iPhone 与 Android 上的微信 |
| 任务通知 | 系统推送通知 | 无系统推送；小程序内显示未读角标 |
| 后台连接 | 任务运行时后台保持连接，锁屏不中断 | 切到后台后断开，回到前台自动重连并补齐进度 |
| 设备私钥 | 存在 Android Keystore | 存在微信本地存储 |
| 打开外部链接 | 交给系统浏览器 | 复制链接后自行打开 |
| 中转 | 官方中转或自建中转 | 只能连官方中转（受小程序合法域名限制） |

## 安全

- **端到端加密**：小程序经 `wss://<中转>/tunnel` 连到中转，WebSocket 帧里装的是手机与电脑之间的 Noise_IK 会话；中转只拆帧转发字节，不落盘、不记日志。
- **最小权限**：手机只能访问白名单里的接口；配对、吊销等管理操作只能在电脑上进行。
- **随时收回**：吊销某台设备，它已有的连接会立即断开。

技术细节见[加密与安全模型](/docs/crypto/)，安全评审见[开源与安全](/opensource/)。

## 系统要求

| 项目 | 要求 |
| --- | --- |
| 手机 | iPhone 或 Android 上的微信；扫码配对需要相机（也可以粘贴配对串） |
| 电脑 | 运行 dsh web 并安装 dsh-mobile-bridge 插件（macOS、Linux 均可） |

[安装微信小程序](/docs/install-miniapp/) · [配对与设备管理](/docs/pairing/)
