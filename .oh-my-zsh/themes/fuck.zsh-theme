# Git Information Function
git_prompt_info() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    local git_status=""
    
    # Check for changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
      git_status="%F{red}*%f" # Modified files
    fi
    
    # Check for untracked files
    if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
      git_status="${git_status}%F{yellow}?%f" # Untracked files
    fi
    
    # Check for staged files
    if ! git diff-index --quiet --cached HEAD -- 2>/dev/null; then
      git_status="${git_status}%F{green}+%f" 
    fi
    
    echo " %F{blue}git:(%F{red}${branch}%F{blue})${git_status}%f"
  fi
}

# Time Function (Right Prompt)
time_prompt() {
  echo "%F{8}[%D{%H:%M:%S}]%f"
}

# Main Prompt (Left Side)
PROMPT='%F{magenta}╭∩╮(Ο_Ο)╭∩╮%f$(git_prompt_info) '

# Right Prompt (Time)
RPROMPT='$(time_prompt)'

# Prompt Options
setopt PROMPT_SUBST
