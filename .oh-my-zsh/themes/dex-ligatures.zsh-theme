# Should be saved as: ~/.oh-my-zsh/themes/catppuccin.zsh-theme

# Catppuccin Mocha Color Palette
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

# Timer functionality
function preexec() {
    timer=${timer:-$SECONDS}
}

function precmd() {
    if [ $timer ]; then
        timer_show=$(($SECONDS - $timer))
        unset timer
    fi
}

# Format execution time with clock icon
function format_time() {
    local current_time="${overlay1}🕐 %D{%H:%M:%S}${reset}"
    
    if [[ -n $timer_show ]]; then
        local hours=$((timer_show / 3600))
        local minutes=$(((timer_show % 3600) / 60))
        local seconds=$((timer_show % 60))
        
        local exec_time=""
        if [[ $hours -gt 0 ]]; then
            exec_time=" ${overlay0}⏱ ${hours}h ${minutes}m ${seconds}s${reset}"
        elif [[ $minutes -gt 0 ]]; then
            exec_time=" ${overlay0}⏱ ${minutes}m ${seconds}s${reset}"
        elif [[ $seconds -gt 5 ]]; then  # Only show if > 5 seconds
            exec_time=" ${overlay0}⏱ ${seconds}s${reset}"
        fi
        
        echo "${current_time}${exec_time}"
    else
        echo "${current_time}"
    fi
}

# Current time display
function current_time() {
    echo "${overlay1}🕐 %D{%H:%M:%S}${reset}"
}

# Enhanced Git status function with ligatures
function git_prompt_info() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch_name="$(git_current_branch)"
        local git_status=""
        local git_color=""
        
        # Check repository status with beautiful icons
        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            git_color="$red"
            git_status=""  # Git branch with changes
        else
            git_color="$green"
            git_status=""  # Clean git branch
        fi
        
        # Get ahead/behind info with arrows
        local ahead_behind=""
        local upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
        if [[ -n "$upstream" ]]; then
            local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
            local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
            
            if [[ $ahead -gt 0 ]]; then
                ahead_behind="${ahead_behind}${blue}⇡${ahead}"
            fi
            if [[ $behind -gt 0 ]]; then
                ahead_behind="${ahead_behind}${yellow}⇣${behind}"
            fi
        fi
        
        # File status counts with beautiful icons
        local staged=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        local modified=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        local untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
        
        local file_status=""
        if [[ $staged -gt 0 ]]; then
            file_status="${file_status}${green}●${staged}"
        fi
        if [[ $modified -gt 0 ]]; then
            file_status="${file_status}${yellow}±${modified}"
        fi
        if [[ $untracked -gt 0 ]]; then
            file_status="${file_status}${red}…${untracked}"
        fi
        
        # Combine all git info
        local git_info="${git_color}${git_status} ${branch_name}${ahead_behind}"
        if [[ -n "$file_status" ]]; then
            git_info="${git_info} ${file_status}"
        fi
        
        echo " ${blue}[${git_info}${blue}]${reset}"
    fi
}

# User info with colors based on privileges
function user_info() {
    if [[ $EUID -eq 0 ]]; then
        echo "${red}%n${reset}"  # Red for root
    else
        echo "${mauve}%n${reset}"  # Mauve for regular user
    fi
}

# Host info with SSH detection
function host_info() {
    if [[ -n $SSH_CONNECTION ]]; then
        echo "${peach}%m${reset}"  # Peach for SSH connections
    else
        echo "${green}%m${reset}"  # Green for local
    fi
}

# Directory path with truncation for long paths
function dir_info() {
    echo "${yellow}%~${reset}"
}

# Return status indicator with beautiful arrows
function return_status() {
    echo "%(?:${green}❯:${red}❯)${reset}"
}

# Beautiful separators and connectors
function prompt_separator() {
    echo "${blue}───${reset}"
}

function prompt_connector() {
    echo "${blue}──${reset}"
}

# Main prompt configuration
setopt PROMPT_SUBST

# Left side prompt with beautiful ligatures
PROMPT='${blue}╭─${blue}[$(user_info)${text}@$(host_info)${blue}]$(prompt_connector)${blue}[$(dir_info)${blue}]$(git_prompt_info)
${blue}╰─$(return_status) '

# Right side prompt with execution time
RPROMPT='$(format_time)'

# Additional oh-my-zsh git settings
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

# Enable command correction
setopt CORRECT

# History settings
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
