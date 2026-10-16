---
title: "电脑操作"
linkTitle: "电脑操作"
tagline: "让 DSH 操作没有 API 的 Mac 应用，在后台进行，不抢你的鼠标"
description: "dsh-kimi-computer-use 插件把 Kimi Computer Use 接入 DSH，提供 11 个 mcp__cu__* 工具：Agent 通过辅助功能树与截图看懂 Mac 应用的界面，在后台点击、输入、拖拽；不可逆操作先确认。"
icon: "cu"
badge: "插件"
weight: 30
repo: "https://github.com/dshapp/dsh-kimi-computer-use"
shot: "/img/shots/cu.jpg"
shotAlt: "DSH 通过电脑操作在「提醒事项」里新建列表并逐条添加待办"
features:
  - title: "够得着桌面应用"
    body: "没有 API、没有命令行的 Mac 应用，Agent 也能读懂界面并完成操作。"
  - title: "不抢鼠标和前台"
    body: "输入在后台投递，不移动你的鼠标指针，窗口被遮住也能操作，你可以继续用电脑。"
  - title: "每一步都核对"
    body: "内置操作技能：操作前后重新读取界面状态，确认结果再往下走，减少点错。"
  - title: "危险动作先确认"
    body: "发送、删除、购买、发布这类难以撤回的操作，先说明要做什么，等你确认。"
related:
  - path: "/products/chrome/"
    title: "Chrome 扩展与浏览器控制"
    body: "网页里的活交给浏览器控制，桌面应用交给电脑操作。"
  - path: "/products/macos/"
    title: "macOS App"
    body: "「设置 → 电脑操作」逐项检查插件、KimiCU 与授权。"
---

## 解决什么问题

DSH 擅长文件、命令和网页，但很多活发生在**没有 API、没有命令行**的桌面应用里：Keynote、系统设置、备忘录、各种内部客户端。传统的 GUI 自动化又会抢走你的鼠标和前台窗口，跑的时候你什么都干不了。

## 由什么组成

| 组件 | 作用 | 获取 |
| --- | --- | --- |
| KimiCU.app | 真正执行操作：读取界面、在后台投递点击与键盘输入 | Kimi 官方渠道 |
| dsh-kimi-computer-use 插件 | 把 KimiCU 接入 DSH，发布为 11 个 `mcp__cu__*` 工具，并附带操作技能 | `dsh plugin --profile web add dsh-kimi-computer-use` |

插件只负责连接：DSH 会随插件启动和停止 KimiCU 的 MCP 进程，但不会下载、安装或更新 KimiCU.app 本身。

## 它能帮你做什么

- 「把 Keynote 第 3 页的四个文本框左对齐。」
- 「在系统设置里把这台 Mac 的名字改成 Design-Mac。」
- 「把备忘录里这周的待办抄到提醒事项。」
- 「这个内部客户端没有导出功能，把列表数据抄成表格。」

## 两种「眼睛」

- **辅助功能树**：窗口、按钮、文字与层级。精确、可定位，知道某个元素「是什么」。
- **截图**：补齐树里说不清的部分，比如画布、图表、自定义绘制的界面。

定位基于控件本身而不是坐标，窗口挪了位置、换了分辨率也照样点得准；需要时也可以按坐标操作画布类界面。

## 不打扰你

- **不移动你的鼠标指针**，你可以继续正常用电脑。
- **不把窗口抢到前台**，即使窗口被完全遮挡，输入依然能落地。
- 极少数必须在前台操作的应用，才会短暂切到前台。

## 准备与安装

1. 从 **Kimi 官方渠道**安装 KimiCU.app，并保持它在运行。
2. 在「系统设置 → 隐私与安全性」里给 **KimiCU.app** 授予「辅助功能」与「屏幕录制」（不是授予 DSH）。
3. 安装插件：用 Mac App 的话，在「设置 → 电脑操作」一键安装，并逐项检查 KimiCU 与授权状态；用命令行的话运行 `dsh plugin --profile web add dsh-kimi-computer-use`，然后重启 dsh 服务。
4. 回到 DSH，对它说「帮我在某某应用里……」。

详见[电脑操作文档](/docs/computer-use/)。

## 系统要求

| 项目 | 要求 |
| --- | --- |
| 系统 | macOS |
| 依赖 | 已安装并运行的 KimiCU.app |
| DSH | `@deepseek-ai/dsh` 0.1.1-rc.2 或更高 |
