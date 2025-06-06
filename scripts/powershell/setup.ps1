# Other recommended programs:
# - DaVinci Resolve
# - FL Studio
# - Ableton
# - TranslucentTB

# TODO Copy 'rarreg.key' to WinRAR folder.
# TODO Copy GlazeWM configuration to %USERPROFILE%/.glzr/glazewm
# TODO Set up a temporal elevation

# Win11DisableRoundedCourners
# TODO Setup
# TODO Delete the .exe at the end? Or move to another folder?
# https://github.com/valinet/Win11DisableRoundedCorners/releases/download/1.0.0.3/Win11DisableOrRestoreRoundedCorners.exe

#Write-Output "Other: fetching and running 'Win11DisableOrRestoreRoundedCorners.exe'..."
#Start-Sleep -Milliseconds 100
#$Repo = "valinet/Win11DisableRoundedCorners"
#$FileName = "Win11DisableOrRestoreRoundedCorners.exe"
#$LatestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
#$LatestVersion = $LatestRelease.tag_name
#$Url = "https://github.com/$Repo/releases/download/$LatestVersion/$FileName"
#$Desktop = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
#$FilePath = [System.IO.Path]::Combine($Desktop, $FileName)
#Invoke-WebRequest -Uri $Url -OutFile $FilePath # Download the latest version
#Start-Process -FilePath $FilePath -NoNewWindow -Wait # Run the executable

# Neovim
# TODO Test if working in powershell.
# https://dev.to/hoo12f/setting-up-neovim-with-windows-powershell-2208
#Write-Output "Copying neovim configuration into Appdata\Local..."
#Start-Sleep -Milliseconds 100											# Sleep for 100 milliseconds.
#$NvimConfigPath = "$env:USERPROFILE\AppData\Local\nvim"
#$SourcePath = "..\config\nvim"
# Create the target directory if it doesn't exist
#if (!(Test-Path $NvimConfigPath)) {
#    New-Item -ItemType Directory -Path $NvimConfigPath -Force
#}
#Copy-Item -Path $SourcePath -Destination $NvimConfigPath -Recurse -Force # Copy the files

# ------------------------- ASCII -------------------------
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Display-AsciiArt {
    $asciiArt = @"
  ⣴⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⣼⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣼⣿⣿⣿⣿⣿⣿⣿⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣤⣤⣶⣶⣿⣿⡗
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟ 
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀
⣿⣿⡇⠜⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿ ⠀  
⣿⣿⣿⣶⣿⣿⣿⣿⣿⠋⡹⠙⣿⣿⣿⡇⠀⠀  
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣾⣿⣿⠛⠀⠀⠀⠀⠀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠛⠁⠀⠀⠀⠀⠀⠀
⣿⣿⡿⠻⠿⠿⠿⠿⠛⠹⠑⠀⠀       
⠟                   
"@

    # Simulating pv -qL 470 (prints each line with a small delay)
    $asciiArt -split "`n" | ForEach-Object {
        Write-Host $_ -NoNewline
        Start-Sleep -Milliseconds 50
        Write-Host ""
    }
}

# ------------------------- Start -------------------------
Display-AsciiArt
Write-Output "Welcome to meow's windows setup script!"
Start-Sleep -Seconds 1

# Configuration
Write-Output "------------------------- Configuration -------------------------"
Write-Output @"
List of configuration:
[+] Powershell: create a profile
[+] Powershell: remove welcome message
"@

$answer = Read-Host "This will set up the next configuration, do you wish to continue? (y/n)"
switch ($answer.ToLower()) {
    "y" { Write-Host "Continuing..." }
    "n" { Write-Host "Exiting..."; exit }
    default { Write-Host "Character not recognized. Exiting..."; exit }}
Start-Sleep -Milliseconds 500

Write-Output "Powershell: Creating a profile..."
Start-Sleep -Milliseconds 100
if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

