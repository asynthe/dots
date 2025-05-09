# Elevate if not running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[+] Restarting script as administrator..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Setting up symlinks for specific apps that work on Windows.
# Get the directory of the running script
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# ------------------------- Winget -------------------------
# ------------------------- Apps -------------------------

# Define symbolic link items
$itemsToLink = @(
    @{ Name = "PowerShell"; Source = "..\..\config\powershell\Microsoft.PowerShell_profile.ps1"; Target = "$PROFILE" },
    @{ Name = "Emacs"; Source = "..\..\config\emacs"; Target = "$env:APPDATA\.emacs.d" },
    @{ Name = "Neovim"; Source = "..\..\config\nvim"; Target = "$env:LOCALAPPDATA\nvim" },
    @{ Name = "Wezterm"; Source = "..\..\config\wezterm\.wezterm.lua"; Target = "$env:USERPROFILE\.wezterm.lua" }
)

# Loop through and create symbolic links
foreach ($item in $itemsToLink) {
    $name = $item.Name
    $sourcePath = Resolve-Path -Path (Join-Path $scriptRoot $item.Source) -ErrorAction SilentlyContinue
    $targetPath = $item.Target

    if (-not $sourcePath) {
        Write-Host "[!] Source not found for ${name}"
        continue
    }

    if (Test-Path $targetPath) {
        $response = Read-Host "[?] File for $name already exists. Should I replace it? (y/n)"
        if ($response -ne 'y') {
            Write-Host "[+] Skipping symbolic link for $name."
            continue
        }
        Remove-Item -Path $targetPath -Recurse -Force
    }

    # Ensure parent directory exists
    $targetParent = Split-Path $targetPath
    if (-not (Test-Path $targetParent)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }

    # Create symbolic link
    New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force | Out-Null
    #Write-Host "[+] Symbolic link for $name has been created."
    #Write-Host "[+] Symbolic link for $name has been created: $sourcePath -> $targetPath"
}
