#!/bin/bash

# Mac Developer Setup Script
# Based on current system analysis and best practices for 2025

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    log_error "This script is for macOS only!"
    exit 1
fi

log_info "🚀 Starting Mac Developer Setup..."

# ============================================================================
# 1. SYSTEM PREPARATION
# ============================================================================

setup_xcode() {
    log_info "Installing Xcode Command Line Tools..."
    if ! xcode-select --print-path &>/dev/null; then
        xcode-select --install
        log_warning "Please complete Xcode installation and re-run this script"
        exit 1
    fi
    log_success "Xcode Command Line Tools installed"
}

setup_homebrew() {
    log_info "Installing Homebrew..."
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
    
    brew update
    log_success "Homebrew installed and updated"
}

# ============================================================================
# 2. ESSENTIAL DEVELOPER TOOLS
# ============================================================================

install_essential_tools() {
    log_info "Installing essential development tools..."
    
    # Core development tools
    local essential_formulas=(
        # Version Control & Development
        "git"
        "git-extras"
        "gh"                    # GitHub CLI
        
        # Programming Languages & Runtimes
        "node"
        "python@3.12"
        "python@3.11"
        "ruby"
        "rust"
        "go"
        
        # Databases
        "postgresql@16"
        "sqlite"
        "redis"
        
        # DevOps & Cloud
        "docker"
        "docker-compose"
        "terraform"
        "awscli"
        "aws-vault"
        "kubectl"
        "helm"
        "k9s"                  # Kubernetes cluster management
        "trivy"                # Security scanner
        
        # Modern Runtimes
        "bun"                  # Fast JavaScript runtime
        "deno"                 # Modern JS/TS runtime
        "uv"                   # Ultra-fast Python package manager
        "mise"                 # Modern version manager
        
        # AI/ML Tools
        "ollama"               # Local LLM runner
        
        # Network & System Tools
        "curl"
        "wget"
        "htop"
        "tree"
        "watch"
        "jq"                    # JSON processor
        "httpie"               # Better curl
        "nmap"
        "mtr"                  # Network diagnostics
        
        # Text Processing & Search
        "ripgrep"              # Better grep
        "fzf"                  # Fuzzy finder
        "fd"                   # Better find
        "bat"                  # Better cat
        "eza"                  # Better ls
        "zoxide"               # Smart cd replacement
        "bottom"               # Modern htop replacement
        "procs"                # Modern ps replacement
        "dust"                 # Modern du replacement
        "sd"                   # Modern sed replacement
        "delta"                # Better git diff viewer
        
        # Shell & Terminal
        "zsh"
        "tmux"
        "starship"             # Modern prompt
        
        # Security
        "gnupg"
        "pass"                 # Password manager
        "age"                  # Modern encryption
        "sops"                 # Secrets management
        "gitleaks"             # Git secrets scanner
        
        # Development Workflow
        "lazygit"              # Terminal git UI
        "act"                  # Run GitHub Actions locally
        "direnv"               # Directory-based env vars
        "tldr"                 # Simplified man pages
        
        # Utilities
        "mas"                  # Mac App Store CLI
        "trash"                # Safe rm
        "yt-dlp"               # Modern youtube-dl replacement
        "ffmpeg"
        "imagemagick"
    )
    
    brew install "${essential_formulas[@]}"
    log_success "Essential tools installed"
}

install_cask_apps() {
    log_info "Installing GUI applications..."
    
    local essential_casks=(
        # Development
        "visual-studio-code"
        "cursor"               # AI-powered editor
        "warp"                 # AI-powered terminal
        "iterm2"               # Traditional terminal
        "docker"
        "android-studio"
        "postman"
        "insomnia"             # REST client alternative
        "proxyman"             # HTTP debugging
        
        # Browsers
        "google-chrome"
        "firefox"
        "arc"
        
        # Communication
        "slack"
        "discord"
        "telegram"
        "zoom"
        
        # Productivity
        "raycast"              # AI-powered launcher (modern Alfred)
        "rectangle"            # Window management
        "dropbox"
        "the-unarchiver"
        "notion"               # Note-taking
        
        # Media
        "vlc"
        "spotify"
        
        # Security
        "1password"            # Password manager
        "1password-cli"        # 1Password CLI
        
        # Utilities
        "bartender"            # Menu bar organizer
    )
    
    brew install --cask "${essential_casks[@]}"
    log_success "GUI applications installed"
}

