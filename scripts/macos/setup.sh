#! /bin/bash

echo "Welcome to meow's macos setup script!"
echo "ようこそ！"
sleep 2

HOMEBREW_NO_AUTO_UPDATE=1

echo "-------------- Checking if Homebrew is installed --------------"
sleep 0.7

if command -v brew >/dev/null 2>&1; then
  echo "Homebrew is already installed."
else
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if command -v brew >/dev/null 2>&1; then
    echo "Homebrew installation was successful."
  else
    echo "Homebrew installation failed, install manually then re-run."
    exit 1
  fi
fi

echo "-------------- Installing packages --------------"
sleep 0.7
brew_install() {
    echo "Installing $1"
    if brew list $1 &>/dev/null; then
        echo "${1} is already installed"
    else
        brew install $1 && echo "Installed $1"
        #brew install $1 >/dev/null 2>&1 && echo "Installed $1"
    fi
}

brew_install "
    direnv 
    eza
    ffmpeg 
    fzf
    imagemagick
    mpv 
    neovim
    nushell
    ripgrep 
    sk
    starship
    stow
    stow
    tmux
    tmuxp
    yazi
    zellij
    zoxide
"

echo "Installing emacs (Emacs Plus)..."
sleep 0.7
brew tap d12frosted/emacs-plus #>/dev/null 2>&1
brew install emacs-plus #>/dev/null 2>&1

echo "Installing Zathura..."
sleep 0.7
brew tap zegervdv/zathura #>/dev/null 2>&1
brew install zathura #>/dev/null 2>&1

echo "Setting up Zathura"
sleep 0.7
brew install zathura-pdf-mupdf #>/dev/null 2>&1
mkdir -p $(brew --prefix zathura)/lib/zathura #>/dev/null 2>&1
ln -s $(brew --prefix zathura-pdf-mupdf)/libpdf-mupdf.dylib $(brew --prefix zathura)/lib/zathura/libpdf-mupdf.dylib #>/dev/null 2>&1

echo "-------------- Installing packages (cask) --------------"
sleep 0.7
brew_install_cask() {
    echo "Installing $1"
    if brew list $1 &>/dev/null; then
        echo "${1} is already installed"
    else
        brew install --cask $1 && echo "Installed $1"
        #brew install --cask $1 >/dev/null 2>&1 && echo "Installed $1"
    fi
}

brew_install_cask "
    powershell
    wezterm
"

echo "-------------- Installing fonts (cask) --------------"
sleep 0.7
brew_install_cask_fonts() {
    echo "Installing $1"
    if brew list $1 &>/dev/null; then
        echo "${1} is already installed"
    else
        brew install --cask $1 && echo "Installed $1"
        #brew install --cask $1 >/dev/null 2>&1 && echo "Installed $1"
    fi
}

brew_install_cask_fonts "
    font-iosevka-nerd-font
    font-iosevka-term-nerd-font
    font-jetbrains-mono-nerd-font
"

echo "-------------- Installer has finished! --------------"


echo "Installer has finished!"
sleep 2

