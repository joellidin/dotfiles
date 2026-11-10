# The profile is sourced by the login session, as .zprofile and again below, and nested shells
# repeat it; keep only the first copy of each PATH entry (lookup order is unchanged).
typeset -U path PATH
source $HOME/.config/zsh/.zprofile
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""
# ZSH_THEME_RANDOM_CANDIDATES=(
#   "robbyrussell"
#   "pure"
# )

# Set list of themes to pick from when loading at random
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-autosuggestions
  history-substring-search
  zsh-fzf-history-search
  zsh-syntax-highlighting
  gopass
  kubectl
  uv
  rust
  herdr
)

# zcompdump clean up for oh-my-zsh
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$HOST-$ZSH_VERSION"
source $ZSH/oh-my-zsh.sh


globalias() {
   # Get last word to the left of the cursor:
   # (z) splits into words using shell parsing
   # (A) makes it an array even if there's only one element
   local word=${${(Az)LBUFFER}[-1]}
   if [[ $GLOBALIAS_FILTER_VALUES[(Ie)$word] -eq 0 ]]; then
      zle _expand_alias
      zle expand-word
   fi
   zle self-insert
}
zle -N globalias

# space expands all aliases, including global
bindkey -M emacs "^ " globalias
bindkey -M viins "^ " globalias
bindkey -M viins "^R" fzf_history_search
bindkey -M vicmd "^R" fzf_history_search

# control-space to make a normal space
bindkey -M emacs " " magic-space
bindkey -M viins " " magic-space

# normal space during searches
bindkey -M isearch " " magic-space

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#

if [ -f $HOME/.config/shell/aliasrc ]; then
    . $HOME/.config/shell/aliasrc
fi

# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# fpath+=$HOME/.local/src/oh-my-zsh/custom/themes/pure
# autoload -U promptinit; promptinit
# prompt pure
eval "$(starship init zsh)"
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"


# History settings
export HISTSIZE=10000000
export SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
unsetopt PROMPT_SP


# Set vi mode
setopt vi
# Esc enters normal mode after 10 ms instead of 0.4 s (no two-key insert-mode bindings rely on the wait)
KEYTIMEOUT=1

# herdr starts a fresh shell in the project dir for every new pane, tab and workspace.
# This replaces the tmux send-keys "source .venv/bin/activate" hack in the c, D and
# sessionizer bindings. Drop the HERDR_ENV test to get the same behaviour everywhere.
if [[ -n $HERDR_ENV && -z $VIRTUAL_ENV && -d .venv ]]; then
    source .venv/bin/activate
fi

# Project switcher on ^f.
#   inside herdr   -> herdr-sessionizer focuses or creates a workspace
#   plain terminal -> herdr-sessionizer starts or attaches herdr in the chosen project
# No stdout redirect: the script may exec the herdr TUI.
function sessionizer() {
    zle push-input
    BUFFER="herdr-sessionizer"
    zle accept-line
}
zle -N sessionizer
bindkey -M viins '^f' sessionizer
bindkey -M vicmd '^f' sessionizer
# clean up
# compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/zcompcache

. "$HOME/.local/share/cargo/env"

. "$HOME/.local/share/../bin/env"

# Basilica CLI
. "$HOME/.basilica/env"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
