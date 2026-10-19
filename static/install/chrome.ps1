# DSH Chrome 扩展 —— 一键检查 / 安装本机依赖(Windows 10/11)
#
# 在「命令提示符」(cmd)或 PowerShell 中粘贴执行:
#
#   powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=3072; iex ([Text.Encoding]::UTF8.GetString((New-Object Net.WebClient).DownloadData('https://dshapp.github.io/install/chrome.ps1')))"
#
# 这行命令刻意不含 "$":粘进 PowerShell 时外层双引号不会先展开变量,粘进 cmd 时
# 也没有需要转义的字符;按字节下载再按 UTF-8 解码,中文提示不受系统代码页影响。
#
# 只检查、不安装:先在 cmd 里执行 set DSH_CHECK_ONLY=1(PowerShell 里是
# $env:DSH_CHECK_ONLY='1'),再执行上面那行。
#
# 依次确保:Node.js >= 22.19 → pnpm >= 10 → dsh(@deepseek-ai/dsh)→ dsh-chrome-control
# 插件 → 启动一次 dsh web,让插件把 Chrome 的本地启动器 com.dsh.chrome 注册到
# HKCU\Software\Google\Chrome\NativeMessagingHosts。已满足的步骤一律跳过,可重复运行。
#
# 可选环境变量:DSH_NPM_REGISTRY(默认 https://registry.npmjs.org)、DSH_HOME
# (默认 %USERPROFILE%\.dsh)、DSH_WEB_PORT(默认 3080,扩展只认 3080,一般不要改)。

