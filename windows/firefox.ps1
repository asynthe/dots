# Firefox on Windows, the way scripts/firefox/ + gentoo/setup.md §5 set it up on Linux:
# arkenfox + config/firefox/common.cfg as system-wide autoconfig, the add-ons from
# scripts/firefox/policies.sh force-installed by policy, and the default/study/work/infra
# profiles with config/firefox/keep.js linked in as user.js.
#
#   powershell -ExecutionPolicy Bypass -File windows\firefox.ps1           # dry run
#   powershell -ExecutionPolicy Bypass -File windows\firefox.ps1 -Apply    # do it
#
# The install dir is under Program Files, so -Apply re-launches itself as admin.
# Close Firefox first. Rerun to pull a newer arkenfox or pick up ADDONS changes.

param([switch]$Apply, [switch]$Elevated)

$ErrorActionPreference = 'Stop'

# The admin window closes when done, so keep it open on a failure to read the error
if ($Elevated) { trap { Write-Host $_ -ForegroundColor Red; Read-Host 'press enter to close'; exit 1 } }

$Dots = Split-Path -Parent $PSScriptRoot
$FfConf = Join-Path $Dots 'config\firefox'
$Install = Join-Path $env:ProgramFiles 'Mozilla Firefox'
$FF = Join-Path $env:APPDATA 'Mozilla\Firefox'
$Profiles = 'default', 'study', 'work', 'infra'

function note($m) { Write-Host '  [+] ' -ForegroundColor Green -NoNewline; Write-Host $m }
function warn($m) { Write-Host '  [!] ' -ForegroundColor Yellow -NoNewline; Write-Host $m }
function run($m, [scriptblock]$b) {
    if ($Apply) { & $b } else { Write-Host '  would: ' -ForegroundColor Blue -NoNewline; Write-Host $m }
}
# Write only when the content changed, so reruns are quiet
function put($path, $text) {
    if ((Test-Path -LiteralPath $path) -and ((Get-Content -Raw -LiteralPath $path) -eq $text)) { return }
    if ($Apply) { note "write $path" }
    run "write $path" { [IO.File]::WriteAllText($path, $text, [Text.UTF8Encoding]::new($false)) }
}

if (-not (Test-Path "$Install\firefox.exe")) { warn "no Firefox in $Install"; exit 1 }

if ($Apply -and (Get-Process firefox -ErrorAction SilentlyContinue)) { warn 'firefox is running, close it first'; exit 1 }

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).
    IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($Apply -and -not $admin) {
    warn 'writing to Program Files needs admin, elevating...'
    $p = Start-Process powershell -Verb RunAs -Wait -PassThru -ArgumentList @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-Apply', '-Elevated'
    )
    if ($p.ExitCode) { warn "elevated run failed (exit $($p.ExitCode))" } else { note 'done' }
    exit $p.ExitCode
}

