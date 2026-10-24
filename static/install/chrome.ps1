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
# 插件(>= 0.3.14,更早的版本在 Windows 上不注册启动器;且在 web profile 里处于启用状态)
# → 启动一次 dsh web,让插件把 Chrome 的本地启动器 com.dsh.chrome 注册到
# HKCU\Software\Google\Chrome\NativeMessagingHosts。已满足的步骤一律跳过,可重复运行。
#
# 本脚本在后台启动的 dsh web 以「cmd.exe 命令行里带 install-dsh-web.log」为标记:没注册
# 成功时脚本会自己结束它;下次运行发现它还占着端口(例如更早版本的脚本留下的)也会结束它。
# 用户自己启动的 dsh web 一律不碰,只提示 PID。
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
  $MinPlugin = [version]'0.3.14'   # 第一个在 Windows 上注册 com.dsh.chrome 的版本
  $LogName = 'install-dsh-web.log'
  $ExtId = 'kgjjicancjnedmappjhefngdjaommpop'
  $HostKey = 'HKCU:\Software\Google\Chrome\NativeMessagingHosts\com.dsh.chrome'
  $CheckOnly = ($env:DSH_CHECK_ONLY -eq '1')
  $Zh = (Get-UICulture).Name -like 'zh*'

  $script:Step = 0
  $script:Failed = $false
  # 参数不能叫 $zh:PowerShell 变量名不分大小写,会遮住外面的 $Zh,结果永远输出中文。
  function T([string]$cn, [string]$en) { if ($Zh) { $cn } else { $en } }
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

  # "0.3.14" / "v0.3.14-rc.1" → [version]0.3.14;解析不了返回 $null。
  function ConvertTo-Version([string]$text) {
    if ($text -match '^\s*v?(\d+)\.(\d+)\.(\d+)') { return [version]('{0}.{1}.{2}' -f $Matches[1], $Matches[2], $Matches[3]) }
    return $null
  }

  # StrictMode 下读不存在的属性会抛错,JSON 字段一律经这里取。
  function Get-Prop($object, [string]$name) {
    if ($null -eq $object) { return $null }
    $property = $object.PSObject.Properties[$name]
    if ($property) { return $property.Value }
    return $null
  }

  function Read-Json([string]$file) {
    try { if (Test-Path -LiteralPath $file) { return (Get-Content -Raw -Encoding UTF8 -LiteralPath $file | ConvertFrom-Json) } } catch { }
    return $null
  }

  $profileDir = Join-Path $DshDir "profiles\$Profile_"
  $profilePkg = Join-Path $profileDir 'package.json'
  # pnpm 把插件链接在 node_modules 下(Windows 上是 junction),Get-Content 会跟随过去。
  $pluginPkg = Join-Path $profileDir "node_modules\$Plugin\package.json"

  # Declared:profile 的 dependencies 里有它。Enabled:列在 dsh.profile.bundles 里 —— dsh 只
  # 加载这里列出的插件,在设置里停用的插件仍留在 dependencies 中,而 dsh plugin add 不会
  # 重新启用它。Version:node_modules 里实际装上的版本(dependencies 里只是一个范围)。
  function Get-PluginState {
    $manifest = Read-Json $profilePkg
    $bundles = @(Get-Prop (Get-Prop (Get-Prop $manifest 'dsh') 'profile') 'bundles')
    return @{
      Declared = ($null -ne (Get-Prop (Get-Prop $manifest 'dependencies') $Plugin))
      Enabled = ($bundles -contains $Plugin)
      Version = (ConvertTo-Version ([string](Get-Prop (Read-Json $pluginPkg) 'version')))
    }
  }

  function Test-PluginCurrent($state) { return [bool]($state.Declared -and $state.Version -and ($state.Version -ge $MinPlugin)) }

  function Format-PluginVersion($version) { if ($version) { "v$version" } else { T '版本未知' 'unknown version' } }

  function Fail-PluginDisabled([string]$version) {
    Fail (T "已安装($version),但在 $Profile_ profile 里被停用了,dsh 不会加载它。请在 DSH 的「设置 → 插件」里启用 $Plugin;或者执行 dsh plugin --profile $Profile_ remove $Plugin 后重新运行本命令(会重新安装并启用)。" "Installed ($version) but disabled in the $Profile_ profile, so dsh does not load it. Enable $Plugin under Settings → Plugins in DSH, or run dsh plugin --profile $Profile_ remove $Plugin and run this command again (it reinstalls and enables it).")
  }

  function Get-Processes([string]$filter) {
    try { return @(Get-CimInstance Win32_Process -Filter $filter -ErrorAction Stop) } catch { }
    try { return @(Get-WmiObject Win32_Process -Filter $filter -ErrorAction Stop) } catch { }
    return @()
  }

  # 本脚本(包括更早的版本)在后台启动的 dsh web:隐藏的 cmd.exe,命令行里带着日志文件名。
  function Get-OwnDshWeb {
    return @(Get-Processes "Name = 'cmd.exe'" | Where-Object { $_.CommandLine -and ($_.CommandLine -like "*$LogName*") -and ($_.CommandLine -like '* web *') })
  }

  # 连同子进程(node、chrome-daemon)一起结束;taskkill 的输出是本地代码页,不显示。
  function Stop-Tree([int]$id) {
    & (Join-Path $env:SystemRoot 'System32\taskkill.exe') /PID $id /T /F 2>&1 | Out-Null
  }

  # 结束本脚本以前留在后台的 dsh web(它加载着旧插件,chrome-daemon.exe 还占着旧版本的
  # 文件),并等端口释放。返回结束了几个。
  function Stop-OwnDshWeb {
    $own = @(Get-OwnDshWeb)
    foreach ($p in $own) {
      Info (T "结束本脚本之前在后台启动的 dsh web(PID $($p.ProcessId))…" "Stopping the dsh web this script started earlier (PID $($p.ProcessId))…")
      Stop-Tree ([int]$p.ProcessId)
    }
    if ($own.Count -gt 0) {
      $until = (Get-Date).AddSeconds(10)
      while ((Test-Port $Port) -and ((Get-Date) -lt $until)) { Start-Sleep -Milliseconds 500 }
    }
    return $own.Count
  }

  function Get-PortOwner([int]$port) {
    try {
      $conn = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction Stop | Select-Object -First 1
      if ($conn) { return [int]$conn.OwningProcess }
    } catch { }
    try {
      foreach ($line in @(& (Join-Path $env:SystemRoot 'System32\netstat.exe') -ano -p tcp 2>$null)) {
        if ($line -match "^\s*TCP\s+\S+:$port\s+\S+\s+LISTENING\s+(\d+)\s*$") { return [int]$Matches[1] }
      }
    } catch { }
    return $null
  }

  # 日志里从 $offset 字节起的部分,即本次启动写入的内容。写入方可能还开着文件,按 ReadWrite 共享打开。
  function Read-LogSince([string]$file, [long]$offset) {
    $stream = $null
    try {
      $stream = New-Object IO.FileStream($file, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
      if ($stream.Length -le $offset) { return '' }
      [void]$stream.Seek($offset, [IO.SeekOrigin]::Begin)
      $buffer = New-Object byte[] ([int]($stream.Length - $offset))
      $read = $stream.Read($buffer, 0, $buffer.Length)
      $text = [Text.Encoding]::UTF8.GetString($buffer, 0, $read)
      return ($text -replace ([string][char]27 + '\[[0-9;]*[A-Za-z]'), '')
    } catch { return '' } finally { if ($stream) { $stream.Dispose() } }
  }

  function Show-LogTail([string]$text, [int]$count = 20) {
    $lines = @($text -split '\r?\n' | Where-Object { $_.Trim() })
    if ($lines.Count -eq 0) { Info (T '(这次启动没有写入任何日志)' '(nothing was logged by this start)'); return }
    Info (T "本次日志最后 $([Math]::Min($count, $lines.Count)) 行:" "Last $([Math]::Min($count, $lines.Count)) lines of this start's log:")
    foreach ($line in @($lines | Select-Object -Last $count)) { Write-Host "      $line" -ForegroundColor DarkGray }
  }

  # 根据本次日志判断没注册上的原因,按最具体的优先。
  function Get-RegisterFailure([string]$text, [bool]$exited, $exitCode, [bool]$listening) {
    if ($text -match 'unsupported platform win32') {
      return (T "实际加载的 $Plugin 不支持 Windows(需要 $MinPlugin 及以上)。请执行 dsh plugin --profile $Profile_ add ${Plugin}@latest,再重新运行本命令。" "The loaded $Plugin has no Windows support (needs $MinPlugin or later). Run dsh plugin --profile $Profile_ add ${Plugin}@latest, then run this command again.")
    }
    if ($text -match 'native host registration failed:\s*([^\r\n]+)') {
      $why = $Matches[1].Trim()
      return (T "插件写注册表失败:$why。通常是安全软件(360、火绒、电脑管家等)拦截了对 HKCU\Software\Google\Chrome\NativeMessagingHosts 的写入,请在安全软件里放行后重新运行本命令。" "The plugin could not write the registry: $why. Security software usually blocks writes to HKCU\Software\Google\Chrome\NativeMessagingHosts; allow it there, then run this command again.")
    }
    if ($text -match ('skipping profile bundle "' + [regex]::Escape($Plugin) + '":\s*([^\r\n]+)')) {
      $why = $Matches[1].Trim()
      return (T "dsh 没有加载 ${Plugin}:$why" "dsh did not load ${Plugin}: $why")
    }
    if ($exited) {
      return (T "dsh web 启动后退出了(退出码 $exitCode),原因见下面的日志。" "dsh web exited during startup (exit code $exitCode); see the log below.")
    }
    if ($listening) {
      return (T "dsh web 已经启动,但 90 秒内插件没有注册启动器,原因见下面的日志。" "dsh web is up, but the plugin did not register the launcher within 90s; see the log below.")
    }
    return (T 'dsh web 在 90 秒内没有启动完成,原因见下面的日志。' 'dsh web did not finish starting within 90s; see the log below.')
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
  $state = Get-PluginState
  $version = Format-PluginVersion $state.Version
  if ((Test-PluginCurrent $state) -and $state.Enabled) { Ok (T "已安装到 $Profile_ profile($version)" "installed in the $Profile_ profile ($version)") }
  elseif (Test-PluginCurrent $state) { Fail-PluginDisabled $version; Finish; return }
  elseif ($CheckOnly) {
    if ($state.Declared) { Fail (T "当前 $version 太旧,需要 $MinPlugin 及以上(更早的版本在 Windows 上不注册启动器)" "$version is too old; needs $MinPlugin or later (earlier releases do not register the launcher on Windows)") }
    else { Fail (T '未安装' 'not installed') }
  }
  else {
    if ($state.Declared) { Warn (T "当前 $version 低于 $MinPlugin(更早的版本在 Windows 上不注册启动器),将升级。" "$version is older than $MinPlugin (earlier releases do not register the launcher on Windows); upgrading.") }
    [void](Stop-OwnDshWeb)
    # 已安装时 add 也会把版本更新到最新,并改写 dependencies 里的范围,不会被旧 lockfile 钉住。
    Info "dsh plugin --profile $Profile_ add ${Plugin}@latest"
    $okay = Invoke-Tool (Get-Exe 'dsh') @('plugin', '--profile', $Profile_, 'add', "${Plugin}@latest")
    $state = Get-PluginState
    $version = Format-PluginVersion $state.Version
    if ($okay -and (Test-PluginCurrent $state)) {
      if ($state.Enabled) { Ok (T "插件已安装($version)" "plugin installed ($version)") }
      else { Fail-PluginDisabled $version; Finish; return }
    }
    elseif ($okay -and $state.Declared) {
      Fail (T "安装后仍是 $version,低于 $MinPlugin。如果给 npm / pnpm 配置了镜像源,它可能还没同步到新版本,请换回官方源或稍后重试。" "Still $version after installing, older than $MinPlugin. A configured npm/pnpm mirror may not have synced the new release yet; switch back to the official registry or retry later.")
      Finish; return
    }
    else {
      Fail (T '插件安装失败,请查看上面的 pnpm 输出。如果报 EPERM / EBUSY,先在任务管理器里结束 chrome-daemon.exe 再重新运行本命令。' "Plugin install failed; see pnpm's output above. On EPERM / EBUSY, end chrome-daemon.exe in Task Manager and run this command again.")
      Finish; return
    }
  }

  # ---- 5. 本地启动器 + dsh web ----
  Step (T '本地启动器(Chrome Native Messaging)' 'Local launcher (Chrome Native Messaging)')
  if (Test-HostRegistered) {
    Ok (T '已注册' 'registered')
    if (Test-Port $Port) { Ok (T "dsh web 正在运行(127.0.0.1:$Port)" "dsh web is running (127.0.0.1:$Port)") }
    else { Info (T 'dsh web 未运行;扩展需要时会自动启动它。' 'dsh web is not running; the extension starts it when needed.') }
  }
  elseif ($CheckOnly) { Fail (T '未注册(启动一次 dsh web 即可注册)' 'not registered (starting dsh web once registers it)') }
  else {
    # 端口上已有服务但没注册启动器:是本脚本以前留下的 dsh web 就结束它重来;用户自己启动的
    # 不替他结束,只告诉他是哪个进程、怎么结束。
    if (Test-Port $Port) { [void](Stop-OwnDshWeb) }
    if (Test-Port $Port) {
      $owner = Get-PortOwner $Port
      if ($owner) {
        $name = @(Get-Processes "ProcessId = $owner" | ForEach-Object { $_.Name }) -join ''
        if (-not $name) { $name = '?' }
        Fail (T "127.0.0.1:$Port 已被 PID $owner($name)占用,多半是装好或升级插件之前启动的 dsh web。请在运行它的窗口按 Ctrl+C,或执行 taskkill /PID $owner /T /F,然后重新运行本命令。" "127.0.0.1:$Port is taken by PID $owner ($name), most likely a dsh web started before the plugin was installed or upgraded. Press Ctrl+C in its window or run taskkill /PID $owner /T /F, then run this command again.")
      } else {
        Fail (T "127.0.0.1:$Port 上已有服务在运行,多半是装好或升级插件之前启动的 dsh web。请关掉它(在运行它的窗口按 Ctrl+C),再重新运行本命令。" "Something is already listening on 127.0.0.1:$Port, most likely a dsh web started before the plugin was installed or upgraded. Stop it (Ctrl+C in its window), then run this command again.")
      }
    }
    else {
      $logs = Join-Path $DshDir 'logs'
      New-Item -ItemType Directory -Force -Path $logs | Out-Null
      $log = Join-Path $logs $LogName
      # 日志是追加写的,记下起点,失败时只分析本次启动写入的部分。
      $offset = [long]0
      if (Test-Path -LiteralPath $log) { $offset = (Get-Item -LiteralPath $log).Length }
      Info (T "启动 dsh web(后台运行,日志:$log)…" "Starting dsh web in the background (log: $log)…")
      # cmd /c 负责把 stdout/stderr 追加进同一个日志;窗口隐藏,关掉当前终端也不影响它。
      # 命令行里的日志文件名同时是 Get-OwnDshWeb 认出它的标记。
      $proc = Start-Process -PassThru -FilePath $env:ComSpec -WindowStyle Hidden -ArgumentList @('/s', '/c', "`"`"$(Get-Exe 'dsh')`" web --no-open --port $Port >> `"$log`" 2>&1`"")
      # Windows PowerShell 5.1 要先取一次句柄,进程退出后 ExitCode 才读得到。
      try { [void]$proc.Handle } catch { }
      $deadline = (Get-Date).AddSeconds(90)
      while ((Get-Date) -lt $deadline) {
        if ((Test-HostRegistered) -and (Test-Port $Port)) { break }
        if ($proc.HasExited) { break }
        Start-Sleep -Seconds 1
      }
      if (Test-HostRegistered) {
        Ok (T '已注册' 'registered')
        if (Test-Port $Port) { Ok (T "dsh web 已启动(127.0.0.1:$Port)" "dsh web started (127.0.0.1:$Port)") }
        else { Warn (T "dsh web 还没起来,查看日志:$log" "dsh web is not up yet; see $log") }
      } else {
        $exited = $proc.HasExited
        $exitCode = if ($exited) { $proc.ExitCode } else { $null }
        $listening = Test-Port $Port
        # 没注册成功的 dsh web 留着只会挡住下一次运行,结束它(先结束,日志才写完整)。
        if (-not $exited) { Stop-Tree $proc.Id }
        $text = Read-LogSince $log $offset
        Fail (Get-RegisterFailure $text $exited $exitCode $listening)
        Show-LogTail $text
        if (-not $exited) { Info (T '已结束这次在后台启动的 dsh web,重新运行本命令不会被它挡住。' 'Stopped the dsh web started in the background, so it will not get in the way of the next run.') }
        Info (T "完整日志:$log" "Full log: $log")
      }
    }
  }

  Finish
}