# ============================================================================
# 3. DEVELOPMENT ENVIRONMENT SETUP
# ============================================================================

setup_shell() {
    log_info "Setting up optimized shell environment..."
    
    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Install Powerlevel10k theme
    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
    fi
    
    # Install useful zsh plugins
    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions $plugins_dir/zsh-autosuggestions
    fi
    
    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $plugins_dir/zsh-syntax-highlighting
    fi
    
    log_success "Shell environment configured"
}

setup_python() {
    log_info "Setting up Python development environment..."
    
    # Install pyenv if not present
    if ! command -v pyenv &>/dev/null; then
        brew install pyenv pyenv-virtualenv
    fi
    
    # Install latest Python versions
    local python_versions=("3.12.0" "3.11.6")
    for version in "${python_versions[@]}"; do
        if ! pyenv versions | grep -q "$version"; then
            pyenv install "$version"
        fi
    done
    
    # Set global Python version
    pyenv global 3.12.0
    
    # Install essential Python packages
    pip install --upgrade pip
    pip install pipenv poetry black flake8 mypy pytest jupyter ipython
    
    log_success "Python environment configured"
}

setup_node() {
    log_info "Setting up Node.js development environment..."
    
    # Install nvm
    if [[ ! -d "$HOME/.nvm" ]]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        source ~/.nvm/nvm.sh
    fi
    
    # Install latest LTS Node.js
    nvm install --lts
    nvm use --lts
    nvm alias default node
    
    # Install essential global packages
    npm install -g \
        yarn \
        pnpm \
        typescript \
        ts-node \
        @angular/cli \
        @vue/cli \
        create-react-app \
        vercel \
        netlify-cli \
        prettier \
        eslint
    
    log_success "Node.js environment configured"
}

setup_git() {
    log_info "Configuring Git..."
    
    # Global Git configuration
    read -p "Enter your Git username: " git_username
    read -p "Enter your Git email: " git_email
    
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    git config --global pull.rebase true
    git config --global rebase.autoStash true
    git config --global merge.conflictStyle zdiff3
    git config --global rerere.enabled true
    git config --global fetch.prune true
    git config --global branch.sort -committerdate
    
    # Enhanced aliases
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.cm "commit -m"
    git config --global alias.cam "commit -am"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.visual "!gitk"
    
    log_success "Git configured"
}

# ============================================================================
# 4. MACOS SYSTEM OPTIMIZATION
# ============================================================================

optimize_macos_defaults() {
    log_info "Applying developer-optimized macOS defaults..."
    
    # Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    
    # Desktop & Screen Saver
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    
    # Dock
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock tilesize -int 36
    defaults write com.apple.dock minimize-to-application -bool true
    defaults write com.apple.dock show-process-indicators -bool true
    
    # Trackpad
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    
    # Keyboard
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    
    # Screenshots
    defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"
    defaults write com.apple.screencapture type -string "png"
    defaults write com.apple.screencapture disable-shadow -bool true
    
    # Activity Monitor
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
    defaults write com.apple.ActivityMonitor IconType -int 5
    defaults write com.apple.ActivityMonitor ShowCategory -int 0
    
    # TextEdit
    defaults write com.apple.TextEdit RichText -int 0
    defaults write com.apple.TextEdit PlainTextEncoding -int 4
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
    
    log_success "macOS defaults optimized"
}

create_development_directories() {
    log_info "Creating development directory structure..."
    
    mkdir -p ~/Development/{Projects,Playground,Archive}
    mkdir -p ~/Development/Projects/{Web,Mobile,Backend,Scripts}
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    
    log_success "Development directories created"
}