# Same files as /opt/firefox on gentoo: a loader in defaults\pref, then mozilla.cfg
# (a comment line, arkenfox with user_pref -> defaultPref, then common.cfg).
Write-Host '-- autoconfig'
put "$Install\defaults\pref\autoconfig.js" (
    "pref(`"general.config.filename`", `"mozilla.cfg`");`npref(`"general.config.obscure_value`", 0);`n")
$arkenfox = (Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/arkenfox/user.js/master/user.js').Content
$arkenfox = $arkenfox -replace '(?m)^user_pref\(', 'defaultPref('
$common = Get-Content -Raw "$FfConf\common.cfg"
put "$Install\mozilla.cfg" ("// windows autoconfig`n" + $arkenfox.TrimEnd() + "`n" + $common)

# Windows reads distribution\policies.json beside firefox.exe instead of /etc/firefox/policies.
# The add-on list stays in policies.sh, so there's one list to edit.
Write-Host '-- policies'
$addons = [ordered]@{}
$inList = $false
foreach ($line in Get-Content "$Dots\scripts\firefox\policies.sh") {
    if ($line -match '^ADDONS=\(') { $inList = $true; continue }
    if ($inList -and $line -match '^\)') { break }
    if ($inList -and $line -match '^\s*"(\S+)\s+(\S+)"') {
        $addons[$Matches[1]] = @{
            installation_mode = 'force_installed'
            install_url       = "https://addons.mozilla.org/firefox/downloads/latest/$($Matches[2])/latest.xpi"
        }
    }
}
note "$($addons.Count) add-ons"
$theme = [regex]::Match($common, '"extensions\.activeThemeID",\s*"([^"]+)"').Groups[1].Value
if ($theme -and -not $addons.Contains($theme)) { warn "common.cfg's theme $theme is not in ADDONS" }
if ($Apply) { New-Item -ItemType Directory -Force "$Install\distribution" | Out-Null }
put "$Install\distribution\policies.json" (@{ policies = @{
    ExtensionSettings = $addons
    SearchEngines     = @{ Default = 'DuckDuckGo' }
} } | ConvertTo-Json -Depth 5)

# Profiles, like scripts/firefox/setup.sh. A Windows install starts out on its own
# 'default-release' profile, which holds the history: that one becomes 'default'.
Write-Host '-- profiles'
$ini = "$FF\profiles.ini"
if (-not (Test-Path $ini)) { warn 'no profiles.ini, start firefox once, then re-run'; exit 1 }

function Read-Profiles {
    $secs = [ordered]@{}; $cur = $null
    foreach ($line in Get-Content $ini) {
        if ($line -match '^\[(.+)\]$') { $cur = $Matches[1]; $secs[$cur] = [ordered]@{} }
        elseif ($cur -and $line -match '^([^=]+)=(.*)$') { $secs[$cur][$Matches[1]] = $Matches[2] }
    }
    $secs
}
function Write-Profiles($secs) {
    $out = foreach ($s in $secs.Keys) { "[$s]"; foreach ($k in $secs[$s].Keys) { "$k=$($secs[$s][$k])" }; '' }
    [IO.File]::WriteAllLines($ini, [string[]]$out)
}
function Find-Profile($secs, $name) {
    foreach ($s in $secs.Keys) { if ($s -like 'Profile*' -and $secs[$s].Name -eq $name) { return $s } }
}
function Get-ProfileDir($sec) {
    if ($sec.IsRelative -eq '0') { $sec.Path } else { Join-Path $FF ($sec.Path -replace '/', '\') }
}

$secs = Read-Profiles
$release = Find-Profile $secs 'default-release'
if ($release) {
    $old = Find-Profile $secs 'default'
    if ($old -and (Test-Path (Join-Path (Get-ProfileDir $secs[$old]) 'places.sqlite'))) {
        warn "both 'default' and 'default-release' have history, leaving names alone"
    } else {
        note "profile default-release -> default$(if ($old) { " (dropping the empty old 'default')" })"
        if ($Apply) {
            Copy-Item $ini "$ini.bak" -Force
            if ($old) { $secs.Remove($old) }
            $secs[$release].Name = 'default'
            Write-Profiles $secs
        }
    }
}
# setup.sh's "make default the default": the Install section picks what a bare
# firefox.exe opens, and Profile*'s Default=1 is what the profile manager shows.
$secs = Read-Profiles
$def = Find-Profile $secs 'default'
if ($Apply -and $def) {
    foreach ($s in @($secs.Keys)) {
        if ($s -like 'Profile*') { $secs[$s].Remove('Default') }
        if ($s -like 'Install*') { $secs[$s].Default = $secs[$def].Path }
    }
    $secs[$def].Default = '1'
    Write-Profiles $secs
}

foreach ($name in $Profiles) {
    $secs = Read-Profiles
    $s = Find-Profile $secs $name
    if ($name -eq 'default' -and $release -and -not $Apply) {
        $dir = Get-ProfileDir $secs[$release]   # renamed above on -Apply
    } elseif ($s) {
        $dir = Get-ProfileDir $secs[$s]
    } else {
        $dir = "$FF\Profiles\$name"
        note "create profile $name"
        run "firefox --CreateProfile `"$name $dir`"" {
            Start-Process -Wait "$Install\firefox.exe" -ArgumentList '--headless', '--CreateProfile', "`"$name $dir`""
        }
    }

    $userjs = Join-Path $dir 'user.js'
    $item = Get-Item -LiteralPath $userjs -Force -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType -eq 'SymbolicLink' -and $item.Target -eq "$FfConf\keep.js") { continue }
    if ($item -and -not $item.LinkType) { warn "$name user.js is a real file, left alone"; continue }
    note "$name\user.js -> config\firefox\keep.js"
    run "mklink $userjs" {
        New-Item -ItemType Directory -Force $dir | Out-Null
        if ($item) { $item.Delete() }
        cmd /c "mklink `"$userjs`" `"$FfConf\keep.js`"" | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "mklink failed for $userjs" }
    }

    # common.cfg's theme is only a default, a profile that saved its own keeps it
    $prefs = Join-Path $dir 'prefs.js'
    if ((Test-Path $prefs) -and (Select-String -Quiet -SimpleMatch '"extensions.activeThemeID"' $prefs)) {
        note "$name prefs.js: drop its saved theme"
        run "strip extensions.activeThemeID from $prefs" {
            (Get-Content $prefs) | Where-Object { $_ -notmatch '"extensions\.activeThemeID"' } | Set-Content $prefs
        }
    }
}

# browser.sh's profile picker, as one desktop shortcut per profile
Write-Host '-- shortcuts'
$Desktop = [Environment]::GetFolderPath('Desktop')
$shell = New-Object -ComObject WScript.Shell
foreach ($name in $Profiles) {
    $lnk = Join-Path $Desktop "Firefox ($name).lnk"
    if ((Test-Path -LiteralPath $lnk) -and $shell.CreateShortcut($lnk).Arguments -eq "-P $name") { continue }
    note "Desktop\Firefox ($name)"
    run "shortcut $lnk -> firefox.exe -P $name" {
        $s = $shell.CreateShortcut($lnk)
        $s.TargetPath = "$Install\firefox.exe"
        $s.Arguments = "-P $name"
        $s.WorkingDirectory = $Install
        $s.IconLocation = "$Install\firefox.exe,0"
        $s.Description = "Firefox, $name profile"
        $s.Save()
    }
}

if (-not $Apply) { Write-Host "`ndry run, pass -Apply to make changes" }
