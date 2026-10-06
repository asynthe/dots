#Clear-Host
#figlet -f "Merlin1" Powershellhell"
#$host.ui.RawUI.BackgroundColor = "Black"
#$host.ui.RawUI.ForegroundColor = "Green"

# --------------- Configuration ---------------

# Yazi
function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
}

# Wezterm required
function prompt {
    $p = $executionContext.SessionState.Path.CurrentLocation
    $osc7 = ""
    if ($p.Provider.Name -eq "FileSystem") {
        $ansi_escape = [char]27
        $provider_path = $p.ProviderPath -Replace "\\", "/"
        $osc7 = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}${ansi_escape}\"
    }
    "${osc7}PS $p$('>' * ($nestedPromptLevel + 1)) ";
}

# Quick zip extract
function x {
    param([Parameter(Mandatory)][string]$Zip, [string]$Dest = ".")
    $f = Get-Item -LiteralPath $Zip
    Expand-Archive -LiteralPath $f.FullName -DestinationPath (Join-Path $Dest $f.BaseName)
}

# --------------- Aliases ---------------

Set-Alias l y
Set-Alias lf y

# --------------- Repo status ---------------

# The profile is a symlink into dots (windows/link.ps1); check_repo.ps1 sits
# beside the real file, not beside the link.
$_profile = Get-Item -LiteralPath $PSCommandPath -Force
$_dir = if ($_profile.LinkType -eq 'SymbolicLink') { Split-Path -Parent @($_profile.Target)[0] } else { $PSScriptRoot }
if (Test-Path (Join-Path $_dir 'check_repo.ps1')) {
    . (Join-Path $_dir 'check_repo.ps1')
    check_repo
}
Remove-Variable _profile, _dir
