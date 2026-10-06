# -----------------------
# CONFIGURATION
# -----------------------
$taskName = "RotateWallpapers"
$scriptPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "Set-RandomWallpapers.ps1"

# -----------------------
# SCHEDULED TASK SETUP
# -----------------------
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Daily -At 9:00AM
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -Force

Write-Host "✅ Scheduled task '$taskName' created to run daily at 9:00 AM"
