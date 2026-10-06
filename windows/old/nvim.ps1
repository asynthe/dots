# --------------- Neovim configuration ---------------

# Define the list of source folders to symlink (Neovim and Starship)
$foldersToSymlink = @(
    "C:\path\to\config\nvim",  # Path to your Neovim configuration folder
    "C:\path\to\config\starship"  # Path to your Starship configuration folder
)

# Define the base target path in LOCALAPPDATA
$targetBasePath = $env:LOCALAPPDATA

# Check if the script is being run as Administrator
$IsAdmin = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Not running as Administrator. Restarting with elevated privileges..."
    
    # Restart script as Administrator
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs
    return
}

# Loop through each folder and create a symlink
foreach ($folder in $foldersToSymlink) {
    # Define the target path using the folder name (base folder name without path)
    $folderName = Split-Path $folder -Leaf
    $targetPath = Join-Path $targetBasePath $folderName

    # Check if the source folder exists
    if (Test-Path $folder) {
        # Remove existing symlink if it exists
        if (Test-Path $targetPath) {
            Write-Host "Removing existing symlink at $targetPath"
            Remove-Item $targetPath -Recurse -Force
        }

        # Create the symbolic link for this folder
        Write-Host "Creating symlink for folder:"
        Write-Host "  From: $folder"
        Write-Host "  To:   $targetPath"
        New-Item -ItemType SymbolicLink -Path $targetPath -Target $folder
    } else {
        Write-Host "Source folder does not exist: $folder"
    }
}

Write-Host "Symlink creation completed."
