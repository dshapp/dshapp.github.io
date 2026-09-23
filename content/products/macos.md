---
title: "原生 macOS App"
linkTitle: "macOS App"
tagline: "丝滑、极速、快捷键齐全的 Mac 桌面端"
description: "DSH 的 macOS 原生客户端：SwiftUI 原生窗口、Apple Silicon 原生构建、完整快捷键体系，遵循 macOS 交互规范。"
icon: "apple"
badge: "丝滑 · 极速"
weight: 10
repo: "https://github.com/dshapp/dsh-macapp"
shot: "/img/shots/macos-app.jpg"
shotAlt: "DSH macOS 应用主界面"
shot2: "/img/shots/macos-shortcuts.jpg"
shot2Alt: "DSH macOS 应用的快捷键面板"
features:
  - title: "原生窗口，原生手感"
    body: "窗口、侧边栏、工具栏、菜单栏全部使用系统控件，滚动与惯性与系统一致，不套壳网页。"
  - title: "Apple Silicon 原生构建"
    body: "arm64 原生二进制，冷启动即用；长会话轨迹滚动依然保持帧率。"
  - title: "全套快捷键"
    body: "新建会话、查找、会话切换、快捷键面板，都绑定了符合 Mac 肌肉记忆的组合键。"
  - title: "跟随系统设置"
    body: "遵循系统外观、强调色与辅助功能选项，包括「减少动态效果」与高对比度。"
related:
  - path: "/products/chrome/"
    title: "Chrome 扩展与控制"
    body: "让 Agent 直接操作你日常使用的 Chrome。"
  - path: "/products/android/"
    title: "原生 Android App"
    body: "手机扫码连回这台 Mac，继续同一个会话。"
---

## 为什么是原生

DSH for macOS 是 SwiftUI 写的原生应用，不是把网页塞进窗口。这带来三件你在日常使用中能立刻感知到的事：

- **滚动手感和系统一致。** 会话轨迹再长也不会出现网页那种迟滞或跳帧，惯性与回弹跟系统其他应用一样。
- **启动即用。** 原生二进制省掉了运行时初始化，点开就能输入。
- **菜单栏即功能地图。** 每个命令都在菜单里出现并显示快捷键，快捷键面板（⌘/）可以一次看全。

## 快捷键

| 操作 | 快捷键 |
| --- | --- |
| 新建会话 | ⌘N |
| 在当前工作区新建会话 | ⌥⌘N |
| 新建工作区 | ⇧⌘N |
| 分叉会话 | ⌘R |
| 在当前视图中查找 | ⌘F |
| 上一个 / 下一个会话 | ⌥⌘← / ⌥⌘→ |
| 显示 / 隐藏边栏 | ⌥⌘S |
| 选择模型 | ⇧⌘M |
| 权限模式 | ⇧⌘P |
| 显示 / 隐藏终端 | ⌘J |
| 快捷键面板 | ⌘/ |
| 发送消息 | ⌘↩ |

完整列表以应用内快捷键面板为准。

## 遵循 macOS 规范

我们不自己画一套控件。窗口用系统窗口，侧边栏用系统侧边栏，列表用系统列表；主题色、对比度、动态效果开关全部读系统设置。你换系统外观、调强调色、开「减少动态效果」，应用跟着变。

## 本机服务

应用会在本机托管 DSH 服务，Chrome 扩展、手机端都连到它。你不需要额外开终端或者记端口。