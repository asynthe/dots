#figlet -f "Merlin1" Powershellhell"

function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
}

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

function x {
    param([Parameter(Mandatory)][string]$Zip, [string]$Dest = ".")
    $f = Get-Item -LiteralPath $Zip
    Expand-Archive -LiteralPath $f.FullName -DestinationPath (Join-Path $Dest $f.BaseName)
}

Set-Alias l y
Set-Alias lf y

# After the prompt function above: atuin wraps it to record each command.
if (Get-Command atuin -ErrorAction SilentlyContinue) {
    atuin init powershell --disable-up-arrow | Out-String | Invoke-Expression
}

# The profile is a symlink into dots (link.ps1, notes: windows/windows.md); check_repo.ps1 sits
# beside the real file, not beside the link.
$_profile = Get-Item -LiteralPath $PSCommandPath -Force
$_dir = if ($_profile.LinkType -eq 'SymbolicLink') { Split-Path -Parent @($_profile.Target)[0] } else { $PSScriptRoot }
if (Test-Path (Join-Path $_dir 'check_repo.ps1')) {
    . (Join-Path $_dir 'check_repo.ps1')
    check_repo
}
Remove-Variable _profile, _dir
