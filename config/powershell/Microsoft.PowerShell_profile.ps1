#Clear-Host
#figlet -f "Merlin1" Powershellhell"
#$host.ui.RawUI.BackgroundColor = "Black"
#$host.ui.RawUI.ForegroundColor = "Green"

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
