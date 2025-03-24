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
        Write-Host $_
        Start-Sleep -Milliseconds 50
    }
}

Display-AsciiArt
Write-Output "Welcome to meow's windows setup script!"
Write-Output "------------------------- Start ! -------------------------"
Start-Sleep -Seconds 1												# Sleep 1 second.

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
    default { Write-Host "Character not recognized. Exiting..."; exit }
}
Start-Sleep -Milliseconds 500											# Sleep half a second.

Write-Output "Powershell: Creating a profile..."
Start-Sleep -Milliseconds 100
if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

Write-Output "Powershell: Removing welcome message..."
Start-Sleep -Milliseconds 100
Add-Content -Path $PROFILE -Value '$Host.UI.RawUI.WindowTitle = "PowerShell"; Clear-Host'

# Programs
Write-Output "Finished!"
Start-Sleep -Seconds 1												# Sleep 1 second.
Write-Output "------------------------- Programs -------------------------"
Write-Output @"
List of programs:
[+] 7zip
[+] CPU-Z (MSI Ver.)
[+] Discord
[+] Eartrumpet
[+] Git
[+] KeePassXC
[+] PowerToys
[+] Visual Studio Code
[+] Mullvad VPN
[+] Notepad++
[+] OBS Studio
[+] Obsidian
[+] PuTTY
[+] WinRAR
[+] Spotify
[+] VLC
[+] VMware Workstation Pro
[+] Steam
[+] qBittorrent
[+] Wezterm
"@

$programs = @(
    "7zip.7zip",
    "CPUID.CPU-Z.MSI", # MSI Ver.
    #"CrystalDewWorld.CrystalDiskInfo.KureiKeiEdition", # REMOVED - ADD WHEN NEEDED
    "Discord.Discord",
    "File-New-Project.EarTrumpet",
    "Git.Git",
    "KeePassXCTeam.KeePassXC",
    #"LibreWolf.LibreWolf", # REMOVED - ADD WHEN NEEDED
    "Microsoft.PowerToys",
    "Microsoft.VisualStudioCode",
    "MullvadVPN.MullvadVPN",
    "Notepad++.Notepad++",
    "OBSProject.OBSStudio",
    "Obsidian.Obsidian",
    "PeterPawlowski.foobar2000",
    "PuTTY.PuTTY",
    "RARLab.WinRAR",
    "Spotify.Spotify",
    "VLC.VLC",
    "VMware.WorkstationPro", # TODO Is this working?
    "Valve.Steam",
    "qBittorrent.qBittorrent",
    "wez.wezterm"
)

Start-Sleep -Milliseconds 500											# Sleep half a second.
$answer = Read-Host "This will set up the next list of programs, do you wish to continue? (y/n)"
switch ($answer.ToLower()) {
    "y" { Write-Host "Continuing..." }
    "n" { Write-Host "Exiting..."; exit }
    default { Write-Host "Character not recognized. Exiting..."; exit }
}

Write-Output "Winget: Checking for updates..."
Start-Sleep -Milliseconds 100											# Sleep for 100 milliseconds.
winget upgrade --id Microsoft.DesktopAppInstaller -e --silent

# Get installed programs
Write-Output "Checking installed programs..."
Start-Sleep -Milliseconds 100											# Sleep 100 milliseconds
$installedPrograms = winget list | ForEach-Object { $_ -split '\s{2,}' } | Select-Object -Skip 1

Write-Output "Winget: Installing and checking for missing programs..."
Start-Sleep -Milliseconds 100
foreach ($program in $programs) {
    $programName = ($program -split '\.')[-1]
    if ($installedPrograms -notcontains $program) {
        Write-Output "Installing $program..."
        winget install --id $program --exact --silent
        Write-Output "$programName installation complete."
    } else {
        Write-Output "$programName is already installed."
    }
}

Write-Output "Finished!"
Start-Sleep -Seconds 1												# Sleep 1 second.
Write-Output "------------------------- Other -------------------------"

# Other
# TODO Set up a temporal elevation
# TODO Delete the .exe at the end? Or move to another folder?
Write-Output "Other: fetching and running 'Win11DisableOrRestoreRoundedCorners.exe'..."
Start-Sleep -Milliseconds 100
$Repo = "valinet/Win11DisableRoundedCorners"
$FileName = "Win11DisableOrRestoreRoundedCorners.exe"
$LatestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
$LatestVersion = $LatestRelease.tag_name
$Url = "https://github.com/$Repo/releases/download/$LatestVersion/$FileName"
$Desktop = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$FilePath = [System.IO.Path]::Combine($Desktop, $FileName)
Invoke-WebRequest -Uri $Url -OutFile $FilePath # Download the latest version
Start-Process -FilePath $FilePath -NoNewWindow -Wait # Run the executable

Write-Output "------------------------- Finished! -------------------------"
Start-Sleep -Milliseconds 200
Write-Output "Setup completed! Please restart PowerShell to apply changes."

# TODO TEST NEOVIM CONFIGURATION ON POWERSHELL ???
# https://dev.to/hoo12f/setting-up-neovim-with-windows-powershell-2208

# TODO ADD Win11DisableRoundedCourners
# https://github.com/valinet/Win11DisableRoundedCorners/releases/download/1.0.0.3/Win11DisableOrRestoreRoundedCorners.exe