# ============================================================================
# 5. CONFIGURATION FILES
# ============================================================================

create_zshrc() {
    log_info "Creating optimized .zshrc..."
    
    cat > ~/.zshrc << 'EOF'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Optimize compinit - only check once a day
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"
else
  compinit -C -d "${ZDOTDIR:-$HOME}/.zcompdump"
fi

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker
  kubectl
  terraform
)

# Disable oh-my-zsh aliases to speed startup
zstyle ':omz:*' aliases no

source $ZSH/oh-my-zsh.sh

# History settings
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
HISTSIZE=50000
SAVEHIST=50000
HIST_STAMPS="dd.mm.yyyy"

# Environment variables
export EDITOR='code'
export PATH="$HOME/.local/bin:$PATH"

# Development environment setup
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi

# Node.js (nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# fzf configuration
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_R_OPTS='--preview "echo {}" --preview-window down:3:hidden:wrap --bind "?:toggle-preview"'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Initialize zoxide (smart cd)
eval "$(zoxide init zsh)"

# Initialize direnv
eval "$(direnv hook zsh)"

# Initialize mise (modern version manager)
eval "$(mise activate zsh)"

# Aliases
alias ll='eza -la'
alias la='eza -la'
alias l='eza -l'
alias tree='eza --tree'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias rm='trash'
alias ps='procs'
alias htop='bottom'
alias du='dust'
alias sed='sd'
alias cd='z'               # zoxide smart cd
alias h='history'
alias hg='history | grep'
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias lg='lazygit'         # Terminal git UI

# Load Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

    log_success ".zshrc created"
}

create_gitconfig() {
    log_info "Creating .gitconfig template..."
    
    cat > ~/.gitconfig_template << 'EOF'
[user]
    name = YOUR_NAME
    email = YOUR_EMAIL

[init]
    defaultBranch = main

[pull]
    rebase = true

[rebase]
    autoStash = true
    updateRefs = true

[merge]
    conflictStyle = zdiff3

[rerere]
    enabled = true

[fetch]
    prune = true
    pruneRemote = true

[branch]
    sort = -committerdate

[status]
    showUntrackedFiles = all

[alias]
    st = status
    co = checkout
    br = branch
    cm = commit -m
    cam = commit -am
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = !gitk
    a = add
    ap = add -p
    c = commit
    ca = commit -a
    f = fetch
    fo = fetch origin
    r = rebase
    ri = rebase -i
    rc = rebase --continue
    ra = rebase --abort

[color]
    ui = auto

[core]
    editor = code --wait
    autocrlf = input
    safecrlf = warn
EOF

    log_success ".gitconfig template created"
}

# ============================================================================
# 6. MAIN EXECUTION
# ============================================================================

main() {
    log_info "Mac Developer Setup Script v1.0"
    log_info "================================="
    
    # Ask for sudo upfront
    sudo -v
    
    # Keep sudo alive
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    
    # System preparation
    setup_xcode
    setup_homebrew
    
    # Install tools and applications
    install_essential_tools
    install_cask_apps
    
    # Setup development environments
    setup_shell
    setup_python
    setup_node
    setup_git
    
    # Optimize macOS
    optimize_macos_defaults
    create_development_directories
    
    # Create configuration files
    create_zshrc
    create_gitconfig
    
    # Setup fzf
    $(brew --prefix)/opt/fzf/install --all
    
    # Restart affected applications
    killall Finder Dock SystemUIServer 2>/dev/null || true
    
    log_success "🎉 Mac setup complete!"
    log_info "📝 Next steps:"
    log_info "1. Restart your terminal"
    log_info "2. Run 'p10k configure' to setup your prompt"
    log_info "3. Configure Git with your credentials"
    log_info "4. Install any additional apps from the Mac App Store"
    log_info "5. Configure your development environments"
    
    log_warning "⚠️  Some changes require a restart to take effect"
}

# Run the main function
main "$@"
EOF