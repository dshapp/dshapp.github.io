---
title: "原生 Android App"
linkTitle: "Android App"
tagline: "Kotlin + Compose，扫码连回 Mac"
description: "DSH 的 Android 原生客户端：Kotlin 与 Jetpack Compose 实现，Material 3 交互，与其它端共享同一批会话；扫码即可连回 Mac，端到端加密。"
icon: "android"
badge: "Material 3"
weight: 20
repo: "https://github.com/dshapp/dsh-androidapp"
aliases:
  - /products/remote/
shot: "/img/shots/android-app.png"
shotAlt: "DSH Android 应用界面"
shot2: "/img/shots/remote-pairing.jpg"
shot2Alt: "Mac 应用中的手机访问配对二维码"
features:
  - title: "纯原生实现"
    body: "Kotlin + Jetpack Compose，不嵌 WebView；列表、抽屉、底部弹层都用 Material 3 组件。"
  - title: "功能对齐"
    body: "会话列表、会话页、输入区、图片与附件、各类设置面板与桌面端保持一致。"
  - title: "扫码接入"
    body: "用相机扫描 Mac 上的配对二维码即可接入，之后靠密钥自证明，不再需要验证码。"
  - title: "端到端加密"
    body: "手机与 Mac 之间一次 Noise_IK 握手同时完成加密与双向认证，中转服务器读不到任何内容。"
related:
  - path: "/products/macos/"
    title: "原生 macOS App"
    body: "配对码的发起端，也是会话真正运行的地方。"
  - path: "/products/chrome/"
    title: "Chrome 扩展与控制"
    body: "让 Agent 直接操作你日常使用的 Chrome。"
---

## 与桌面端一致的能力

Android 客户端的目标不是「能用」，而是和桌面端**一样好用**：

- 会话列表、工作区、设置面板与桌面端是同一份数据。
- 对话流里的工具调用、轨迹、Markdown 与代码高亮都原生渲染。
- 图片、附件、分享都通过系统能力完成。

## 平台化的交互替换

界面按 Android 规范重新实现，不做 iOS 的照搬：

| iOS | Android |
| --- | --- |
| NavigationStack | Navigation Compose |
| List / Section | LazyColumn + ListItem |
| swipeActions | SwipeToDismissBox |
| contextMenu | 长按 DropdownMenu |
| sheet | ModalBottomSheet |
| SF Symbols | Material Icons |
| DataScanner | CameraX + ML Kit |

## 配对流程

手机不是「登录」进来的，而是和这台 Mac 建立一条自己的加密通道：

- Mac 侧点「添加设备」，生成一次性配对令牌（5 分钟有效，同时只留一枚）。
- 二维码里带上中转地址、Mac 的公钥与名称、以及令牌。
- 手机扫码 → 本地生成密钥对 → 用 Noise_IK 连上 → 首条消息携带令牌。
- Mac 校验令牌（常数时间、单次消费）后把设备公钥写入白名单。
- 令牌立即丢弃；未配对设备的握手在认证阶段就失败。

## 三件事，一次握手解决

传统方案里，加密靠 TLS、鉴权靠令牌、防重放靠时间戳与去重表。DSH 把它们合并成一次 Noise_IK 握手：

| 能力 | 由什么提供 |
| --- | --- |
| 加密信道 | Noise transport（ChaChaPoly） |
| 认证手机 | 握手里的设备静态公钥，公钥本身就是设备 ID |
| 认证 Mac | 手机预先知道 Mac 的公钥，握手时验证 |
| 前向保密 | 每次握手的临时密钥 |
| 防重放 | transport nonce 单调计数 |

结果是：**没有证书、没有 CA、没有域名依赖、没有 bearer token，也没有时间窗校验。**

## 中转服务器看不到内容

公网侧只有一个极简中转：

1. 读每条连接开头的 37 字节明文头（magic + 版本 + 路由公钥）。
2. 按路由公钥找到对应 Mac 的长连接。
3. 之后**只搬字节**，永不解析。

它不解密、不写磁盘、不记日志。路由公钥只是标识符，不是秘密——它本来就在配对二维码里。

## 设备管理

- 每台设备带到期时间，默认 180 天。
- 设备列表里的"在线"是观测出来的：中转会统计手机实际持有的连接数，而不是靠"最后活跃时间"猜。
- 吊销设备会同时挂断它已经建立的连接。

## 连接后能访问什么

手机连上后**只能访问它需要的**：RPC 通道开放，插件路由默认拒绝，只有明确加入白名单的少数路由例外。配对与吊销接口对手机一律返回 403 —— 它们只属于 Mac 端。

## 安全存储

设备私钥与服务器配置保存在加密存储中，与桌面端一样，配对成功后不依赖密码。
