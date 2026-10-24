---
title: "安装 Chrome 扩展"
linkTitle: "安装 Chrome 扩展"
description: "让 DSH 用你已登录的 Chrome 处理网页：在 Mac App 设置里一键安装组件，再从 Chrome 应用商店添加扩展。"
group: "start"
platform: "chrome"
weight: 3
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

## 不用 Mac App？一条命令检查并安装

一键脚本会依次检查 Node.js（≥ 22.19）、pnpm（≥ 10，dsh 用它安装插件）、dsh 和浏览器控制插件 [dsh-chrome-control](https://github.com/dshapp/dsh-chrome-control)，缺什么装什么，最后在后台启动一次 `dsh web`，让插件注册 Chrome 的本地启动器。已经装好的步骤会跳过，可以放心重复运行。

**macOS / Linux**：在「终端」中粘贴执行（[查看脚本](/install/chrome.sh)）：

```bash
curl -fsSL https://dshapp.github.io/install/chrome.sh | bash
```

**Windows 10 / 11**：在「命令提示符」（cmd）或 PowerShell 中粘贴执行（[查看脚本](/install/chrome.ps1)）：

```bat
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=3072; iex ([Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData('https://dshapp.github.io/install/chrome.ps1')))"
```

- 只想检查、不安装：macOS / Linux 在命令末尾加 `-s -- --check`（即 `… | bash -s -- --check`）；Windows 先执行 `set DSH_CHECK_ONLY=1`（PowerShell 中为 `$env:DSH_CHECK_ONLY='1'`）。
- 需要安装 Node.js 时：macOS 有 Homebrew 就用 Homebrew，否则从 nodejs.org 下载官方 LTS 安装包、校验 SHA-256 后用系统安装器安装（会要求输入开机密码）；Windows 优先用 winget，没有则下载官方 MSI（会弹出管理员授权）；Linux 请先用包管理器或 nvm 自行安装。
- Windows 需要 dsh-chrome-control 0.3.14 及以上（更早的版本在 Windows 上不注册本地启动器），脚本发现旧版本会自动升级；插件在设置里被停用时会提示你先启用。
- 如果 `dsh web` 在装插件之前就已经在运行，脚本不会替你结束它，会提示你关掉后重新运行（Windows 上会给出占用端口的 PID）。脚本自己在后台启动的 `dsh web` 没注册成功时会被自动结束，并给出日志里找到的原因。

也可以手动执行同样的步骤：

```bash
npm install -g pnpm
npm install -g @deepseek-ai/dsh
dsh plugin --profile web add dsh-chrome-control
dsh web          # 默认监听 http://127.0.0.1:3080
```

然后按上面的第 2 步安装扩展，在扩展弹窗里确认服务地址，弹窗会显示连接状态。没装插件时，扩展连不上服务，Agent 调用浏览器工具时会提示「没有连接的 Chrome 扩展」。

## 为什么不用一个干净的浏览器

全新的浏览器意味着**没有登录态** —— 你得在里面把每个网站重新登录一遍。复用你已登录的 Chrome，它才能直接接着你的上下文干活，而且你的 Cookie 留在浏览器里，不会被上传。

## 下一步

- [圈选网页元素](/docs/element-picker/) —— 在页面上直接指给它看。
- [浏览器工具](/docs/browser-tools/) —— 它在浏览器里能做哪些事。
