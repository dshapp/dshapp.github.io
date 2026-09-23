---
title: "Chrome 扩展 & 浏览器控制"
linkTitle: "Chrome 扩展"
tagline: "复用你自己的 Chrome，在网页中圈选元素"
description: "DSH 的 Chrome 扩展与浏览器控制能力：使用你已登录的 Chrome 配置文件，支持在网页中圈选元素、点击、填表、上传、截图与网络检查。"
icon: "chrome"
badge: "圈选元素"
weight: 30
repo: "https://github.com/dshapp/dsh-chrome-extension"
shot: "/img/shots/chrome-picker.jpg"
shotAlt: "在网页中圈选元素"
shot2: "/img/shots/chrome-sidepanel.jpg"
shot2Alt: "Chrome 侧边栏中的 DSH 面板"
features:
  - title: "复用登录态"
    body: "操作你日常使用的那只 Chrome：同一个配置文件、同一批登录态、同一组已打开的标签页。"
  - title: "网页中圈选元素"
    body: "在页面上框出目标元素，连同选择器、文本与结构一起交给 Agent，比用语言描述位置可靠得多。"
  - title: "真实输入"
    body: "点击与键盘使用受信任事件，页面无法区分是人还是 Agent；需要时还能走后台标签页，不打断你当前的工作。"
  - title: "可控可切断"
    body: "扩展弹窗里的「允许 Agent 控制」开关一关，控制链路立即中断。"
related:
  - path: "/products/macos/"
    title: "原生 macOS App"
    body: "浏览器控制的结果会回到同一个会话里。"
  - path: "/products/cu/"
    title: "CU 能力"
    body: "浏览器之外的桌面应用，交给计算机使用能力。"
---

## 由两部分组成

浏览器控制需要**两部分配合使用**，缺一不可：

| 组件 | 作用 | 获取 |
| --- | --- | --- |
| Chrome 扩展 Deepseek Harness APP | 在浏览器里执行操作，并提供侧边栏对话 | [Chrome 应用商店](https://chromewebstore.google.com/detail/deepseek-harness-app/kgjjicancjnedmappjhefngdjaommpop) |
| DSH 插件 dsh-chrome-control | 在 `dsh web` 上提供扩展连接的桥接服务，把能力发布成 `mcp__chrome__*` 工具 | [GitHub](https://github.com/dshapp/dsh-chrome-control)，`dsh plugin --profile web add dsh-chrome-control` |

安装步骤见[安装 Chrome 扩展](/docs/install-chrome/)。

## 为什么复用你的 Chrome

大多数浏览器自动化方案会让你开一个"干净"的浏览器，于是所有需要登录的页面都进不去。DSH 的做法相反：**直接使用你已经在用的那只 Chrome**。

- 后台管理系统、公司内部工具、需要二次验证的站点，都是已登录状态，直接可用。
- 已打开的标签页也在视野内，不必重新导航。
- Cookie、扩展、代理设置都与你自己使用时完全一致。

## 在网页中圈选元素

这是日常最省事的入口。与其用语言描述"右上角那个按钮"，不如直接框住它：

1. 在扩展里点「圈选元素」。
2. 鼠标划过页面，候选元素实时高亮。
3. 点一下，元素的选择器、文本与结构摘要进入输入框。

元素摘要包含可点击的引用，Agent 后续可以直接对它执行点击、填表或读取。

## 控制工具

扩展连接后，Agent 获得 27 个 `mcp__chrome__*` 工具，覆盖导航与标签页管理、页面理解（快照、取文本、按语义查找）、交互（点击、填表、下拉、上传、悬停、键盘、鼠标）、滚动、脚本执行、截图与 PDF、网络检查、弹窗处理与等待。

## 权限与安全

- 扩展弹窗中的「允许 Agent 控制」开关可随时切断控制。
- 控制通道只接受来自扩展页面的连接，普通网页即使发现端点也无法接入。
- 不发送任何遥测数据。
- 上传工具只会把你显式指定的本地文件交给页面。