---
title: "安装 Chrome 扩展"
linkTitle: "安装 Chrome 扩展"
description: "让 DSH 用你已登录的 Chrome 处理网页：在 Mac App 设置里一键安装组件，再从 Chrome 应用商店添加扩展。"
group: "start"
weight: 4
---

浏览器控制让 DSH 的 Agent 直接使用**你日常在用的那个 Chrome** —— 同样的登录态、同样的已打开标签页。它由 `dsh-chrome-control` 插件与 Chrome 扩展两部分组成；只装扩展的话，也可以把它的侧栏当作 DSH 客户端使用。

## 系统要求

| 项目 | 要求 |
| --- | --- |
| 浏览器 | Chrome 120 或更高 |
| Mac 端 | 已安装并运行 [DSH macOS App](/docs/install-macos/) |

## 安装步骤（推荐）

1. 打开 Mac App 的「**设置 → 浏览器**」。它会检测浏览器控制所需的组件，缺什么点一下就装好。
2. 打开 [Chrome 应用商店中的扩展](https://chromewebstore.google.com/detail/deepseek-harness-app/kgjjicancjnedmappjhefngdjaommpop)（商店名称为「DeepSeek Harness APP」），点「添加至 Chrome」。
3. 回到「设置 → 浏览器」，显示「已连接」就可以用了。连不上时，设置页会显示具体原因。
4. 建议把扩展图标固定到工具栏；打开侧边栏，也可以直接在 Chrome 里和它对话。

扩展默认连接本机的 DSH 服务（`http://127.0.0.1:3080`），一般不需要修改。

## 不用 Mac App？用命令行安装

如果你直接在终端里运行 DSH，而不是用 Mac App，需要手动安装浏览器控制插件 [dsh-chrome-control](https://github.com/dshapp/dsh-chrome-control)：

```bash
dsh plugin --profile web add dsh-chrome-control
dsh web          # 默认监听 http://127.0.0.1:3080
```

然后按上面的第 2 步安装扩展，在扩展弹窗里确认服务地址，弹窗会显示连接状态。没装插件时，扩展连不上服务，Agent 调用浏览器工具时会提示「没有连接的 Chrome 扩展」。

## 为什么不用一个干净的浏览器

全新的浏览器意味着**没有登录态** —— 你得在里面把每个网站重新登录一遍。复用你已登录的 Chrome，它才能直接接着你的上下文干活，而且你的 Cookie 留在浏览器里，不会被上传。

## 下一步

- [圈选网页元素](/docs/element-picker/) —— 在页面上直接指给它看。
- [浏览器工具](/docs/browser-tools/) —— 它在浏览器里能做哪些事。
