---
title: "安装 Chrome 扩展"
linkTitle: "安装 Chrome 扩展"
description: "安装 DSH Chrome 扩展，在侧边栏里对话，并让 Agent 复用你已登录的浏览器。"
group: "start"
weight: 4
---

Chrome 扩展让 Agent 直接操作**你日常在用的那个 Chrome** —— 同样的 profile、同样的登录态、同样的已打开标签页。

## 系统要求

| 项目 | 要求 |
| --- | --- |
| 浏览器 | Chrome 120+ |
| 权限模型 | Manifest V3 |
| 服务端 | 本机运行的 DSH，且已安装 [dsh-chrome-control](https://github.com/dshapp/dsh-chrome-control) 插件 |

## 先装 dsh-chrome-control 插件

扩展只是浏览器这一半，**不能单独使用**。它要连接 DSH 里的 [dsh-chrome-control](https://github.com/dshapp/dsh-chrome-control) 插件：插件在 `dsh web` 上挂出 `/chrome/mcp` 与 `/chrome/ws`，把扩展的能力发布成 Agent 可用的 `mcp__chrome__*` 工具。两者缺一不可。

```bash
dsh plugin --profile web add dsh-chrome-control
dsh web          # 默认监听 http://127.0.0.1:3080
```

没装插件时，扩展连不上服务，Agent 调用浏览器工具也只会得到「没有连接的 Chrome 扩展」。

## 安装步骤

1. 打开 [Chrome 应用商店中的 DeepSeek Harness APP](https://chromewebstore.google.com/detail/deepseek-harness-app/kgjjicancjnedmappjhefngdjaommpop)，点「添加至 Chrome」安装扩展。
2. 点扩展图标打开弹窗，填写本机 DSH 服务地址（即 `dsh web` 的地址，默认 `http://127.0.0.1:3080`），扩展会自动连接其中的 `/chrome/ws`。
3. 弹窗里能看到 WebSocket 连接状态，显示已连接即可用。
4. 打开侧边栏开始对话。

## 为什么不用一个干净的浏览器

用一个全新的无痕浏览器意味着**没有登录态** —— 你还得在里面重新登录每个站点。复用你已登录的 Chrome，Agent 才能直接接着你的上下文干活，也不用上传任何 Cookie。

## 下一步

- [圈选网页元素](/docs/element-picker/) —— 在页面上直接指着元素说话。
- [浏览器工具](/docs/browser-tools/) —— 扩展到底给 Agent 开了哪些能力。
