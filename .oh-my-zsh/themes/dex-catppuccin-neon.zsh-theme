# Двухэтажный промпт в стиле Catppuccin с неоновыми акцентами

# Цветовая палитра Catppuccin Mocha с неоновыми акцентами
typeset -A CATPPUCCIN_COLORS
CATPPUCCIN_COLORS[base]='#1e1e2e'
CATPPUCCIN_COLORS[mantle]='#181825'
CATPPUCCIN_COLORS[crust]='#11111b'
CATPPUCCIN_COLORS[text]='#cdd6f4'
CATPPUCCIN_COLORS[subtext0]='#a6adc8'
CATPPUCCIN_COLORS[subtext1]='#bac2de'
CATPPUCCIN_COLORS[surface0]='#313244'
CATPPUCCIN_COLORS[surface1]='#45475a'
CATPPUCCIN_COLORS[surface2]='#585b70'
CATPPUCCIN_COLORS[overlay0]='#6c7086'
CATPPUCCIN_COLORS[overlay1]='#7f849c'
CATPPUCCIN_COLORS[overlay2]='#9399b2'
# Неоновые акценты
CATPPUCCIN_COLORS[blue]='#89b4fa'
CATPPUCCIN_COLORS[lavender]='#b4befe'
CATPPUCCIN_COLORS[sapphire]='#74c7ec'
CATPPUCCIN_COLORS[sky]='#89dceb'
CATPPUCCIN_COLORS[teal]='#94e2d5'
CATPPUCCIN_COLORS[green]='#a6e3a1'
CATPPUCCIN_COLORS[yellow]='#f9e2af'
CATPPUCCIN_COLORS[peach]='#fab387'
CATPPUCCIN_COLORS[maroon]='#eba0ac'
CATPPUCCIN_COLORS[red]='#f38ba8'
CATPPUCCIN_COLORS[mauve]='#cba6f7'
CATPPUCCIN_COLORS[pink]='#f5c2e7'
CATPPUCCIN_COLORS[flamingo]='#f2cdcd'
CATPPUCCIN_COLORS[rosewater]='#f5e0dc'

# Функции для работы с цветами
catppuccin_color() {
    echo "%F{${CATPPUCCIN_COLORS[$1]}}"
}

catppuccin_reset() {
    echo "%f"
}

# Переменная для отслеживания времени выполнения команды
typeset -g CMD_START_TIME

# Хук для записи времени начала команды
preexec() {
    CMD_START_TIME=$(date +%s.%3N)
}

# Функция для расчета времени выполнения команды
get_cmd_duration() {
    if [[ -n $CMD_START_TIME ]]; then
        local end_time=$(date +%s.%3N)
        local duration
        
        # Проверяем наличие bc, если нет - используем простое вычитание
        if command -v bc >/dev/null 2>&1; then
            duration=$(echo "$end_time - $CMD_START_TIME" | bc)
            
            if (( $(echo "$duration >= 1" | bc -l) )); then
                if (( $(echo "$duration >= 60" | bc -l) )); then
                    local minutes=$(printf "%.0f" $(echo "$duration / 60" | bc))
                    local seconds=$(printf "%.1f" $(echo "$duration % 60" | bc))
                    echo "${minutes}m ${seconds}s"
                else
                    echo "$(printf "%.2f" $duration)s"
                fi
            else
                local milliseconds=$(printf "%.0f" $(echo "$duration * 1000" | bc))
                echo "${milliseconds}ms"
            fi
        else
            # Упрощенное вычисление без bc
            duration=$(printf "%.2f" $((end_time - CMD_START_TIME)))
            if (( duration >= 1 )); then
                echo "${duration}s"
            else
                echo "$(printf "%.0f" $((duration * 1000)))ms"
            fi
        fi
        unset CMD_START_TIME
    fi
}

