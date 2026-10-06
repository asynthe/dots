# Symlink dots configs into the Windows user profile.
#
#   powershell -ExecutionPolicy Bypass -File windows\link.ps1           # dry run
#   powershell -ExecutionPolicy Bypass -File windows\link.ps1 -Apply    # do it
#
# Symlinks need either Developer Mode (Settings > System > For developers)
# or an elevated shell. Without either, -Apply re-launches itself as admin.
# Existing real files are moved aside to <name>.bak, never deleted.

param([switch]$Apply)

$ErrorActionPreference = 'Stop'

$Dots = Split-Path -Parent $PSScriptRoot
$Conf = Join-Path $Dots 'config'
$Docs = [Environment]::GetFolderPath('MyDocuments')
$Roam = $env:APPDATA
$Local = $env:LOCALAPPDATA

# target (in $HOME) => source (in dots). The same config/ dirs home_setup.sh
# links into ~/.config on Linux, at wherever each program looks on Windows.
# Linking a program that isn't installed is harmless; it's there when it is.
$Links = [ordered]@{
    "$HOME\.config\wezterm"                                    = "$Conf\wezterm"
    "$Docs\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" = "$Conf\powershell\Microsoft.PowerShell_profile.ps1"
    "$Docs\PowerShell\Microsoft.PowerShell_profile.ps1"        = "$Conf\powershell\Microsoft.PowerShell_profile.ps1"

    # These read ~/.config on Windows too
    "$HOME\.config\fastfetch"                                  = "$Conf\fastfetch"
    "$HOME\.config\opencode"                                   = "$Conf\opencode"

    # These use the Windows folders instead
    "$Local\nvim"                                              = "$Conf\nvim"
    "$Roam\yazi\config"                                        = "$Conf\yazi"
    "$Roam\alacritty"                                          = "$Conf\alacritty"
    "$Roam\mpv"                                                = "$Conf\mpv"
    "$Roam\jj"                                                 = "$Conf\jj"

    # File by file, like home_setup.sh: VSCodium writes state beside them
    "$Roam\VSCodium\User\settings.json"                        = "$Conf\VSCodium\User\settings.json"
    "$Roam\VSCodium\User\custom.css"                           = "$Conf\VSCodium\User\custom.css"
}

function note($m) { Write-Host '  [+] ' -ForegroundColor Green -NoNewline; Write-Host $m }
function warn($m) { Write-Host '  [!] ' -ForegroundColor Yellow -NoNewline; Write-Host $m }
function run($m, [scriptblock]$b) {
    if ($Apply) { & $b } else { Write-Host '  would: ' -ForegroundColor Blue -NoNewline; Write-Host $m }
}

function Test-CanSymlink {
    $admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).
        IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    $dev = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' `
        -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue
    $admin -or ($dev -and $dev.AllowDevelopmentWithoutDevLicense -eq 1)
}

if ($Apply -and -not (Test-CanSymlink)) {
    warn 'no symlink privilege (not admin, Developer Mode off), elevating...'
    Start-Process powershell -Verb RunAs -Wait -ArgumentList @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-NoExit', '-File', "`"$PSCommandPath`"", '-Apply'
    )
    exit
}

Write-Host '-- links'
foreach ($target in $Links.Keys) {
    $source = $Links[$target]
    if (-not (Test-Path -LiteralPath $source)) { warn "missing source $source, skipping"; continue }

    $item = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType -eq 'SymbolicLink') {
        if ($item.Target -eq $source) { continue }           # already linked
        note "relink $target (was -> $($item.Target))"
        run "remove link $target" { $item.Delete() }
    } elseif ($item) {
        note "backup $target -> $target.bak"
        run "move $target -> $target.bak" { Move-Item -LiteralPath $target "$target.bak" -Force }
    }

    note "$target -> $source"
    run "mklink $target $source" {
        New-Item -ItemType Directory -Force (Split-Path -Parent $target) | Out-Null
        # mklink (not New-Item) so Developer Mode works without admin on Windows PowerShell 5.1
        $dirFlag = if ((Get-Item -LiteralPath $source).PSIsContainer) { '/D ' } else { '' }
        cmd /c "mklink $dirFlag`"$target`" `"$source`"" | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "mklink failed for $target" }
    }
}

# Fonts that aren't packaged anywhere, installed per-user (no admin) the way
# gentoo/setup.md unzips them into ~/.local/share/fonts on Linux.
Write-Host '-- fonts'
$FontDir = "$Local\Microsoft\Windows\Fonts"
$FontReg = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
$tmp = Join-Path ([IO.Path]::GetTempPath()) 'dots-fonts'
$fonts = @()
if (Test-Path "$Dots\assets\fonts\TX-02.zip") {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
    Expand-Archive "$Dots\assets\fonts\TX-02.zip" $tmp
    $fonts += Get-ChildItem $tmp -Recurse -Include *.otf, *.ttf
}
$fonts += Get-Item "$Dots\assets\fonts\Smash-Regular.ttf" -ErrorAction SilentlyContinue
foreach ($f in $fonts) {
    if (Test-Path -LiteralPath "$FontDir\$($f.Name)") { continue }   # already installed
    note "font $($f.Name)"
    run "install $($f.Name) -> $FontDir" {
        New-Item -ItemType Directory -Force $FontDir | Out-Null
        Copy-Item -LiteralPath $f.FullName "$FontDir\$($f.Name)"
        $kind = if ($f.Extension -eq '.otf') { 'OpenType' } else { 'TrueType' }
        New-ItemProperty -Path $FontReg -Name "$($f.BaseName) ($kind)" `
            -Value "$FontDir\$($f.Name)" -PropertyType String -Force | Out-Null
    }
}
Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue

# Windows PowerShell 5.1 defaults to Restricted, which refuses to load the
# linked profile. pwsh 7 already defaults to RemoteSigned.
Write-Host '-- execution policy'
if ((Get-ExecutionPolicy -Scope CurrentUser) -notin 'RemoteSigned', 'Unrestricted', 'Bypass') {
    note 'CurrentUser execution policy -> RemoteSigned'
    run 'Set-ExecutionPolicy -Scope CurrentUser RemoteSigned' {
        # Saves fine but errors about this script's own -ExecutionPolicy Bypass overriding it
        try { Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force } catch {}
    }
}

if (-not $Apply) { Write-Host "`ndry run, pass -Apply to make changes" }
