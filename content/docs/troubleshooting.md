---
title: "排错"
linkTitle: "排错"
description: "安装、连接、配对与权限相关的常见故障与排查方法。"
group: "reference"
weight: 61
---

## macOS App 打不开

**被 Gatekeeper 拦下**：到「系统设置 → 隐私与安全性」，在刚才那条拦截提示下面点「仍要打开」。

**确认架构**：客户端是 Apple Silicon（arm64）原生构建，需要 macOS 14+。

## Chrome 扩展显示未连接

1. 确认 macOS 客户端正在运行（服务随应用起停）。
2. 确认 DSH 已安装 [dsh-chrome-control](https://github.com/dshapp/dsh-chrome-control) 插件（`dsh plugin --profile web add dsh-chrome-control`，装完重启 `dsh web`）。没有这个插件，服务端根本没有 `/chrome/ws`，扩展无处可连。
3. 检查扩展弹窗里填的服务地址是否正确。
4. 弹窗里会显示 WebSocket 状态，注意看具体报错。

## 手机扫码后没连上

| 现象 | 排查 |
| --- | --- |
| 扫码没反应 | 确认二维码未过期（5 分钟有效），重新生成 |
| 提示配对失败 | 确认手机与 Mac 跑的是同一版本，令牌单次消费 |
| 之前能用现在不行 | 设备可能已到期（默认 180 天），重新配对 |

## 计算机使用点不中控件

到「系统设置 → 隐私与安全性」确认 **辅助功能** 与 **屏幕录制** 都已授权。少任何一个，要么读不到控件树，要么截不了图。

## 权限被拒绝

**默认就是拒绝的**。如果你访问的功能没在放行范围内，先看[权限分级](/docs/permissions/)确认它是否属于被允许的路由，而不是反复重试。

## 还是不行

- [常见问题](/docs/faq/)
- [开源与审核](/opensource/) —— 提 issue 前先看看仓库。