# Функция для получения информации о Git
git_prompt_info_custom() {
    if git rev-parse --git-dir &> /dev/null; then
        local ref branch_name git_status status_color
        
        ref=$(git symbolic-ref HEAD 2> /dev/null) || \
        ref=$(git rev-parse --short HEAD 2> /dev/null) || return 0
        
        branch_name="${ref#refs/heads/}"
        
        # Проверяем статус репозитория
        local git_status_output=$(git status --porcelain 2> /dev/null)
        
        if [[ -n $git_status_output ]]; then
            if echo "$git_status_output" | grep -q '^??'; then
                status_color="red"
                git_status="●"
            elif echo "$git_status_output" | grep -q '^[MADRC]'; then
                status_color="yellow"
                git_status="●"
            else
                status_color="peach"
                git_status="●"
            fi
        else
            status_color="green"
            git_status="●"
        fi
        
        echo " $(catppuccin_color overlay1)│$(catppuccin_reset) $(catppuccin_color sapphire)$(catppuccin_reset) $(catppuccin_color text)$branch_name$(catppuccin_reset) $(catppuccin_color $status_color)$git_status$(catppuccin_reset)"
    fi
}

# Функция для сокращения длинного пути
shrink_path() {
    local path="$PWD"
    local home="$HOME"
    
    # Заменяем домашнюю директорию на ~
    if [[ "$path" == "$home"* ]]; then
        path="~${path#$home}"
    fi
    
    # Если путь длиннее 50 символов, сокращаем его
    if [[ ${#path} -gt 50 ]]; then
        local IFS='/'
        local path_array=($path)
        local result=""
        local last_index=$((${#path_array[@]} - 1))
        
        # Всегда показываем последние 2 директории полностью
        for i in "${!path_array[@]}"; do
            if [[ $i -eq 0 && "${path_array[0]}" == "~" ]]; then
                result="~"
            elif [[ $i -ge $((last_index - 1)) ]]; then
                result="$result/${path_array[$i]}"
            elif [[ $i -eq 1 ]]; then
                result="$result/${path_array[$i]:0:1}"
            else
                result="$result/${path_array[$i]:0:1}"
            fi
        done
        echo "${result#/}"
    else
        echo "$path"
    fi
}

# Основная функция промпта
build_prompt() {
    local user_host="$(catppuccin_color mauve)%n$(catppuccin_reset)$(catppuccin_color overlay1)@$(catppuccin_reset)$(catppuccin_color blue)%m$(catppuccin_reset)"
    local current_path="$(catppuccin_color overlay1)│$(catppuccin_reset) $(catppuccin_color pink)$(catppuccin_reset) $(catppuccin_color yellow)$(shrink_path)$(catppuccin_reset)"
    local git_info="$(git_prompt_info_custom)"
    
    local left_prompt="${user_host}${current_path}${git_info}"
    
    local current_time="$(catppuccin_color teal)%D{%H:%M:%S}$(catppuccin_reset)"
    local cmd_time=""
    local duration=$(get_cmd_duration)
    if [[ -n $duration ]]; then
        cmd_time=" $(catppuccin_color overlay1)│$(catppuccin_reset) $(catppuccin_color peach)$(catppuccin_reset) $(catppuccin_color subtext1)$duration$(catppuccin_reset)"
    fi
    
    local right_prompt="${cmd_time} $(catppuccin_color overlay1)│$(catppuccin_reset) $(catppuccin_color lavender)$(catppuccin_reset) ${current_time}"
    
    # Вычисляем длину строки без ANSI последовательностей для выравнивания
    local left_length=${#${(S%%)left_prompt//(\%([KF1]|)\{*\}|\%[Bbkf])}}
    local right_length=${#${(S%%)right_prompt//(\%([KF1]|)\{*\}|\%[Bbkf])}}
    local terminal_width=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}
    local spaces_needed=$((terminal_width - left_length - right_length))
    
    if [[ $spaces_needed -lt 0 ]]; then
        spaces_needed=0
    fi
    
    # Первая строка с выравниванием
    local first_line="${left_prompt}${(l:spaces_needed:: :)}${right_prompt}"
    
    # Вторая строка (промпт ввода)
    local second_line="$(catppuccin_color surface1)╰─$(catppuccin_reset) $(catppuccin_color green)❯$(catppuccin_reset) "
    
    echo "${first_line}"$'\n'"${second_line}"
}

update_terminal_title() {
    print -Pn "\e]0;%n@%m: %~\a"
}

# Устанавливаем промпт
setopt PROMPT_SUBST
PROMPT='$(build_prompt)'

# Отключаем правый промпт Oh My Zsh
RPROMPT=""

# Хуки Oh My Zsh
autoload -U add-zsh-hook
add-zsh-hook precmd update_terminal_title

# Включаем поддержку 256 цветов
export TERM="${TERM:-xterm-256color}"
