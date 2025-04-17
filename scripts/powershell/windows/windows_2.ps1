# Self-elevate if not running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "🔐 Elevating to administrator..."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 1. Folders to Delete
$foldersToDelete = @(
    "Contacts",
    "Favorites",
    "Games",
    "Links",
    "Music",
    "OneDrive",
    "Pictures",
    "Saved Games",
    "Searches",
    "Videos"
)

Write-Host "`n🗑️ Deleting unused folders..." -ForegroundColor Cyan
foreach ($folder in $foldersToDelete) {
    $path = Join-Path $HOME $folder
    if (Test-Path $path) {
        try {
            Remove-Item $path -Recurse -Force -ErrorAction Stop
            Write-Host "✅ Deleted: $folder"
        } catch {
            Write-Warning "⚠️ Could not delete $folder: $_"
        }
    } else {
        Write-Host "ℹ️ $folder not found, skipping."
    }
}

# 2. Hide Documents folder
$documentsPath = Join-Path $HOME "Documents"
if (Test-Path $documentsPath) {
    try {
        (Get-Item $documentsPath).Attributes += 'Hidden'
        Write-Host "`n🙈 Hid: Documents folder"
    } catch {
        Write-Warning "⚠️ Could not hide Documents: $_"
    }
}

# 3. Clear Quick Access
Write-Host "`n🧼 Clearing Quick Access..." -ForegroundColor Cyan
$recentFolders = "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations"
$customDestinations = "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations"
Remove-Item "$recentFolders\*" -Force -ErrorAction SilentlyContinue
Remove-Item "$customDestinations\*" -Force -ErrorAction SilentlyContinue
Write-Host "✅ Quick Access cleared"

# 4. Uninstall OneDrive
Write-Host "`n🧹 Removing OneDrive..." -ForegroundColor Cyan
$onedriveExe = "$env:SystemRoot\System32\OneDriveSetup.exe"
if (Test-Path $onedriveExe) {
    try {
        Start-Process -FilePath $onedriveExe -ArgumentList "/uninstall" -Wait
        Write-Host "✅ OneDrive uninstalled"
    } catch {
        Write-Warning "⚠️ Could not uninstall OneDrive: $_"
    }
} else {
    Write-Host "ℹ️ OneDrive setup not found, may already be removed."
}

Write-Host "`n🎉 Minimalist cleanup complete!" -ForegroundColor Green
