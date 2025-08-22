# Catppuccin Mocha Oh-My-Zsh Theme

local rosewater='%F{#fef7ed}'
local flamingo='%F{#f2cdcd}'
local pink='%F{#f5c2e7}'
local mauve='%F{#cba6f7}'
local red='%F{#f38ba8}'
local maroon='%F{#eba0ac}'
local peach='%F{#fab387}'
local yellow='%F{#f9e2af}'
local green='%F{#a6e3a1}'
local teal='%F{#94e2d5}'
local sky='%F{#89dceb}'
local sapphire='%F{#74c7ec}'
local blue='%F{#89b4fa}'
local lavender='%F{#b4befe}'
local text='%F{#cdd6f4}'
local subtext1='%F{#bac2de}'
local subtext0='%F{#a6adc8}'
local overlay2='%F{#9399b2}'
local overlay1='%F{#7f849c}'
local overlay0='%F{#6c7086}'
local surface2='%F{#585b70}'
local surface1='%F{#45475a}'
local surface0='%F{#313244}'
local base='%F{#1e1e2e}'
local mantle='%F{#181825}'
local crust='%F{#11111b}'
local reset='%f'

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
    if [[ -n $timer_show ]]; then
        local hours=$((timer_show / 3600))
        local minutes=$(((timer_show % 3600) / 60))
        local seconds=$((timer_show % 60))
        
        if [[ $hours -gt 0 ]]; then
            echo "${overlay1}took ${hours}h ${minutes}m ${seconds}s${reset}"
        elif [[ $minutes -gt 0 ]]; then
            echo "${overlay1}took ${minutes}m ${seconds}s${reset}"
        elif [[ $seconds -gt 5 ]]; then  # Only show if > 5 seconds
            echo "${overlay1}took ${seconds}s${reset}"
        fi
    fi
}

function git_prompt_info() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch_name="$(git_current_branch)"
        local git_status=""
        local git_color=""
        
        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            git_color="$red"
            git_status="●"
        else
            git_color="$green"
            git_status="✓"
        fi
        
        local ahead_behind=""
        local upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
        if [[ -n "$upstream" ]]; then
            local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
            local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
            
            if [[ $ahead -gt 0 ]]; then
                ahead_behind="${ahead_behind}${blue}↑${ahead}"
            fi
            if [[ $behind -gt 0 ]]; then
                ahead_behind="${ahead_behind}${yellow}↓${behind}"
            fi
        fi
        
        local staged=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        local modified=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        local untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
        
        local file_status=""
        if [[ $staged -gt 0 ]]; then
            file_status="${file_status}${green}+${staged}"
        fi
        if [[ $modified -gt 0 ]]; then
            file_status="${file_status}${yellow}~${modified}"
        fi
        if [[ $untracked -gt 0 ]]; then
            file_status="${file_status}${red}?${untracked}"
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
        echo "${red}%n${reset}"  # Red for root
    else
        echo "${mauve}%n${reset}"  # Mauve for regular user
    fi
}

function host_info() {
    if [[ -n $SSH_CONNECTION ]]; then
        echo "${peach}%m${reset}"  # Peach for SSH connections
    else
        echo "${green}%m${reset}"  # Green for local
    fi
}

function dir_info() {
    echo "${yellow}%~${reset}"
}

function return_status() {
    echo "%(?:${green}❯:${red}❯)${reset}"
}

setopt PROMPT_SUBST

PROMPT='${blue}┌─[$(user_info)${text}@$(host_info)${blue}]─[$(dir_info)${blue}]$(git_prompt_info)
${blue}└─$(return_status) '

RPROMPT='$(format_time)'

ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

setopt CORRECT

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
