{ pkgs, ... }: {
    programs.zsh = {

	    # Plugins
	    autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
	    plugins = [
	        {
	            name = "vi-mode";
	            src = pkgs.zsh-vi-mode;
	            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
	        }
	    ];

	    initExtra = ''
# Keybinds
zmodload zsh/complist
bindkey -M menuselect '^[[Z' reverse-menu-complete

# Run after 5 minutes of inactivity.
TMOUT=300;
TRAPALRM() { ${pkgs.pipes-rs}/bin/pipes-rs }
#TRAPALRM() { unimatrix -s 93 }

# ZSH options (setopt)
while read -r option; do
    setopt $option
done <<-EOF
APPEND_HISTORY
HIST_IGNORE_DUPS
HIST_IGNORE_SPACE
INC_APPEND_HISTORY
INTERACTIVE_COMMENTS
NO_BEEP
EOF

# zsh-vi-mode configuration
function zvm_config() {
    ZVM_CURSOR_STYLE=true
    ZVM_LINE_INIT_MODE=$ZVM_MODE_NORMAL
    #ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
    ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
    ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
    ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLOCK
} 
        '';
    };
}
