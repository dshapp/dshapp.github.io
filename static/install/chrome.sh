#!/usr/bin/env bash
# DSH Chrome 扩展 —— 一键检查 / 安装本机依赖(macOS、Linux)
#
#   curl -fsSL https://dshapp.github.io/install/chrome.sh | bash
#   curl -fsSL https://dshapp.github.io/install/chrome.sh | bash -s -- --check   # 只检查,不安装
#
# 依次确保:Node.js >= 22.19 → pnpm >= 10 → dsh(@deepseek-ai/dsh)→ dsh-chrome-control
# 插件 → 启动一次 dsh web,让插件注册 Chrome 的本地启动器(Native Messaging host
# com.dsh.chrome)。已经满足的步骤一律跳过,可以放心重复运行。
#
# 与 DSH macOS App 的做法保持一致:Node 取 nodejs.org 的官方 LTS 安装包(校验
# SHA-256 后用 Apple 安装器安装),dsh / pnpm 用 npm 全局安装;npm 全局目录属于
# root 时(官方 .pkg 的默认情况)才用 sudo。
#
# 可选环境变量:
#   DSH_NPM_REGISTRY   npm 源,默认 https://registry.npmjs.org
#   DSH_HOME           dsh 数据目录,默认 ~/.dsh
#   DSH_WEB_PORT       dsh web 端口,默认 3080(扩展只认 127.0.0.1:3080,一般不要改)

