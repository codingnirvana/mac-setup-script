#!/bin/bash

brews=(
  archey
  bash
  git
  git-extras
  htop
  httpie
  mtr
  node
  openvpn
  postgresql
  pgcli
  nmap
  python
  ruby
  scala211
  sbt
  tmux
  zsh
  tree
  s3cmd
  vim --with-override-system-vi
  wget --with-iri
  maven
  mackup
)

casks=(
  atom
  betterzipql
  cakebrew
  cleanmymac
  dropbox
  firefox
  freemind
  google-chrome
  intellij-idea-ce
  iterm2
  kindle
  slack
  screenhero
  skype
  vlc
  tunnelblick
  sublime-text
  visual-studio-code
)

pips=(
  pip
  s4cmd
  glances
  pythonpy
)

gems=(
  bundle
)

npms=(
  coffee-script
  grunt
)

vscode=(
  donjayamanne.python
  dragos.scala-lsp
  lukehoban.Go
  ms-vscode.cpptools
  rebornix.Ruby
  redhat.java
)

######################################## End of app list ########################################
set +e


if test ! $(which brew); then
  echo "Installing Xcode ..."
  xcode-select --install

  echo "Installing Homebrew ..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Updating Homebrew ..."
  brew update
  brew upgrade
fi
brew doctor
brew tap homebrew/dupes

fails=()

function print_red {
  red='\x1B[0;31m'
  NC='\x1B[0m' # no color
  echo -e "${red}$1${NC}"
}

function install {
  cmd=$1
  shift
  for pkg in $@;
  do
    exec="$cmd $pkg"
    echo "Executing: $exec"
    if $exec ; then
      echo "Installed $pkg"
    else
      fails+=($pkg)
      print_red "Failed to execute: $exec"
    fi
  done
}

function proceed_prompt {
  read -p "Proceed with installation? " -n 1 -r
  if [[ $REPLY =~ ^[Nn]$ ]]
  then
    exit 1
  fi
}

echo "Install Java"
brew cask install java8

brew info ${brews[@]}
proceed_prompt
install 'brew install' ${brews[@]}

brew install caskroom/cask/brew-cask
brew tap caskroom/versions

brew cask info ${casks[@]}
proceed_prompt
install 'brew cask install --appdir=/Applications' ${casks[@]}

echo "Install pip"
install 'easy_install pip'

# TODO: add info part of install
install 'pip install' ${pips[@]}
install 'gem install' ${gems[@]}
install 'npm install -g' ${npms[@]}
install 'code --install-extension' ${vscode[@]}

echo "Setting up zsh ..."
curl -L http://install.ohmyz.sh | sh
chsh -s $(which zsh)
# TODO: Auto-set theme to "fino-time" in ~/.zshrc (using antigen?)
curl -sSL https://get.rvm.io | bash -s stable  # required for some zsh-themes

echo "Setting git defaults ..."
git config --global rerere.enabled true
git config --global branch.autosetuprebase always
git config --global credential.helper osxkeychain
git config --global user.name $1
git config --global user.email $2

echo "Upgrading ..."
pip install --upgrade setuptools
pip install --upgrade pip
gem update --system

prompt "Install mac CLI [NOTE: Say NO to bash-completions since we have fzf]!"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/guarinogabriel/mac-cli/master/mac-cli/tools/install)"

echo "Update packages"
pip3 install --upgrade pip setuptools wheel
mac update

echo "Cleaning up ..."
brew cleanup
brew cask cleanup

for fail in ${fails[@]}
do
  echo "Failed to install: $fail"
done

read -p "Run `mackup restore` after DropBox has done syncing"
echo "Done"