Write-Output "Powershell: Removing welcome message..."
Start-Sleep -Milliseconds 100
Add-Content -Path $PROFILE -Value '$Host.UI.RawUI.WindowTitle = "PowerShell"; Clear-Host'

# Programs
Write-Output "------------------------- Programs -------------------------"
Write-Output @"
List of programs:
[+] 7zip
[+] CPU-Z (MSI Ver.)
[+] CrystalDiskInfo (Kurei Kei Edition)
[+] Discord
[+] Eartrumpet
[+] Git
[+] KeePassXC
[+] Librewolf
[+] Mullvad VPN
[+] Notepad++
[+] OBS Studio
[+] Obsidian
[+] PowerToys
[+] PuTTY
[+] Spotify
[+] Steam
[+] VLC
[+] VMware Workstation Pro
[+] Visual Studio Code
[+] Wezterm
[+] WinRAR
[+] Yazi
[+] qBittorrent
[+] scrcpy
"@

# NOTE: Remember that last one doesn't have a comma.
$programs = @(
    "7zip.7zip",
    "CPUID.CPU-Z.MSI", # MSI Ver.
    "CrystalDewWorld.CrystalDiskInfo.ShizukuEdition",
    "Discord.Discord",
    "File-New-Project.EarTrumpet",
    "Flow-Launcher.Flow-Launcher",
    "Git.Git",
    "KeePassXCTeam.KeePassXC",
    "LibreWolf.LibreWolf",
    "Microsoft.PowerToys",
    "Microsoft.VisualStudioCode",
    "Notepad++.Notepad++",
    "OBSProject.OBSStudio",
    "Obsidian.Obsidian",
    "PeterPawlowski.foobar2000",
    "PuTTY.PuTTY",
    "Spotify.Spotify",
    "VLC.VLC",
    "Valve.Steam",
    "lars-berger.GlazeWM",
    "qBittorrent.qBittorrent",
    "wez.wezterm",
    "Genymobile.scrcpy",

    #"CrystalDewWorld.CrystalDiskInfo.KureiKeiEdition",
    #"MullvadVPN.MullvadVPN", # Weird bug that opens it when system starts but doesn't show.
    #"RARLab.WinRAR", # Prefer beta for Dark Mode
    #"VMware.WorkstationPro", # TODO Is this working?

    # Yazi
    # TODO: `yy` alias
    # TODO: Allow yazi to use `file` which comes with Git,
    #       find the binary for `file`.
    #       more info: https://yazi-rs.github.io/docs/installation#windows
    "sxyazi.yazi",
    "Gyan.FFmpeg", 
    "7zip.7zip",
    "jqlang.jq",
    "sharkdp.fd",
    "BurntSushi.ripgrep.MSVC",
    "junegunn.fzf",
    "ajeetdsouza.zoxide",
    "ImageMagick.ImageMagick"
)

$answer = Read-Host "This will set up the next list of programs, do you wish to continue? (y/n)"
switch ($answer.ToLower()) {
    "y" { Write-Host "Continuing..." }
    "n" { Write-Host "Exiting..."; exit }
    default { Write-Host "Character not recognized. Exiting..."; exit }
}

Write-Output "Winget: Checking for updates..."
Start-Sleep -Milliseconds 100
winget upgrade --id Microsoft.DesktopAppInstaller -e --silent

Write-Output "Winget: Installing and checking for missing programs..."
foreach ($program in $programs) {
    $programName = ($program -split '\.')[-1]
    if ($installedPrograms -notcontains $program) { # Check if the program is already installed
        Write-Output "Installing $program"
        winget install --id $program --exact --silent
        Write-Output "$programName installation complete."
    } else {
        Write-Output "$programName is already installed."
    }
}

Write-Output "------------------------- Finished! -------------------------"
Start-Sleep -Milliseconds 200
Write-Output "Setup completed! Please restart PowerShell to apply changes."
