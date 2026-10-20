# DSH 站点

DSH 产品家族的静态宣传站，用 Hugo 构建。视觉语言对齐 [linear.app](https://linear.app/)：深色单色调、Inter Variable 字体、克制的描边与层次，无主题切换、无 npm 构建链。

## 运行

本地预览（带草稿与热重载）：

```bash
cd /Users/user/dshapp/dsh-site
hugo server --port 1313 --bind 127.0.0.1
```

打开 <http://127.0.0.1:1313/>（中文）或 <http://127.0.0.1:1313/en/>（英文）。

出静态产物到 `public/`：

```bash
hugo --gc --minify
```

Hugo 版本要求：`0.166.0+extended`（Hugo Pipes 用于拼接、压缩和指纹化 CSS/JS）。

## 部署

线上地址：<https://dshapp.github.io/>（仓库 `dshapp/dshapp.github.io`）。

`.github/workflows/pages.yml` 在每次 push 到 `main` 时自动执行：安装 Hugo extended → `hugo --gc --minify` → 校验产物 → 发布到 GitHub Pages。
`public/` 不入库，线上版本完全由 CI 构建。需要重新部署但没有新提交时，在 Actions 页面对该 workflow 点 **Run workflow**，或：

```bash
gh workflow run pages.yml -R dshapp/dshapp.github.io
```

## 下载与安装包

下载页 `/download/`（`content/download*.md` + `layouts/_default/download.html`，文案在 `data/download/{zh,en}.yaml`）和全站所有下载按钮都指向本站 `/downloads/` 下的安装包，并显示当前最新版本号。整条链路：

```
dsh-macapp / dsh-androidapp  push main
  └─ notify-site.yml  ──repository_dispatch──▶  本仓库 build-apps.yml（另有每 30 分钟轮询兜底）
        ├─ build-mac      macos-26：Scripts/build-dmg-unsigned.sh → Release  mac-v0.1.<N>
        ├─ build-android  ubuntu：assembleRelease（release keystore 签名）→ Release  android-v1.0.<N>
        └─ deploy-site    触发 pages.yml
pages.yml
  └─ scripts/fetch-releases.py：取各平台最新 Release → static/downloads/*.dmg|*.apk + data/releases.json
       + /downloads/latest.json → hugo 构建 → Pages
```

- 源码 commit 没变就不会重复构建（Release 说明里记录了 `source-sha`）。手动重建：Actions → *Build & publish app installers* → Run workflow（可选平台、勾选 force）。
- 模板通过 `partial "dl/url.html" "mac"` / `"android"` / `"chrome"` 取下载地址，`dl/meta.html` 取「v0.1.64 · 14.6 MB」，`dl/version-line.html` 渲染按钮下方的版本行。某平台还没有 Release 时，按钮自动退回到 `/download/`，页面显示「即将推出」。
- 本地预览想看到真实版本：`GH_TOKEN=$(gh auth token -h github.com) python3 scripts/fetch-releases.py`，生成物已在 `.gitignore` 中。

所需 secrets（本仓库 Settings → Secrets and variables → Actions）：

| Secret | 所在仓库 | 内容 |
| --- | --- | --- |
| `APP_SOURCE_TOKEN` | dshapp.github.io | fine-grained PAT：仓库 dsh-macapp + dsh-androidapp，Contents: Read-only |
| `ANDROID_KEYSTORE_BASE64` / `ANDROID_KEYSTORE_PASSWORD` / `ANDROID_KEY_ALIAS` / `ANDROID_KEY_PASSWORD` | dshapp.github.io | Android release 签名（本机备份在 `~/.dsh-keys/`，**丢失后已安装用户无法覆盖升级**） |
| `SITE_DISPATCH_TOKEN` | dsh-macapp、dsh-androidapp | fine-grained PAT：仓库 dshapp.github.io，Contents: Read and write（可选，缺省时靠轮询） |

## 更新日志（/whatsnew/）

顶栏「更新日志 / What's new」进入 `/whatsnew/`，汇总各模块最近的版本更新，可按模块筛选（`#mac`、`#android` 等 hash 直达某个模块，`#mac-0-1-64` 直达某个版本）。

- 数据：`data/changelog/<模块>.yaml`（mac / android / chrome / browser / bridge / cu），每个版本含 `version`、`date`、`status`（upcoming / released）、`title.{zh,en}`、`changes[].{type,zh,en}`，`type` 取 new / improved / fixed。内容由各仓库的 tag 与提交历史整理，只写用户可感知的变化。
- **自动同步**：`.github/workflows/changelog-sync.yml` 每 15 分钟（以及 build-apps 跑完后）运行 `scripts/sync-changelog.py`，有变化就提交 `data/changelog/` 并重新部署：
  - 已标 `upcoming` 的版本一旦发布（mac/android 看本仓库的 `mac-v*`/`android-v*` Release，Chrome 扩展看 `v<版本>-build.<N>` 标签，浏览器控制/远程连接/电脑操作看各仓库的 `v<版本>` 标签），自动改成 `released`，日期改为真实发布日期。所以提前写好的条目放心标 `upcoming`，不用回来改。
  - 文件里还没有的新版本按两次发布之间的 feat/fix/perf 提交生成条目，带 `generated: true`；配置了 `DEEPSEEK_API_KEY` secret 时由模型改写成面向用户的中英文案。人工润色后删掉 `generated` 那一行即可，同步不会覆盖已有条目。
  - 读私有源码：mac/android 用已有的 `APP_SOURCE_TOKEN`；Chrome 扩展用 `CHROME_EXTENSION_DEPLOY_KEY`（dsh-chrome-extension 上的只读 deploy key）。
  - 本地预览：`GH_TOKEN=$(gh auth token -h github.com) LOCAL_SOURCES=~/dshapp python3 scripts/sync-changelog.py --dry-run`
- 模块名、图标、顺序与标签文案：`data/whatsnew/{zh,en}.yaml`；新增模块时在这里加一项并放一个同名 yaml。
- 模板 `layouts/_default/whatsnew.html`，筛选逻辑在 `assets/js/main.js`。某版本号与当前可下载的安装包一致时，会显示「下载此版本」。

## 目录结构

```
hugo.toml                  双语配置、站点参数、输出格式
i18n/{zh,en}.toml          界面文案（导航、按钮、页脚、404）
data/home/{zh,en}.yaml     首页文案（hero、场景、四种能力、三个深挖、三步上手、可控与安全、常见问题、CTA）
data/appmock/sessions/{zh,en}.yaml   首屏 App 复刻的演示会话与轨迹（按语言区分，只放用户能看懂的真实任务）
data/appmock/{zh,en}.yaml    App 复刻的界面文案（随语言切换）
data/opensource/{zh,en}.yaml  开源/安全/可审核详情页：三支柱、8 条安全评审、仓库清单
content/_index*.md         首页 front matter
content/products/*.md      4 个产品页（zh）+ *.en.md（en）；远程连接教程并入 android.md，旧地址走 aliases 跳转
content/opensource*.md     「开源、安全、可审核」详情页（layout: opensource）
layouts/_default/opensource.html  该详情页的版式（含评审清单与仓库网格）
content/docs/*.md          16 个文档页（zh）+ *.en.md（en）；目录分组与顺序来自各自 front matter 的 group / weight
layouts/docs/{list,single}.html   文档页的两个入口，都只调用 docs-shell
layouts/partials/docs-shell.html  文档版式：左目录 + 正文 + 右「本页目录」+ 上下页
layouts/partials/docs-nav.html    左侧目录（分组、高亮、窄屏折叠）
assets/css/                tokens → base → layout → components → sections → docs → app-mock
assets/js/main.js          抽屉导航、文档目录折叠、滚动揭示、代码复制、按键修饰符本地化
assets/js/app-mock.js      首页 App 复刻的交互（切会话、收起侧栏、追加消息）
layouts/partials/app-mock.html  首页 macOS 版块的可交互 App 界面复刻
assets/img/shots/          产品截图（Hugo Pipes 读取真实尺寸）
assets/img/logo-mark.png   品牌标志源图（带透明通道；Hugo Pipes 缩放到 4× 显示尺寸并指纹化）
static/favicon.png         标签页图标（64）
static/apple-touch-icon.png  iOS 主屏图标（180）
layouts/partials/          head / header / footer / icon / brand-logo / shot-img / sections/*
layouts/index.html         首页编排（只调用 sections/* 分片）
```

## 图标与 Logo

**图标全部是内联 SVG**（`layouts/partials/icon.html`），没有图标字体、没有外部请求、没有构建依赖。用法 `{{ partial "icon.html" "apple" }}`，未知名字回落到 `layout-grid`。

- **通用图标取自 [Lucide](https://github.com/lucide-icons/lucide)**（ISC 许可）：24 视窗、1.7 描边、圆头圆角。当前用到 37 个，含导航与文档用的 `menu download arrow-right chevron-down chevron-up check lock shield globe qr terminal cu grid`，以及首页 App 复刻用的 `panel-left settings smartphone square-pen pin arrow-up-down folder-plus archive message-square code clock chevrons-right plus paperclip send trash-2 git-branch arrow-up-right list square`。
- **品牌标志取自 [Simple Icons](https://github.com/simple-icons/simple-icons)**（CC0），实心填充：`apple / android / chrome / github`。**Lucide 已移除全部品牌标识**（仓库里没有 github / chrome / android，它的 `apple` 是水果），所以这四个不能用 Lucide 替代。
- 加新图标：从 Lucide 取 `icons/<name>.svg`，把 `<svg>` 内部内容贴进 `$lucide` 那个 `dict`；**品牌标志要放进 `$brand` 那个 dict**（自动 `fill="currentColor"`、不描边）。注意 Go 模板字符串没有反斜杠转义，属性串必须用反引号原始字符串。
- 加完删掉没人引用的条目：`icon.html` 里的死图标会被原样内联进每一页。

**品牌标志图**走 `layouts/partials/brand-logo.html`（`{{ partial "brand-logo.html" 22 }}`），显示 22px、按 4× 生成，视网膜屏也锐利。换 logo 就替换 `assets/img/logo-mark.png`，再重新生成 favicon 与 apple-touch-icon。

## 双语

- 中文在 `/`，英文在 `/en/`，由 `hugo.toml` 的 `defaultContentLanguage = "zh"` 与 `defaultContentLanguageInSubdir = false` 决定。
- 正文用文件后缀区分：`macos.md` / `macos.en.md`；首页文案按语言分文件放在 `data/home/`。
- 界面文案走 `i18n`，导航项名称来自 `i18n` 的 `nav.*` 键，不在 `hugo.toml` 里配菜单。
- 语言切换用 `.AllTranslations` 读取真实翻译路径；**不要**用 `relLangURL` 拼语言切换链接，它会漏掉 `/en` 前缀。
- 深色是唯一主题：`html[data-theme="dark"]` + `color-scheme: dark`，没有浅色分支。

## 文档

`/docs/` 是使用文档，中英文各 16 页。三处结构决定它的样子：

### 目录分组

左侧目录的**分组顺序**写死在 `layouts/partials/docs-nav.html` 的 `$groups` 里；**组内条目与顺序**来自每个文档页 front matter 的 `group` 与 `weight`，不需要维护第二份清单。

| group | 组标题（i18n 键） |
| --- | --- |
| `start` | `docs.group.start` |
| `use` | `docs.group.use` |
| `browser` | `docs.group.browser` |
| `mobile` | `docs.group.mobile` |
| `cu` | `docs.group.cu` |
| `security` | `docs.group.security` |
| `reference` | `docs.group.reference` |

加一页文档：在 `content/docs/` 放 `slug.md` 和 `slug.en.md`，写好 `group` 与 `weight`（只属于某个端的再写 `platform`，见下）即可自动进目录。**新分组**要同时改 `docs-nav.html` 的 `$groups` 和两个 `i18n/*.toml` 的 `docs.group.<key>`。

### 按端区分（顶部选择器）

文档顶部有「全部 / macOS App / Chrome 扩展 / Android App / 微信小程序」选择器，左侧目录与上下页按所选的端筛选，并与 URL 双向同步。

- 页面属于哪个端写在 front matter 的 `platform`（`macos` / `chrome` / `android` / `miniapp`）；**不写 = 各端通用**（权限、可审核性、FAQ、排错、概览）。电脑操作归在 `macos`。
- 一页同时属于几个端时写成列表，第一项是主端：配对与加密是 `platform: ["android", "miniapp"]`，默认按 Android 显示，在小程序视图里带 `?platform=miniapp` 留在本页。解析统一走 `layouts/partials/docs/page-platforms.html`。
- 当前端 = URL 的 `?platform=` → 页面自己的 `platform` → `all`。专属页的 URL 本身就代表端（`/docs/install-chrome/` 即 Chrome），通用页用 `?platform=chrome` 记住端。
- 在通用页上切端：不刷新，`pushState` 改 `?platform=`，前进后退可用；在专属页上切到别的端：跳到那个端的第一页（按 `weight`，即它的安装页）。`?platform=` 指向与专属页冲突的端时，同样直接跳过去。
- 站内指向通用页的文档链接（目录、正文、上下页、顶部「文档」、语言切换）会自动带上当前端，所以从 macOS 的页面点进「权限分级」仍停在 macOS 视图。
- 实现：选择器在 `layouts/partials/docs-platforms.html`（都是真链接，无 JS 也能用）；端列表在 `docs-shell.html` 的 `$platforms`；目录条目/分组上的 `data-for-platform` 由 `docs-nav.html` 生成，`docs.css` 按 `.docs-shell[data-platform]` 隐藏；`docs-shell.html` 里一段内联脚本在首屏前读 `?platform=`，避免目录闪一下；其余逻辑在 `main.js`「文档：按端筛选」。**新增一个端**要改 `$platforms`、两个 `i18n/*.toml` 的 `docs.platform.<key>` 和 `docs.css` 里按端筛选的规则。

### 版式

`docs-shell.html` 是三栏：左目录 240 / 正文 672 / 右「本页目录」200。右侧目录直接用 Hugo 的 `.TableOfContents`，不用写 JS。页面标题里的 `## 小节` 会自动出现在右侧目录里。

### 窄屏

≤900px 时左目录折进原生 `<details>`：默认收起、`summary` 显示当前页，靠 `main.js` 里的 `matchMedia` 按宽度定初始状态，无 JS 也可用（默认展开）。开关图标用 `chevron-down` / `chevron-up` **换图标**而不是 CSS `rotate` —— 内联 SVG 上的 `transform` 在部分渲染路径下不生效。

## 首屏里的可交互 App 界面

首页**首屏**（hero）第一个窗口不是截图，而是一块**用真实 HTML/CSS 复刻的 Mac App 界面**（`layouts/partials/app-mock.html`），替换掉了原来的 `macos-app.jpg`。它可点击、可输入，但只做产品展示：数据全部写死，不发请求、不接真实 Agent。`#macos` 版块因此只保留一段文案，不再重复放窗口。

> 这里的教训：**改之前先确认改动落在页面哪个位置**。Mock 最初只加在 `#macos` 版块（首屏之下），首屏仍是原截图，肉眼打开页面看到的还是图 —— 等于没改。要替换的是用户第一眼看到的那块。

| 文件 | 作用 |
| --- | --- |
| `layouts/partials/sections/hero.html` | 首屏：承载 Mock，并在窄屏渲染静态截图兜底 |
| `layouts/partials/app-mock.html` | 界面结构（侧栏 / 工具栏 / 轨迹 / 输入区） |
| `assets/css/app-mock.css` | 全部样式，收在 `.appmock` 作用域内 |
| `assets/js/app-mock.js` | 交互：切会话、收起侧栏、追加消息 |
| `data/appmock/sessions/{zh,en}.yaml` | 演示会话与轨迹（**按语言区分**；不要放内部项目或英文推理过程） |
| `data/appmock/{zh,en}.yaml` | 应用自身的界面文案（随语言切换） |

只有应用 UI 文案随语言切换；会话标题与轨迹是用户数据，中英一致（真实 App 里用户的会话名不会因为界面语言改变）。

### 1:1 是怎么做到的

画布固定 **1229×768**，所有数值就是 `assets/img/shots/macos-app.jpg` 上实测的像素坐标，改样式时直接对着截图量。已核对到位的关键坐标：

| 部位 | 截图 | Mock |
| --- | --- | --- |
| 侧栏宽 | 258 | 258 |
| 搜索框 | x21 y58 w223 | x21 y58 w223 |
| 工具栏高 | ~44 | 44 |
| 输入卡片 | x301～1184 | x302～1185 |
| 发送/停止按钮 | y722 | y720 |

缩放用容器查询单位，**不需要 JS 也不需要 ResizeObserver**：

```css
.appmock        { container-type: inline-size; aspect-ratio: 1229 / 768; }
.appmock__stage { width: 1229px; height: 768px; transform-origin: 0 0;
                  transform: scale(calc(100cqw / 1229px)); }
```

长度相除得到纯数，所以容器多宽就缩放多少。上界靠外层 `.shot-frame--appmock { max-width: 1229px }` 夹住，同时 `.hero__shot-inner` 也调到 1229px —— 比 1229px 更宽的屏幕也保持 1:1，绝不会放大。

`.appmock` 里有一行 `text-align: left` 不能删：首屏 `.hero { text-align: center }` 原本只包一个 <img> 所以无影响，放进 Mock 后会把界面里所有文字都居中。

> 注意别改回 `min(1, calc(100cqw / 1229px))`：`1` 是无单位数、后面是长度，`min()` 类型不匹配会让整条声明失效，实测会静默退化成兜底的 `scale(.9)`。

配色也**不复用站点的 `--color-*`**：macOS 原生窗口的灰阶（侧栏 `#292929`、主区 `#1e1e1e`）与站点深色主题不是一个体系，混用会污染全站 token。全部取自截图取样，收在 `.appmock` 里。

### 窄屏

`max-width: 900px` 时隐藏 Mock、退回 `macos-app.jpg` 静态图。再窄下去缩放系数不足 0.73，12.5px 正文会掉到 9px 以下，既不可读也不可点；静态图信息量相同且不损失可读性。两块的显隐都在 `app-mock.css` 末尾。

## 换截图

截图统一放在 `assets/img/shots/`，文件名与路径写在 `data/home/*.yaml` 和 `content/products/*.md` 的 `shot` / `shot2` / `heroShot` 字段里（语言无关路径，渲染时走 `relURL`）。

替换步骤：

1. 用同样的文件名覆盖 `assets/img/shots/xxx.jpg`（或改字段值）。
2. 不用手改 `width` / `height` —— `layouts/partials/shot-img.html` 通过 `resources.Get` 读取文件真实像素尺寸，自动写到 `<img>` 上，避免布局跳动。
3. `hugo --gc --minify` 重新构建。

当前使用的截图（均由真实客户端实拍）：

| 文件 | 内容 |
| --- | --- |
| `macos-app.jpg` | macOS 客户端主界面（首屏换成 App 复刻后，只剩首屏窄屏兜底 / 产品卡 / 产品页在用） |
| `macos-shortcuts.jpg` | macOS 快捷键面板 |
| `android-app.png` | Android 会话列表（已配对连接） |
| `chrome-picker.jpg` | Chrome 扩展在网页中圈选元素 |
| `chrome-sidepanel.jpg` | Chrome 侧边栏中的 DSH 面板 |
| `remote-pairing.jpg` | macOS 客户端的移动端配对页 |
| `cu.jpg` | 计算机使用能力在后台操作应用 |

## 换链接

下载地址、仓库地址等都在两处：

- `hugo.toml` 的 `[params]`：`chromeWebStore`、`github`。macOS / Android 的下载地址不用手填，见上文「下载与安装包」。
- `data/opensource/{zh,en}.yaml` 的 `repos` 列表：`/opensource/` 详情页的 GitHub 仓库卡片，只改这一处。

### 仓库状态

每张卡片带 `public: true/false`：`true` 显示绿色「已开源」，`false` 显示「尚未公开」并降低不透明度。**这个标记要跟仓库真实可见性一致** —— 私有仓库的链接匿名访问是 404，标错会让人点到死链。当前 5 个公开（全部 MIT）、3 个未公开（`dsh-macapp` / `dsh-androidapp` / `dsh-chrome-extension`，它们也是仅有的三个没有 LICENSE 文件的仓库）；这三个仓库公开后把 `public` 改成 `true`、`tag` 改成 `MIT` 即可。

### 右上角 GitHub 按钮

头部右上角那个 GitHub 图标按**当前页面**切换仓库地址，新标签页打开：产品页读自己 front matter 里的 `repo`，没有声明的页面（首页、`/opensource/`、`/products/`）回落到 `hugo.toml` 的 `github`（主仓库）。

| 页面 | 仓库 |
| --- | --- |
| `/products/macos/` | `dshapp/dsh-macapp` |
| `/products/android/` | `dshapp/dsh-androidapp` |
| `/products/chrome/` | `dshapp/dsh-chrome-extension` |
| `/products/cu/` | `dshapp/dsh-kimi-computer-use` |
| 其它页面 | `deepseek-ai/deepseek-harness` |

**注意**：macOS / Android / Chrome 扩展对应的三个仓库目前仍是私有的（匿名 404），所以这三个页面上的按钮现在会跳到 GitHub 的 404 页。仓库公开后无需改代码，按钮自然生效。

### 安全评审内容

`data/opensource/*.yaml` 的 `audit` 数组对应 `SECURITY-REVIEW-dsh-mobile-bridge.md` 的 8 个发现。`severity` 是给人看的文案，`level` 决定配色类名（`critical` / `high` / `medium` / `low`）—— 版式里用 id→class 的映射表，所以中文严重度也能拿到正确样式。评审有更新时，这份数据和该报告要一起改。

改完重新构建即可。

## 设计约定

- 颜色、圆角、缓动、层级、字号全部来自 `assets/css/tokens.css`，新增样式只引用变量，不写死色值。
- 复用现有类名（`card` / `grid grid-3` / `section` / `feature__list` / `shot-frame`）组合新板块，不重复造轮子。
- 字体只内置 Inter Variable（OFL 许可）。Linear 自有的 Berkeley Mono 是商业字体，未随仓库分发，等宽字体回退到系统。
- 未引用 Linear 的专有插画或素材，只对齐了数值与版式。
