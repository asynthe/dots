# -----------------------
# CONFIGURATION (relative to script)
# -----------------------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$relativeWallpaperPath = "..\..\wallpapers\fav"
$wallpaperFolder = Join-Path $ScriptDir $relativeWallpaperPath
$historyFile = "$env:LOCALAPPDATA\WallpaperHistory.json"

# -----------------------
# FUNCTIONS
# -----------------------

function Get-RandomImage($folder, $usedImages) {
    $images = Get-ChildItem -Path $folder -Include *.jpg, *.jpeg, *.png -File -ErrorAction SilentlyContinue
    if ($images.Count -eq 0) { return $null }

    $unused = $images | Where-Object { $_.FullName -notin $usedImages }
    if ($unused.Count -eq 0) { $unused = $images }

    return ($unused | Get-Random).FullName
}

function Set-LockScreen($imagePath) {
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $null = [Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime]
    $null = [Windows.System.UserProfile.UserProfilePersonalizationSettings, Windows.System.UserProfile, ContentType = WindowsRuntime]

    $file = [Windows.Storage.StorageFile]::GetFileFromPathAsync($imagePath).GetAwaiter().GetResult()
    $settings = [Windows.System.UserProfile.UserProfilePersonalizationSettings]::Current
    $settings.TrySetLockScreenImageAsync($file).GetAwaiter().GetResult() | Out-Null
}

function Set-DesktopBackground($imagePath) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
  [DllImport("user32.dll", SetLastError = true)]
  public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    $SPI_SETDESKWALLPAPER = 20
    $SPIF_UPDATEINIFILE = 0x01
    $SPIF_SENDWININICHANGE = 0x02

    [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $imagePath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDWININICHANGE) | Out-Null
}

function Update-History($historyPath, $lockImage, $desktopImage) {
    $history = @{
        LockScreen = $lockImage
        Desktop    = $desktopImage
    }
    $history | ConvertTo-Json | Set-Content $historyPath
}

function Load-History($path) {
    if (-not (Test-Path $path)) { return @{ LockScreen = ""; Desktop = "" } }
    return Get-Content $path | ConvertFrom-Json
}

# -----------------------
# MAIN LOGIC
# -----------------------

$history = Load-History -path $historyFile

$lockImage = Get-RandomImage -folder $wallpaperFolder -usedImages @($history.LockScreen)
$desktopImage = Get-RandomImage -folder $wallpaperFolder -usedImages @($history.Desktop)

if ($lockImage) {
    Set-LockScreen -imagePath $lockImage
    Write-Host "✅ Lock screen set to $lockImage"
} else {
    Write-Host "⚠️ No lock screen images found"
}

if ($desktopImage) {
    Set-DesktopBackground -imagePath $desktopImage
    Write-Host "✅ Desktop background set to $desktopImage"
} else {
    Write-Host "⚠️ No desktop images found"
}

Update-History -historyPath $historyFile -lockImage $lockImage -desktopImage $desktopImage
