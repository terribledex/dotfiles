# Path to your Oh My Zsh installation directory
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="dex-catppuccin-neon"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# История команд
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups
setopt share_history

# Поддержка fzf (если установлен)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Подсветка синтаксиса (если установлен)
[[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Автоподсказки (если установлен)
[[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# TheFuck (must have if you don't)
eval $(thefuck --alias)

# Windsurf IDE PATH
export PATH="/Users/etozhedex/.codeium/windsurf/bin:$PATH"

# Brew PATH 
export PATH="/opt/homebrew/bin:$PATH"

# EDITOR
export EDITOR="nvim"

# Цвета ls (через eza или ls)
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Aliases 
alias l='eza -alh'
alias tree='eza --tree'
alias tping='ping -c 100 8.8.8.8'
alias ll='ls -plah'
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias update='brew update && brew upgrade && omz update'
alias reload='source ~/.zshrc'
alias cls='clear && printf "\e[3J"'
alias n='nvim'

# Welcoming message 
echo "The work which we do with pleasure heals the wear and tear of the day better than rest."
export PATH="$HOME/.local/bin:$PATH"

unsetopt correct
unsetopt correctall


# --- experimental ---
# oh-my-posh extension prompt. config can be located in every directory, just set the right path to it
eval "$(oh-my-posh init zsh --config ~/catppuccin.omp.json)"

