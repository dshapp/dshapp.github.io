---
title: "浏览器工具"
linkTitle: "浏览器工具"
description: "Chrome 扩展与控制能力给 Agent 开放的 27 个浏览器工具，按能力分组。"
group: "browser"
weight: 21
---


浏览器控制以 `mcp__chrome__*` 工具的形式挂给 Agent。扩展连上后共 **27 个**工具，按能力分组，不是无限制的万能接口。

这些工具由 DSH 插件 [dsh-chrome-control](https://github.com/dshapp/dsh-chrome-control) 发布，并通过 Chrome 扩展执行，两者都装好才会出现，见[安装 Chrome 扩展](/docs/install-chrome/)。

## 会话与标签页

| 工具 | 作用 |
| --- | --- |
| `find_tab` | 按 URL 或「用户当前正在看的标签」重新选中标签页 |
| `list_tabs` | 列出本会话标签组内的所有标签（含 id、URL、标题） |
| `close_tab` | 关闭当前标签 |
| `close_session` | 关闭整个标签组（只在用户明确要求时用） |

## 导航与读取

| 工具 | 作用 |
| --- | --- |
| `navigate` | 打开 URL |
| `get_text` | 提取可读正文，默认剥掉导航、页头页脚与脚本 |
| `snapshot` | 读可访问性树，拿到可交互元素与 `@e` 引用 |

## 定位与交互

| 工具 | 作用 |
| --- | --- |
| `find` | 用一句自然语言找到一个控件，返回可复用引用 |
| `click` | 点击元素；控件不响应合成事件时可切真实输入 |
| `fill` | 填写输入框、文本域或富文本编辑器（清空后写入并回读校验） |
| `select` | 选择下拉项：原生 `<select>` 或 ARIA combobox |
| `hover` | 真实鼠标悬停，触发鼠标移入类菜单与提示 |
| `focus` | 只聚焦不点击，便于随后输入 |
| `key_type` | 以真实按键事件输入文本，并回读确认 |
| `send_keys` | 按单个键或组合键（如 `Control+A`、`Enter`） |
| `mouse_click` | 真实鼠标点击，可按元素或视口坐标 |
| `upload` | 给文件上传控件设置本地路径 |

## 滚动

| 工具 | 作用 |
| --- | --- |
| `scroll` | 滚动页面或某个可滚动元素，并报告是否真的移动了 |
| `scroll_into_view` | 把元素滚进视口并返回它的几何信息 |

## 脚本与取证

| 工具 | 作用 |
| --- | --- |
| `evaluate` | 在页面里执行 JavaScript，返回可序列化结果 |
| `screenshot` | 截当前视口，或单独截一个元素 |
| `save_as_pdf` | 把页面渲染成 PDF 存到磁盘 |
| `network` | 列出本标签最近的网络请求（方法、URL、状态） |
| `network_detail` | 单个请求的完整记录，含请求/响应头，可选响应体 |
| `dialog` | 应答 alert / confirm / beforeunload / prompt |

## 等待

| 工具 | 作用 |
| --- | --- |
| `wait` | 固定等待一小段时间（上限 3 秒） |
| `wait_for_selector` | 轮询到元素出现或消失，命中即返回 |

## 复用的是你的登录态

这些工具跑在你**已登录**的 Chrome 里，所以访问需要登录的站点时不用重新认证。代价是你得清楚：Agent 看得到你在那个浏览器里能看到的东西。

## 下一步

- [权限分级](/docs/permissions/) —— 插件路由的默认拒绝与白名单。
