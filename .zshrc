# git init --bare $HOME/.cfg
# alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
# config config --local status.showUntrackedFiles no
# echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.bashrc

autoload -U promptinit; promptinit
autoload -Uz compinit && compinit

eval "$(starship init zsh)"

precmd() { precmd() { echo "" } }
alias clear="precmd() { precmd() { echo } } && clear"

#Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# History setup
setopt APPEND_HISTORY
setopt SHARE_HISTORY
HISTFILE=$HOME/.zsh_history
SAVEHIST=1000
HISTSIZE=999
setopt HIST_EXPIRE_DUPS_FIRST
setopt EXTENDED_HISTORY

# Vim mode
bindkey -v
alias ls='exa'
alias gitdot="git remote remove origin; git remote add origin git@github.com:abhishek-kaith/.dotfiles.git;"
alias wproxystart="adb shell settings put global http_proxy 192.168.240.1:8080"
alias wproxystop="adb shell settings put global http_proxy :0"
alias sdb="xdg-settings set default-web-browser firefox.desktop"
bindkey -s '^f' 'tmux-sessionizer^M'
bindkey -s '^g' 'tmux neww tmux-cht.sh^M'
export PATH="/home/kai/.config/herd-lite/bin:$PATH"
export PHP_INI_SCAN_DIR="/home/kai/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
