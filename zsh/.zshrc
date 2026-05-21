# ===== SYSTEM INFO =====
fastfetch

# ===== ZINIT SETUP =====
ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# ===== COMPLETIONS =====
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ===== HISTORY =====
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="${HOME}/.zsh_history"
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

# ===== PLUGINS VIA ZINIT =====
zinit snippet OMZP::fzf
zinit ice wait lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions
zinit ice wait lucid
zinit light zdharma-continuum/fast-syntax-highlighting
zinit ice wait lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions
zinit ice wait lucid
zinit light Aloxaf/fzf-tab

zstyle ':completion:*:options' sort false
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath'

# ===== PATH & ENV =====
fpath=("${HOME}/.zsh_completions" $fpath)

export PATH="$PATH:${HOME}/.local/bin"
export ZDOTDIR="${HOME}"
export AWS_SDK_LOAD_CONFIG=1

# ===== INTEGRATIONS =====
[ -f "${HOME}/.fzf.zsh" ] && source "${HOME}/.fzf.zsh"
export FZF_CTRL_R_OPTS="--reverse --header 'Press CTRL-Y to copy, CTRL-/ to toggle preview' --preview 'echo {}' --preview-window 'up:3:wrap,hidden' --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' --bind 'ctrl-/:toggle-preview' --bind 'ctrl-r:toggle-sort' --color header:italic"

eval "$(mise activate zsh --shims)"
eval "$(zoxide init zsh)"

# ===== KEYBINDINGS =====
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

# ===== SHELL OPTIONS =====
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt INTERACTIVE_COMMENTS

# ===== ALIASES =====
alias reload="source ~/.zshrc"
alias zshrc="cursor ~/Untitled/kennysliding/dotfiles/zsh/.zshrc"
alias cd="z"
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first"
alias lt="eza --tree --level=2 --icons"
alias cat="bat --paging=never"
alias grep="rg"
alias find="fd"
alias du="dust"
alias top="btm"
alias lg="lazygit"
alias y="yazi"

# ===== GITHUB PROFILES HOOK =====
autoload -Uz add-zsh-hook
_set_gh_config() {
    if [[ "$PWD" == "$HOME/Code"* ]]; then
        export GH_CONFIG_DIR="$HOME/.config/gh-premialab"
    elif [[ "$PWD" == "$HOME/Untitled/kennysliding"* ]]; then
        export GH_CONFIG_DIR="$HOME/.config/gh-kennysliding"
    else
        unset GH_CONFIG_DIR
    fi
}
add-zsh-hook chpwd _set_gh_config
_set_gh_config

# ===== PNPM =====
export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ===== STARSHIP PROMPT =====
eval "$(starship init zsh)"

# Transient Prompt
# Transient prompt for starship in zsh
zle-line-init() {
  emulate -L zsh

  [[ $CONTEXT == start ]] || return 0

  while true; do
    zle .recursive-edit
    local -i ret=$?
    [[ $ret == 0 && $KEYS == $'\4' ]] || break
    [[ -o ignore_eof ]] || exit 0
  done

  local saved_prompt=$PROMPT
  local saved_rprompt=$RPROMPT
  PROMPT='$(starship module character)'
  RPROMPT=''
  zle .reset-prompt
  PROMPT=$saved_prompt
  RPROMPT=$saved_rprompt

  if (( ret )); then
    zle .send-break
  else
    zle .accept-line
  fi
  return ret
}

zle -N zle-line-init