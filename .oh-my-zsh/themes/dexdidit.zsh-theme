# Should be saved as: ~/.oh-my-zsh/themes/catppuccin-luxury.zsh-theme

# Catppuccin Mocha Color Palette - Enhanced with brighter variants
local rosewater='%F{#ffeee6}'
local flamingo='%F{#ff9999}'
local pink='%F{#ff66cc}'
local mauve='%F{#dd88ff}'
local red='%F{#ff6b9d}'
local maroon='%F{#ff7ba3}'
local peach='%F{#ffaa44}'
local yellow='%F{#ffdd44}'
local green='%F{#66ff99}'
local teal='%F{#44ddaa}'
local sky='%F{#44ccff}'
local sapphire='%F{#3399ff}'
local blue='%F{#6699ff}'
local lavender='%F{#cc99ff}'
local text='%F{#ffffff}'
local subtext1='%F{#e6e6ff}'
local subtext0='%F{#ccccff}'
local overlay2='%F{#b3b3dd}'
local overlay1='%F{#9999cc}'
local overlay0='%F{#8888bb}'
local reset='%f'

# Neon lights 
local neon_green='%F{#00ff88}'
local neon_blue='%F{#00aaff}'
local neon_pink='%F{#ff0099}'
local gold='%F{#ffd700}'
local cyan='%F{#00ffff}'

# Timer functionality (simplified)
function preexec() {
    timer=${timer:-$SECONDS}
}

function precmd() {
    if [ $timer ]; then
        timer_show=$(($SECONDS - $timer))
        unset timer
    fi
}

function format_time() {
    if [[ -n $timer_show && $timer_show -gt 3 ]]; then
        local speed_color=""
        if [[ $timer_show -lt 10 ]]; then
            speed_color="$neon_green"
        elif [[ $timer_show -lt 60 ]]; then
            speed_color="$yellow"
        else
            speed_color="$red"
        fi
        echo "${speed_color}${timer_show}s${reset}"
    fi
}

function git_prompt_info() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch_name="$(git_current_branch)"
        local git_status=""
        local git_color=""

        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            git_color="$neon_pink"
            git_status="●"
        else
            git_color="$neon_green"
            git_status="●"
        fi

        local ahead_behind=""
        local upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
        if [[ -n "$upstream" ]]; then
            local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
            local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")

            if [[ $ahead -gt 0 ]]; then
                ahead_behind="${ahead_behind}${neon_blue}↑${ahead}"
            fi
            if [[ $behind -gt 0 ]]; then
                ahead_behind="${ahead_behind}${yellow}↓${behind}"
            fi
        fi

        local file_status=""
        local staged=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        local modified=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        local untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

        if [[ $staged -gt 0 ]]; then
            file_status="${file_status}${neon_green}+${staged}"
        fi
        if [[ $modified -gt 0 ]]; then
            file_status="${file_status}${gold}~${modified}"
        fi
        if [[ $untracked -gt 0 ]]; then
            file_status="${file_status}${neon_pink}?${untracked}"
        fi

        local git_info="${git_color}${git_status} ${branch_name}${ahead_behind}"
        if [[ -n "$file_status" ]]; then
            git_info="${git_info} ${file_status}"
        fi

        echo " ${blue}[${git_info}${blue}]${reset}"
    fi
}

function user_info() {
    if [[ $EUID -eq 0 ]]; then
        echo "${neon_pink}%n${reset}"  # Яркий розовый для root
    else
        echo "${mauve}%n${reset}"  # Лиловый для обычного пользователя
    fi
}

# Хост с индикацией подключения
function host_info() {
    if [[ -n $SSH_CONNECTION ]]; then
        echo "${peach}%m${reset}"  # Персиковый для SSH
    else
        echo "${neon_green}%m${reset}"  # Неоновый зеленый для локального
    fi
}

function dir_info() {
    echo "${yellow}%~${reset}"
}

# Статус возврата с градиентными стрелками
function return_status() {
    local success_arrow="${neon_green}❯${green}❯${teal}❯"
    local error_arrow="${neon_pink}❯${red}❯${maroon}❯"
    echo "%(?:${success_arrow}:${error_arrow})${reset}"
}

function prompt_connector() {
    echo "${blue}──${cyan}◆${blue}──${reset}"
}

setopt PROMPT_SUBST

# Основной промпт 
PROMPT='${cyan}╭─${blue}[$(user_info)${text}@$(host_info)${blue}]$(prompt_connector)${blue}[$(dir_info)${blue}]$(git_prompt_info)
${cyan}╰─$(return_status) '

RPROMPT='$(format_time)'

# Настройки oh-my-zsh для git
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

# Включаем коррекцию команд
setopt CORRECT
SPROMPT="${yellow}Исправить ${red}'%R'${yellow} на ${green}'%r'${reset}? [y/n/a/e]: "

# История команд
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

function precmd() {
    if [ $timer ]; then
        timer_show=$(($SECONDS - $timer))
        unset timer
    fi
    echo -ne "\033]0;${PWD##*/}\007"
}

function preexec() {
    timer=${timer:-$SECONDS}
}