# 整个脚本包在 main 里、最后一行才调用:curl 中途断开时,bash 只会读到半截函数
# 定义而不会执行半截命令。
main() {
  set -u

  local MIN_NODE="22.19.0"
  local MIN_PNPM_MAJOR=10
  local REGISTRY="${DSH_NPM_REGISTRY:-https://registry.npmjs.org}"
  local DSH_DIR="${DSH_HOME:-$HOME/.dsh}"
  local PORT="${DSH_WEB_PORT:-3080}"
  local PROFILE="web"
  local PLUGIN="dsh-chrome-control"
  local EXT_ID="kgjjicancjnedmappjhefngdjaommpop"
  local DOCS_ZH="https://dshapp.github.io/docs/install-chrome/"
  local DOCS_EN="https://dshapp.github.io/en/docs/install-chrome/"
  local CHECK_ONLY=0
  local arg
  for arg in "$@"; do
    case "$arg" in
      --check|-c) CHECK_ONLY=1 ;;
      --help|-h) sed -n '2,20p' "$0" 2>/dev/null || true; return 0 ;;
    esac
  done

  # ---- 语言与输出 ----
  local ZH=0
  case "${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}" in zh*) ZH=1 ;; esac
  if [ "$ZH" = 0 ] && [ "$(uname -s)" = "Darwin" ]; then
    defaults read -g AppleLanguages 2>/dev/null | head -2 | grep -q 'zh' && ZH=1
  fi
  t() { if [ "$ZH" = 1 ]; then printf '%s' "$1"; else printf '%s' "$2"; fi; }

  local C_OK="" C_ERR="" C_WARN="" C_DIM="" C_B="" C_0=""
  if [ -t 1 ]; then
    C_OK=$'\033[32m'; C_ERR=$'\033[31m'; C_WARN=$'\033[33m'; C_DIM=$'\033[2m'; C_B=$'\033[1m'; C_0=$'\033[0m'
  fi
  local STEP=0 TOTAL=5 FAILED=0
  step() { STEP=$((STEP + 1)); printf '\n%s[%d/%d] %s%s\n' "$C_B" "$STEP" "$TOTAL" "$1" "$C_0"; }
  ok()   { printf '  %s✓%s %s\n' "$C_OK" "$C_0" "$1"; }
  info() { printf '  %s→%s %s\n' "$C_DIM" "$C_0" "$1"; }
  warn() { printf '  %s!%s %s\n' "$C_WARN" "$C_0" "$1"; }
  fail() { printf '  %s✗%s %s\n' "$C_ERR" "$C_0" "$1"; FAILED=1; }
  # 致命:后续步骤都依赖它,直接收尾。
  die()  { fail "$1"; finish; exit 1; }
  finish() {
    printf '\n'
    if [ "$FAILED" = 0 ]; then
      if [ "$CHECK_ONLY" = 1 ]; then
        printf '%s%s%s\n' "$C_OK" "$(t "检查完成:依赖都已就绪。" "Check complete: everything is in place.")" "$C_0"
      else
        printf '%s%s%s\n' "$C_OK" "$(t "完成!回到 Chrome,DSH 扩展会自动连接。" "Done! Switch back to Chrome — the DSH extension connects on its own.")" "$C_0"
      fi
    else
      printf '%s%s%s\n' "$C_ERR" "$(t "有步骤没有完成,按上面的提示处理后重新运行本命令即可。" "Some steps did not finish. Fix the items above, then run this command again.")" "$C_0"
      printf '%s %s\n' "$(t "安装文档:" "Setup guide:")" "$(t "$DOCS_ZH" "$DOCS_EN")"
    fi
  }

  # ---- 工具函数 ----
  have() { command -v "$1" >/dev/null 2>&1; }
  # a >= b(点分版本号,只比数字段)
  ver_ge() {
    awk -v a="$1" -v b="$2" 'BEGIN {
      n = split(a, x, "."); m = split(b, y, ".");
      for (i = 1; i <= (n > m ? n : m); i++) { p = x[i] + 0; q = y[i] + 0; if (p > q) exit 0; if (p < q) exit 1 }
      exit 0 }'
  }
  node_version() { node -v 2>/dev/null | sed 's/^v//'; }
  port_open() { (exec 3<>"/dev/tcp/127.0.0.1/$1") >/dev/null 2>&1; }
  path_prepend() { case ":$PATH:" in *":$1:"*) ;; *) PATH="$1:$PATH"; export PATH ;; esac; }

  local OS
  OS="$(uname -s)"
  case "$OS" in
    Darwin|Linux) ;;
    *) die "$(t "不支持的系统:$OS。Windows 请使用 PowerShell 版脚本(见安装文档)。" "Unsupported system: $OS. On Windows use the PowerShell script (see the setup guide).")" ;;
  esac

  # 已知的 pnpm / npm 全局 bin 目录:用户可能装过但这个 shell 的 PATH 里没有。
  local d
  for d in "$HOME/Library/pnpm" "$HOME/.local/share/pnpm" /opt/homebrew/bin /usr/local/bin; do
    [ -d "$d" ] && path_prepend "$d"
  done

  printf '%s%s%s\n' "$C_B" "$(t "DSH Chrome 扩展 · 本机依赖检查与安装" "DSH Chrome extension · local setup")" "$C_0"
  [ "$CHECK_ONLY" = 1 ] && info "$(t "只检查模式:不会安装或启动任何东西。" "Check-only mode: nothing will be installed or started.")"

  # npm 全局安装;全局目录不可写(官方 .pkg 装的 Node)时才 sudo。
  # 目录(或它尚不存在时最近的已存在上级)可写。全新的自定义 prefix 下
  # lib/node_modules 往往还没建,不能因此误判成要 sudo。
  writable_dir() {
    local p="$1"
    while [ -n "$p" ] && [ ! -e "$p" ]; do p="$(dirname "$p")"; done
    [ -n "$p" ] && [ -w "$p" ]
  }
  npm_global() {
    local root
    root="$(npm root -g 2>/dev/null)"
    if [ -n "$root" ] && writable_dir "$root"; then
      npm install --global --no-fund --no-audit --registry "$REGISTRY" "$@"
    else
      info "$(t "npm 全局目录需要管理员权限,可能会要求输入开机密码。" "npm's global directory needs admin rights; you may be asked for your password.")"
      sudo env "PATH=$PATH" npm install --global --no-fund --no-audit --registry "$REGISTRY" "$@"
    fi
    local status=$?
    hash -r 2>/dev/null
    # npm 全局 bin 不在 PATH 上时补进本次会话(nvm/自定义 prefix)。
    local prefix
    prefix="$(npm prefix -g 2>/dev/null)"
    [ -n "$prefix" ] && [ -d "$prefix/bin" ] && path_prepend "$prefix/bin"
    return $status
  }

  install_node_macos() {
    if have brew; then
      info "$(t "使用 Homebrew 安装 Node.js…" "Installing Node.js with Homebrew…")"
      brew install node || return 1
      return 0
    fi
    local version tmp pkg expected actual
    info "$(t "正在从 nodejs.org 获取当前 LTS 版本…" "Looking up the current LTS release on nodejs.org…")"
    version="$(curl -fsSL https://nodejs.org/dist/index.json | tr '}' '\n' | grep '"lts":"' | head -1 | sed -E 's/.*"version":"v([0-9.]+)".*/\1/')"
    if [ -z "$version" ] || ! ver_ge "$version" "$MIN_NODE"; then
      fail "$(t "没有拿到可用的 Node.js LTS 版本信息。" "Could not determine a suitable Node.js LTS release.")"; return 1
    fi
    tmp="$(mktemp -d)"; pkg="$tmp/node-v$version.pkg"
    info "$(t "下载 Node.js $version…" "Downloading Node.js $version…")"
    curl -fL --progress-bar -o "$pkg" "https://nodejs.org/dist/v$version/node-v$version.pkg" || { rm -rf "$tmp"; return 1; }
    expected="$(curl -fsSL "https://nodejs.org/dist/v$version/SHASUMS256.txt" | awk -v f="node-v$version.pkg" '$2 == f { print $1 }')"
    actual="$(shasum -a 256 "$pkg" | awk '{ print $1 }')"
    if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
      rm -rf "$tmp"; fail "$(t "安装包 SHA-256 校验失败,已放弃安装。" "Installer SHA-256 mismatch; aborted.")"; return 1
    fi
    info "$(t "使用 Apple 安装器安装,需要输入开机密码…" "Running Apple's installer; your password is required…")"
    sudo installer -pkg "$pkg" -target / || { rm -rf "$tmp"; return 1; }
    rm -rf "$tmp"
    path_prepend /usr/local/bin
    hash -r 2>/dev/null
  }

  # ---- 1. Node.js ----
  step "Node.js ≥ $MIN_NODE"
  local nv
  nv="$(node_version)"
  if [ -n "$nv" ] && ver_ge "$nv" "$MIN_NODE"; then
    ok "Node.js $nv"
  elif [ "$CHECK_ONLY" = 1 ]; then
    fail "$(t "未安装或版本过低" "missing or too old")${nv:+ (v$nv)}"
  elif [ "$OS" = "Darwin" ]; then
    [ -n "$nv" ] && warn "$(t "当前 Node.js $nv 低于要求,将安装新版。" "Node.js $nv is too old; installing a newer one.")"
    install_node_macos
    nv="$(node_version)"
    if [ -n "$nv" ] && ver_ge "$nv" "$MIN_NODE"; then ok "Node.js $nv"
    else die "$(t "Node.js 安装失败。可以从 https://nodejs.org 手动下载安装后重试。" "Node.js install failed. Install it from https://nodejs.org and run this again.")"; fi
  else
    die "$(t "请先用系统包管理器或 nvm 安装 Node.js $MIN_NODE 以上版本(https://nodejs.org/en/download),然后重新运行。" "Install Node.js $MIN_NODE or later with your package manager or nvm (https://nodejs.org/en/download), then run this again.")"
  fi

  # ---- 2. pnpm ----
  step "pnpm ≥ $MIN_PNPM_MAJOR"
  local pv
  pv="$(pnpm -v 2>/dev/null)"
  if [ -n "$pv" ] && [ "${pv%%.*}" -ge "$MIN_PNPM_MAJOR" ] 2>/dev/null; then
    ok "pnpm $pv"
  elif [ "$CHECK_ONLY" = 1 ]; then
    fail "$(t "未安装或版本过低(dsh 用 pnpm 安装插件)" "missing or too old (dsh installs plugins with pnpm)")"
  else
    info "$(t "dsh 用 pnpm 安装插件,正在安装 pnpm…" "dsh installs plugins with pnpm; installing pnpm…")"
    npm_global pnpm@latest
    pv="$(pnpm -v 2>/dev/null)"
    if [ -n "$pv" ] && [ "${pv%%.*}" -ge "$MIN_PNPM_MAJOR" ] 2>/dev/null; then ok "pnpm $pv"
    else die "$(t "pnpm 安装失败。" "pnpm install failed.")"; fi
  fi

  # ---- 3. dsh ----
  step "dsh (@deepseek-ai/dsh)"
  local dv
  dv="$(dsh --version 2>/dev/null)"
  if [ -n "$dv" ]; then
    ok "dsh $dv"
  elif [ "$CHECK_ONLY" = 1 ]; then
    fail "$(t "未安装" "not installed")"
  else
    info "$(t "正在安装 dsh…" "Installing dsh…")"
    npm_global @deepseek-ai/dsh@latest
    dv="$(dsh --version 2>/dev/null)"
    if [ -n "$dv" ]; then ok "dsh $dv"; else die "$(t "dsh 安装失败。" "dsh install failed.")"; fi
  fi

  # ---- 4. dsh-chrome-control ----
  step "$PLUGIN"
  local profile_pkg="$DSH_DIR/profiles/$PROFILE/package.json"
  if [ -f "$profile_pkg" ] && grep -q "\"$PLUGIN\"" "$profile_pkg"; then
    ok "$(t "已安装到 $PROFILE profile" "installed in the $PROFILE profile")"
  elif [ "$CHECK_ONLY" = 1 ]; then
    fail "$(t "未安装" "not installed")"
  else
    info "dsh plugin --profile $PROFILE add $PLUGIN"
    if dsh plugin --profile "$PROFILE" add "$PLUGIN" && [ -f "$profile_pkg" ] && grep -q "\"$PLUGIN\"" "$profile_pkg"; then
      ok "$(t "插件已安装" "plugin installed")"
    else
      die "$(t "插件安装失败,请查看上面的 pnpm 输出。" "Plugin install failed; see pnpm's output above.")"
    fi
  fi

  # ---- 5. 本地启动器 + dsh web ----
  step "$(t "本地启动器(Chrome Native Messaging)" "Local launcher (Chrome Native Messaging)")"
  local manifest
  if [ "$OS" = "Darwin" ]; then
    manifest="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.dsh.chrome.json"
  else
    manifest="${XDG_CONFIG_HOME:-$HOME/.config}/google-chrome/NativeMessagingHosts/com.dsh.chrome.json"
  fi
  registered() { [ -f "$manifest" ] && grep -q "$EXT_ID" "$manifest"; }

  if registered; then
    ok "$(t "已注册" "registered")"
    if port_open "$PORT"; then ok "$(t "dsh web 正在运行(127.0.0.1:$PORT)" "dsh web is running (127.0.0.1:$PORT)")"
    else info "$(t "dsh web 未运行;扩展需要时会自动启动它。" "dsh web is not running; the extension starts it when needed.")"; fi
  elif [ "$CHECK_ONLY" = 1 ]; then
    fail "$(t "未注册(启动一次 dsh web 即可注册)" "not registered (starting dsh web once registers it)")"
  elif port_open "$PORT"; then
    # 端口上已有服务,但它没有注册启动器:多半是装插件之前就启动的 dsh web。
    # 不替用户杀进程 —— 里面可能有正在跑的会话。
    fail "$(t "127.0.0.1:$PORT 上已有 dsh web 在运行,但它是在装插件之前启动的。请关掉它(在运行它的终端按 Ctrl+C),再重新运行本命令。" "dsh web is already running on 127.0.0.1:$PORT but was started before the plugin was installed. Stop it (Ctrl+C in its terminal), then run this command again.")"
  else
    mkdir -p "$DSH_DIR/logs"
    local log="$DSH_DIR/logs/install-dsh-web.log"
    info "$(t "启动 dsh web(后台运行,日志:$log)…" "Starting dsh web in the background (log: $log)…")"
    nohup dsh web --no-open --port "$PORT" >>"$log" 2>&1 </dev/null &
    disown 2>/dev/null || true
    local _
    for _ in $(seq 1 90); do
      registered && port_open "$PORT" && break
      sleep 1
    done
    if registered; then
      ok "$(t "已注册" "registered")"
      if port_open "$PORT"; then ok "$(t "dsh web 已启动(127.0.0.1:$PORT)" "dsh web started (127.0.0.1:$PORT)")"
      else warn "$(t "dsh web 还没起来,查看日志:$log" "dsh web is not up yet; see $log")"; fi
    else
      fail "$(t "等了 90 秒仍未注册。请确认已安装 Google Chrome,并查看日志:$log" "Still not registered after 90s. Make sure Google Chrome is installed and check $log")"
    fi
  fi

  finish
  [ "$FAILED" = 0 ]
}

main "$@"
