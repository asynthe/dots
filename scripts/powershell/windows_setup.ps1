# TODO For each of the symbolic links created, output a "[+] Symbolic link for $name has been created."
# TODO If there's already a file or folder show a prompt "[?] File for $name already exists, should I replace it?"

# Elevate if not running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[+] Restarting script as administrator..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Get the directory of the running script
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# ------------------------- Winget -------------------------
# ------------------------- Apps -------------------------
# Setting up symlinks for specific apps that work on Windows.

$itemsToLink = @(
    @{ Source = "..\..\config\powershell\Microsoft.PowerShell_profile.ps1"; Target = "$env:PROFILE" }, # Powershell
    @{ Source = "..\..\config\emacs"; Target = "$env:APPDATA\.emacs.d" }, # Emacs
    @{ Source = "..\..\config\nvim"; Target = "$env:LOCALAPPDATA\nvim" }, # Neovim
    @{ Source = "..\..\config\wezterm\.wezterm.lua"; Target = "$env:USERPROFILE\.wezterm.lua" } # Wezterm
)

# Loop through and create symbolic links
foreach ($item in $itemsToLink) {

    # Resolve full absolute path for source
    $sourcePath = Resolve-Path -Path (Join-Path $scriptRoot $item.Source) -ErrorAction SilentlyContinue
    $targetPath = $item.Target
    if (-not $sourcePath) {
        Write-Host "[!] Source not found: $($item.Source)"
        continue
    }
    if (Test-Path $targetPath) {
        Write-Host "[+] Target already exists: $targetPath. Skipping..."
        continue
    }
    if (Test-Path $sourcePath -PathType Container) {
        New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force
        Write-Host "[+] Created symlink (folder): $targetPath -> $sourcePath"
    }
    elseif (Test-Path $sourcePath -PathType Leaf) {
        # Ensure parent directory exists
        $targetParent = Split-Path $targetPath
        if (-not (Test-Path $targetParent)) {
            New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
        }
        New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force
        Write-Host "[+] Created symlink (file): $targetPath -> $sourcePath"
    }
    else {
        Write-Host "[!] Unrecognized source type: $sourcePath"
    }
}
