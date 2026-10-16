---
title: "Chrome 扩展与浏览器控制"
linkTitle: "Chrome 扩展"
tagline: "让 DSH 用上你已登录的 Chrome，并在浏览器侧栏里直接使用 DSH"
description: "dsh-chrome-control 插件给 DSH 的 Agent 提供 27 个浏览器工具，Chrome 扩展在你已登录的 Chrome 里执行；扩展侧栏本身也是完整的 DSH 客户端，支持圈选元素与页面上下文。"
icon: "chrome"
badge: "扩展 + 插件"
weight: 20
repo: "https://github.com/dshapp/dsh-chrome-control"
shot: "/img/shots/chrome-picker.jpg"
shotAlt: "在网页上圈选元素并写下批注"
shot2: "/img/shots/chrome-sidepanel.jpg"
shot2Alt: "Chrome 侧边栏中的 DSH 客户端"
features:
  - title: "复用你的登录态"
    body: "同一个配置文件、同一批登录态与已打开的标签页，公司后台、内部系统直接可用，Cookie 不离开浏览器。"
  - title: "后台执行，不打扰你"
    body: "真实点击与键盘输入在后台标签页进行；优先复用你已打开的页面，任务结束不关你自己的标签页。"
  - title: "圈选元素 + 批注"
    body: "在页面上圈出元素、写一句要求，元素信息直接进 DSH 的输入框；也可以把当前页面作为上下文带进对话。"
  - title: "侧栏即 DSH 客户端"
    body: "会话、Git 分支与改动、插件管理、后台任务与子代理，看网页时不用切窗口。"
related:
  - path: "/products/macos/"
    title: "macOS App"
    body: "在「设置 → 浏览器」一键安装并诊断连接。"
  - path: "/products/cu/"
    title: "电脑操作"
    body: "浏览器之外的桌面应用，交给电脑操作。"
---

## 解决什么问题

- **Agent 进不了要登录的网站。** 后台管理系统、公司内部工具、需要二次验证的站点，DSH 默认都碰不到。
- **另开浏览器等于重新登录。** Playwright 一类方案会启动一个干净的浏览器，每个站点都得重新登一遍。
- **说不清是页面上的哪个元素。** 只能截图、描述位置、复制选择器，再切回 DSH 粘贴。
- **在浏览器和 DSH 之间来回切。** 看着网页想问 DSH，得切窗口、复制网址和内容。

## 由两部分组成

| 组件 | 作用 | 获取 |
| --- | --- | --- |
| dsh-chrome-control 插件 | 装在 dsh 里，把浏览器能力发布为 `mcp__chrome__*` 工具，并启动一个独立的原生后台服务 | `dsh plugin --profile web add dsh-chrome-control` |
| Chrome 扩展（商店名「DeepSeek Harness APP」） | 在你的 Chrome 里执行操作，并提供侧栏里的 DSH 客户端 | [Chrome 应用商店](https://chromewebstore.google.com/detail/deepseek-harness-app/kgjjicancjnedmappjhefngdjaommpop) |

浏览器控制需要两者配合；只装扩展也能把侧栏当作 DSH 客户端使用。用 Mac App 的话，在「设置 → 浏览器」里一键安装插件、检测扩展即可。详见[安装 Chrome 扩展](/docs/install-chrome/)。

## 浏览器控制：Agent 用的就是你的 Chrome

插件连上后，Agent 获得 27 个 `mcp__chrome__*` 工具，覆盖：

- **导航与标签页**：打开任意地址（网页、本地文件、`about:`、`data:` 等），在标签页之间切换。
- **读懂页面**：无障碍快照、提取正文、按语义查找元素。
- **交互**：点击、填表、下拉选择、上传、悬停、键盘与鼠标、滚动、处理弹窗。
- **检查**：截图、导出 PDF、查看网络请求与响应、执行脚本。

几个对日常使用很重要的细节：

- **不打扰你**：真实鼠标与键盘输入在后台标签页执行，不会切走你正在看的页面。
- **不添乱**：优先复用你已打开的同一页面；任务结束不会关掉你自己的标签页。
- **快捷键靠谱**：按 Chrome 所在系统选 ⌘ 或 Ctrl；全选、复制、粘贴、撤销在各类输入框里都可用，并如实报告是否生效。
- **大页面不卡**：浏览器控制由独立的原生后台服务承担，读超大页面时 DSH 不会卡死；支持 macOS、Linux、Windows。
- **扩展可以唤醒 dsh**：dsh 没在运行时，扩展能把 `dsh web` 拉起来。

## 侧栏：浏览器里的 DSH 客户端

扩展的侧栏不只是遥控器，而是一个完整的 DSH 客户端：

- 会话列表与对话，按最近、状态或手动排序，带运行状态灯。
- **携带当前页面上下文**：打开开关，下一条消息会让 Agent 知道你正在看的页面。
- **Git 入口**：查看当前分支与改动量，切换、新建分支，推送与拉取。
- **插件管理**：安装、更新、卸载插件，一键重启或更新 DSH。
- **后台任务与子代理面板**：查看、中断后台任务和子代理。

## 圈选元素 + 批注

1. 在侧栏里点「圈选元素」。
2. 鼠标划过页面，候选元素实时高亮。
3. 点一下，在点击处弹出批注框，写下要求后提交，或继续圈下一个。

元素会以键值卡片的形式进入对话，Agent 可以直接对它点击、填写或读取。

## 边界

- Cookie 留在浏览器里，不会被上传。
- 只有扩展本身能连接控制通道，普通网页即使发现了地址也接不进来。
- 不发送任何遥测数据；上传文件时只会上传你明确指定的本地文件。
- 不想让 Agent 碰浏览器时，在 Chrome 里停用扩展即可；从 profile 移除插件则彻底关闭浏览器工具。

完整工具清单见[浏览器工具](/docs/browser-tools/)。