& {
  Set-StrictMode -Version 2
  $ErrorActionPreference = 'Continue'
  try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch { }

  $MinNode = [version]'22.19.0'
  $MinPnpmMajor = 10
  $Registry = if ($env:DSH_NPM_REGISTRY) { $env:DSH_NPM_REGISTRY } else { 'https://registry.npmjs.org' }
  $DshDir = if ($env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $env:USERPROFILE '.dsh' }
  $Port = if ($env:DSH_WEB_PORT) { [int]$env:DSH_WEB_PORT } else { 3080 }
  $Profile_ = 'web'
  $Plugin = 'dsh-chrome-control'
  $ExtId = 'kgjjicancjnedmappjhefngdjaommpop'
  $HostKey = 'HKCU:\Software\Google\Chrome\NativeMessagingHosts\com.dsh.chrome'
  $CheckOnly = ($env:DSH_CHECK_ONLY -eq '1')
  $Zh = (Get-UICulture).Name -like 'zh*'

  $script:Step = 0
  $script:Failed = $false
  function T([string]$zh, [string]$en) { if ($Zh) { $zh } else { $en } }
  function Step([string]$title) { $script:Step++; Write-Host ''; Write-Host ("[{0}/5] {1}" -f $script:Step, $title) -ForegroundColor White }
  function Ok([string]$m) { Write-Host "  [OK] $m" -ForegroundColor Green }
  function Info([string]$m) { Write-Host "  ->  $m" -ForegroundColor DarkGray }
  function Warn([string]$m) { Write-Host "  [!] $m" -ForegroundColor Yellow }
  function Fail([string]$m) { Write-Host "  [X] $m" -ForegroundColor Red; $script:Failed = $true }

  function Finish {
    Write-Host ''
    if (-not $script:Failed) {
      if ($CheckOnly) { Write-Host (T '检查完成:依赖都已就绪。' 'Check complete: everything is in place.') -ForegroundColor Green }
      else { Write-Host (T '完成!回到 Chrome,DSH 扩展会自动连接。' 'Done! Switch back to Chrome - the DSH extension connects on its own.') -ForegroundColor Green }
    } else {
      Write-Host (T '有步骤没有完成,按上面的提示处理后重新运行本命令即可。' 'Some steps did not finish. Fix the items above, then run this command again.') -ForegroundColor Red
      Write-Host ((T '安装文档:' 'Setup guide: ') + (T 'https://dshapp.github.io/docs/install-chrome/' 'https://dshapp.github.io/en/docs/install-chrome/'))
    }
  }

  # 重新读取注册表里的 PATH:winget / msi / npm 改的是持久化的环境变量,本进程看不到。
  function Refresh-Path {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $extra = @((Join-Path $env:APPDATA 'npm'), (Join-Path $env:ProgramFiles 'nodejs'))
    $env:Path = (@($machine, $user) + $extra | Where-Object { $_ }) -join ';'
  }

  function Get-Exe([string]$name) {
    $cmd = Get-Command "$name.cmd" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $cmd) { $cmd = Get-Command "$name.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 }
    if ($cmd) { return $cmd.Source }
    return $null
  }

  function Get-NodeVersion {
    $node = Get-Exe 'node'
    if (-not $node) { return $null }
    $raw = (& $node -v 2>$null | Out-String).Trim().TrimStart('v')
    try { return [version]$raw } catch { return $null }
  }

  # 工具输出直接打到终端(Out-Host),函数本身只返回成功与否 —— 否则输出会混进返回值。
  function Invoke-Tool([string]$exe, [string[]]$arguments) {
    & $exe @arguments | Out-Host
    return ($LASTEXITCODE -eq 0)
  }

  function Install-NpmGlobal([string]$spec) {
    $npm = Get-Exe 'npm'
    if (-not $npm) { return $false }
    $okay = Invoke-Tool $npm @('install', '--global', '--no-fund', '--no-audit', '--registry', $Registry, $spec)
    Refresh-Path
    return $okay
  }

  function Install-Node {
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($winget) {
      Info (T '使用 winget 安装 Node.js LTS…' 'Installing Node.js LTS with winget…')
      & $winget.Source install --id OpenJS.NodeJS.LTS -e --silent --accept-source-agreements --accept-package-agreements | Out-Host
      Refresh-Path
      if (Get-NodeVersion) { return }
      Warn (T 'winget 未完成安装,改用 nodejs.org 安装包。' 'winget did not finish; falling back to the nodejs.org installer.')
    }
    Info (T '正在从 nodejs.org 获取当前 LTS 版本…' 'Looking up the current LTS release on nodejs.org…')
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'x64' }
    $release = Invoke-RestMethod -UseBasicParsing 'https://nodejs.org/dist/index.json' |
      Where-Object { $_.lts -and ($_.files -contains "win-$arch-msi") } | Select-Object -First 1
    if (-not $release) { throw (T '没有拿到可用的 Node.js LTS 版本信息。' 'Could not determine a Node.js LTS release.') }
    $version = $release.version
    $file = "node-$version-$arch.msi"
    $msi = Join-Path $env:TEMP $file
    Info (T "下载 Node.js $version…" "Downloading Node.js $version…")
    Invoke-WebRequest -UseBasicParsing "https://nodejs.org/dist/$version/$file" -OutFile $msi
    $sums = (Invoke-WebRequest -UseBasicParsing "https://nodejs.org/dist/$version/SHASUMS256.txt").Content
    $expected = ($sums -split "`n" | Where-Object { $_ -match "\s$([regex]::Escape($file))\s*$" } | ForEach-Object { ($_ -split '\s+')[0] }) | Select-Object -First 1
    $actual = (Get-FileHash -Algorithm SHA256 $msi).Hash
    if (-not $expected -or ($expected -ne $actual)) { Remove-Item $msi -ErrorAction SilentlyContinue; throw (T '安装包 SHA-256 校验失败,已放弃安装。' 'Installer SHA-256 mismatch; aborted.') }
    Info (T '运行安装程序(会弹出管理员授权)…' 'Running the installer (an admin prompt will appear)…')
    $p = Start-Process msiexec.exe -ArgumentList @('/i', "`"$msi`"", '/passive', '/norestart') -Wait -PassThru
    Remove-Item $msi -ErrorAction SilentlyContinue
    if ($p.ExitCode -ne 0 -and $p.ExitCode -ne 3010) { throw "msiexec exit $($p.ExitCode)" }
    Refresh-Path
  }

  function Test-Port([int]$port) {
    $client = New-Object Net.Sockets.TcpClient
    try {
      $async = $client.BeginConnect('127.0.0.1', $port, $null, $null)
      return ($async.AsyncWaitHandle.WaitOne(800) -and $client.Connected)
    } catch { return $false } finally { $client.Close() }
  }

  function Test-HostRegistered {
    try {
      $manifest = (Get-ItemProperty -Path $HostKey -ErrorAction Stop).'(default)'
      if (-not $manifest -or -not (Test-Path $manifest)) { return $false }
      return ((Get-Content -Raw $manifest) -match $ExtId)
    } catch { return $false }
  }

  Write-Host (T 'DSH Chrome 扩展 · 本机依赖检查与安装' 'DSH Chrome extension · local setup') -ForegroundColor White
  if ($CheckOnly) { Info (T '只检查模式:不会安装或启动任何东西。' 'Check-only mode: nothing will be installed or started.') }
  Refresh-Path

  # ---- 1. Node.js ----
  Step "Node.js >= $MinNode"
  $nv = Get-NodeVersion
  if ($nv -and $nv -ge $MinNode) { Ok "Node.js $nv" }
  elseif ($CheckOnly) { Fail (T '未安装或版本过低' 'missing or too old') }
  else {
    if ($nv) { Warn (T "当前 Node.js $nv 低于要求,将安装新版。" "Node.js $nv is too old; installing a newer one.") }
    try { Install-Node } catch { Fail $_.Exception.Message }
    $nv = Get-NodeVersion
    if ($nv -and $nv -ge $MinNode) { Ok "Node.js $nv" }
    else { Fail (T 'Node.js 安装失败。可以从 https://nodejs.org 手动下载安装后,重新打开命令提示符再运行。' 'Node.js install failed. Install it from https://nodejs.org, open a new terminal and run this again.'); Finish; return }
  }

  # ---- 2. pnpm ----
  Step "pnpm >= $MinPnpmMajor"
  function Get-PnpmVersion { $p = Get-Exe 'pnpm'; if ($p) { (& $p -v 2>$null | Out-String).Trim() } else { $null } }
  $pv = Get-PnpmVersion
  if ($pv -and [int]($pv.Split('.')[0]) -ge $MinPnpmMajor) { Ok "pnpm $pv" }
  elseif ($CheckOnly) { Fail (T '未安装或版本过低(dsh 用 pnpm 安装插件)' 'missing or too old (dsh installs plugins with pnpm)') }
  else {
    Info (T 'dsh 用 pnpm 安装插件,正在安装 pnpm…' 'dsh installs plugins with pnpm; installing pnpm…')
    [void](Install-NpmGlobal 'pnpm@latest')
    $pv = Get-PnpmVersion
    if ($pv -and [int]($pv.Split('.')[0]) -ge $MinPnpmMajor) { Ok "pnpm $pv" }
    else { Fail (T 'pnpm 安装失败。' 'pnpm install failed.'); Finish; return }
  }

  # ---- 3. dsh ----
  Step 'dsh (@deepseek-ai/dsh)'
  function Get-DshVersion { $d = Get-Exe 'dsh'; if ($d) { (& $d --version 2>$null | Out-String).Trim() } else { $null } }
  $dv = Get-DshVersion
  if ($dv) { Ok "dsh $dv" }
  elseif ($CheckOnly) { Fail (T '未安装' 'not installed') }
  else {
    Info (T '正在安装 dsh…' 'Installing dsh…')
    [void](Install-NpmGlobal '@deepseek-ai/dsh@latest')
    $dv = Get-DshVersion
    if ($dv) { Ok "dsh $dv" } else { Fail (T 'dsh 安装失败。' 'dsh install failed.'); Finish; return }
  }

  # ---- 4. dsh-chrome-control ----
  Step $Plugin
  $profilePkg = Join-Path $DshDir "profiles\$Profile_\package.json"
  function Test-Plugin { (Test-Path $profilePkg) -and ((Get-Content -Raw $profilePkg) -match ('"' + [regex]::Escape($Plugin) + '"')) }
  if (Test-Plugin) { Ok (T "已安装到 $Profile_ profile" "installed in the $Profile_ profile") }
  elseif ($CheckOnly) { Fail (T '未安装' 'not installed') }
  else {
    Info "dsh plugin --profile $Profile_ add $Plugin"
    $okay = Invoke-Tool (Get-Exe 'dsh') @('plugin', '--profile', $Profile_, 'add', $Plugin)
    if ($okay -and (Test-Plugin)) { Ok (T '插件已安装' 'plugin installed') }
    else { Fail (T '插件安装失败,请查看上面的 pnpm 输出。' "Plugin install failed; see pnpm's output above."); Finish; return }
  }

  # ---- 5. 本地启动器 + dsh web ----
  Step (T '本地启动器(Chrome Native Messaging)' 'Local launcher (Chrome Native Messaging)')
  if (Test-HostRegistered) {
    Ok (T '已注册' 'registered')
    if (Test-Port $Port) { Ok (T "dsh web 正在运行(127.0.0.1:$Port)" "dsh web is running (127.0.0.1:$Port)") }
    else { Info (T 'dsh web 未运行;扩展需要时会自动启动它。' 'dsh web is not running; the extension starts it when needed.') }
  }
  elseif ($CheckOnly) { Fail (T '未注册(启动一次 dsh web 即可注册)' 'not registered (starting dsh web once registers it)') }
  elseif (Test-Port $Port) {
    # 端口上已有服务但没注册启动器:多半是装插件之前启动的 dsh web。不替用户结束它。
    Fail (T "127.0.0.1:$Port 上已有 dsh web 在运行,但它是在装插件之前启动的。请关掉它(在运行它的窗口按 Ctrl+C),再重新运行本命令。" "dsh web is already running on 127.0.0.1:$Port but was started before the plugin was installed. Stop it (Ctrl+C in its window), then run this command again.")
  }
  else {
    $logs = Join-Path $DshDir 'logs'
    New-Item -ItemType Directory -Force -Path $logs | Out-Null
    $log = Join-Path $logs 'install-dsh-web.log'
    Info (T "启动 dsh web(后台运行,日志:$log)…" "Starting dsh web in the background (log: $log)…")
    # cmd /c 负责把 stdout/stderr 追加进同一个日志;窗口隐藏,关掉当前终端也不影响它。
    Start-Process -FilePath $env:ComSpec -WindowStyle Hidden -ArgumentList @('/s', '/c', "`"`"$(Get-Exe 'dsh')`" web --no-open --port $Port >> `"$log`" 2>&1`"") | Out-Null
    $deadline = (Get-Date).AddSeconds(90)
    while ((Get-Date) -lt $deadline) {
      if ((Test-HostRegistered) -and (Test-Port $Port)) { break }
      Start-Sleep -Seconds 1
    }
    if (Test-HostRegistered) {
      Ok (T '已注册' 'registered')
      if (Test-Port $Port) { Ok (T "dsh web 已启动(127.0.0.1:$Port)" "dsh web started (127.0.0.1:$Port)") }
      else { Warn (T "dsh web 还没起来,查看日志:$log" "dsh web is not up yet; see $log") }
    } else {
      Fail (T "等了 90 秒仍未注册。请确认 dsh-chrome-control 是支持 Windows 的新版本(dsh plugin --profile web update dsh-chrome-control),并查看日志:$log" "Still not registered after 90s. Make sure dsh-chrome-control is a release with Windows support (dsh plugin --profile web update dsh-chrome-control) and check $log")
    }
  }

  Finish
}
