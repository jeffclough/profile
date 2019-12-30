# If bash (<shudder/>) is sourcing this script, remember that and play nice.
#debug ".zshrc: \$0='$0'"
#debug ".zshrc: \$SHELL='$SHELL' (before)"
[[ "${0##*/}" == "bash" ]] && . ~/.bash_profile
#debug ".zshrc: \$SHELL='$SHELL' (after)"

# BEFORE sourcing any .rc-prolog code for this interactive session,
# enable iTerm's shell integration.
fn="$HOME/.iterm2_shell_integration.$(basename "$SHELL")"
debug "fn=$fn"
if [ -f "$fn" ]; then
  debug "Sourcing $fn"
  source "$fn"
  debug "Finished $fn"
fi
if [ -n "${functions[iterm2_set_user_var]}" ]; then
  # Make sure iTerm shell integration is turned on.
  export iTermShellIntegration=YES
  # Alias ALL the commands in ~/.iterm2.
  [ -d ~/.iterm2 ] && for cmd in ~/.iterm2/*; do
    [ -x $cmd -a ! -d $cmd ] && alias ${cmd##*/}=$cmd
  done
  # Add some hand shortcuts for making fireworks.
  alias fw='it2attention fireworks'
  alias fwe='it2attention fireworks;sleep 1;exit'
fi

# Run our prolog, if available.
fn="$HOME/.rc-prolog"
if [ -f "$fn" ]; then
  debug "Sourcing $fn"
  source "$fn"
  debug "Finished $fn"
fi

# Some general shell settings.
export CLICOLOR=1
# Good ls colors for dark terminal backgrounds:
export LSCOLORS=gxfxcxdxbxegbdabafacge
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=31;43:su=30;41:sg=30;45:tw=30;42:ow=36;44'
# Good ls colors for light terminal backgrounds:
#export LSCOLORS=exfxcxdxbxeghdhbafhcge
#export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=37;43:su=37;41:sg=30;45:tw=37;42:ow=36;44'

# Get the name of the current host and cook it a bit.
get_host_name() {
  /bin/hostname | sed -e 's/\.gatech\.edu$//' -e 's/.*\.bluehost\.com$/bluehost.com/' -e 's/\.local$//' -e 's/^ipsec-.*/GTmactop/' -e 's/^lawn-.*/GTmactop/' -e 's/192\.168\..*/mactop/' -e 's/^coda-.*/GTmactop/'
}

export -f get_host_name >/dev/null

#
# Set up command history:
#   If $HOME is mounted from a networked volume,
#       append HISTFILE with the name of the current host, and
#       use fcntl locking on $HISTFILE.
#   Expire duplicate commands first when trimming the histfile.
#   All sessions share history in realtime (implies incremental appending).
#
HISTFILE=~/.histfile
if [[ "${SHELL##*/}" == "zsh" ]]; then # This stuff is specific to zsh.
  if df $HOME | cut -d' ' -f1 | grep : >>/dev/null; then
    HISTFILE=$HISTFILE.$(get_host_name)
    setopt histfcntllock
  fi
  #setopt sharehistory
  setopt histexpiredupsfirst
  # histexpiredupsfirst needs HISTSIZE > SAVEHIST.
  HISTSIZE=1100
  SAVEHIST=1000
fi

# Set up command line editing and completion.
debug "\$SHELL=$SHELL before autoload"
debug "basename of \$SHELL=${SHELL##*/} before autoload"
if [[ "${SHELL##*/}" == "zsh" ]]; then
  bindkey -v
  if [[ "$osname" != "SunOS" ]]; then
    autoload -Uz compinit
    compinit
  fi
else
  set -o vi
fi

# Set the title of the emulator window.
windowtitle() {
  [[ -t 1 ]] || return
  case $TERM in
  sun-cmd) echo -en "\e]l$1\e\\"
    ;;
  vt220|*xterm*|ansi|rxvt|dtterm|kterm|Eterm) echo -en "\e]2;$1\a"
    ;;
  esac
}

# Set the title of the emulator tab.
tabtitle() {
  [[ -t 1 ]] || return
  case $TERM in
  vt220|*xterm*|ansi|rxvt|dtterm|kterm|Eterm) echo -en "\e]1;$1\a"
    ;;
  esac
}

# Identify the network we're on.
get_network_name() {
  if [[ "$osname" == "Darwin" ]]; then
    /bin/hostname | sed -e 's/^ipsec-.*/vpn/' -e 's/^lawn-.*/lawn/' -e 's/.*\.local$//' -e 's/.*\.gatech\.edu$//'
  fi
}

real_ip_time=0
get_real_ip() {
  local t
  if [[ "$osname" == "Darwin" ]]; then
    t=$(now -c)
    if [[ $(( t - real_ip_time )) -gt 10 ]]; then
      real_ip=$(curl -s ipchicken.com | pygrep -f '{}' '(^\d+\.\d+\.\d+\.\d+)')
      real_ip_time=$t
    fi
  fi
  echo $real_ip
}

# If PWD is in a Git repo, return the name of the current branch. Otherwise,
# return nothing.
git_branch() {
  local r
  r=$(git rev-parse --git-dir 2>>/dev/null)
  [ -n "$r" ] && basename $(cat $r/HEAD | cut -d' ' -f2)
}

# Before each prompt, show the host name in the terminal window's title bar.
precmd() {
  local mname=$(get_host_name)
  local branch=$(git_branch)
  local u=$(id -nu)
  [ -n "$branch" ] && branch=" (branch: $branch)"
  my_network=$(get_network_name)
  windowtitle "$u@$mname($$) $branch"
  tabtitle "$mname"
  [ -n "$iTermShellIntegration" ] && \
    iterm2_set_user_var badge "$(echo -e "$u\n$mname\n$my_network")"
  # Not prompt-related, but keep our session from timing out.
  unset TMOUT
}

# Set our prompt according to our effective uid.
#echo "D: .zshrc: \$ROOT_PROMPT_COLOR=$ROOT_PROMPT_COLOR (before)"
if [[ "${SHELL##*/}" == "zsh" ]]; then
  # Use zsh's enhanced prompt substitution.
  setopt PROMPT_SUBST
  # Root's prompt color defaults to yellow under zsh.
  export ROOT_PROMPT_COLOR=${ROOT_PROMPT_COLOR:-33}
else
  # Root's prompt color defaults to red under lesser shell.
  export ROOT_PROMPT_COLOR=${ROOT_PROMPT_COLOR:-31}
fi
#echo "D: .zshrc: \$ROOT_PROMPT_COLOR=$ROOT_PROMPT_COLOR (after)"
# User's prompt color defaults to green.
export USER_PROMPT_COLOR=${USER_PROMPT_COLOR:-32}
# Let lesser shells know what prompt color to use.
if [[ "$(id -u)" == "0" ]]; then 
  export PROMPT_COLOR=$ROOT_PROMPT_COLOR
else
  export PROMPT_COLOR=$USER_PROMPT_COLOR
fi
mname=$(get_host_name)
if [[ `uname -s` = "AIX" ]]; then
  PS1="%d%# "
else
  if [[ "${SHELL##*/}" == "zsh" ]]; then
    # Set the prompt content and color. Use the ROOT_PROMPT_COLOR and
    # USER_PROMPT_COLOR varaibles for the colors.
    PS1=$'%{\e[0;%(#.'"$ROOT_PROMPT_COLOR.$USER_PROMPT_COLOR"$')m%}$mname:%~%#%{\e[0m%} '
  else
    PS1="\[\e[${PROMPT_COLOR}m\]$(get_host_name):\w\\$\[\e[0m\] "
  fi
fi
export PS1

# Turn on timelog's color features.
export TIMELOG=-c

alias less='less -R '

if [[ "$osname" == 'SunOS' ]]; then
  alias ls='ls -F'
elif [[ "$osname" == 'Darwin' ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi
alias la='ls -a'
alias ll='ls -l'
alias llh='ll -h'
alias lla='ll -a'
alias lld='ll -d'
alias lrt='ll -rt'
alias lrtail='lrt|tail '

alias cgrep='grep --color'
alias cegrep='egrep --color'
alias pgrep='grep -P'
alias cpgrep='pgrep --color'

if which python3 >/dev/null 2>&1; then
  alias venv='python3 -m venv '
else
  alias venv='echo "Install Python 3!" >&2; echo "" >/dev/null'
fi

alias R='sudo /bin/zsh -c "source ${HOME}/z" '

alias pt='ps -H'

alias vi="$(which vim) -u ~/.vimrc "
alias view="vi -R "

# Use MD to colorize diff output.
alias MD='mark -Idiff'

# Set up a couple of docker aliases.
which docker-machine >/dev/null 2>&1 && alias dm=$(which docker-machine)
if which docker >/dev/null 2>&1; then
  alias dc='docker container'
  alias di='docker image'
fi

# Usage: list_functions [-a]
# List all shell functions. Under zsh, "internal" functions (those starting
# with _) are hidden by default. Use -a or --all to show them. Under bash, all
# functions are shown regardless of command line options.
list_functions() {
  # Handle the command line.
  local INTERNAL='^_'
  while [ $# -gt 0 ]; do
    case "$1" in
      -a)
        INTERNAL='ZS9Jp99Xc3fEq5'
        shift
        ;;
      *)
        echo "list_functions: Bad argument: \"$1\"" >&2
        return 1
    esac
  done
  # This works differently for each  shell.
  case $(realpath "$SHELL") in
    *bash)
      declare -f
      ;;
    *zsh)
      for f in $(print -l ${(ok)functions} | grep -v "$INTERNAL"); do
        echo
        which $f
      done
      ;;
    *)
      echo "Can't get \"all functions\" for shell $SHELL." >&2
      return 1
  esac
  return 0
}
export -f list_functions >/dev/null

# Usage: ML [RE]
# The optional regular expression limits output to matching lines.
function ML {
  local OPT=''
  [ $# -gt 0 ] && OPT="--keep $1"
  mark -i --palette 'red on black,green,yellow,cyan,magenta' $(echo $OPT) '(\bFATAL:.*)|(\bE(RROR)?:.*)|(.*\bRED\b.* )' '(\bL(OG)?:.*)|(\bI(NFO)?:.*)|(.*\bGREEN\b.*)' '(\bW(ARN(ING)?)?:.*)|(.*\bYELLOW\b.*)' '\bD(EBUG|ETAIL)?:.*' '\bN(OTICE)?:.*'
}
export -f ML >/dev/null

function words {
  egrep -i "^$1$" /usr/share/dict/words
}

# Usage: svn-modified [args to "svn status"]
# This just runs "svn status $@" and filters the output with "grep -v '^\?'".
function svn-status {
  svn status $@ | grep -v '^\?'
}
export -f svn-status >/dev/null

# Point EDITOR at vim, or failing that, vi.
export EDITOR=$(which vim)
[ -z "$EDITOR" -o ! -f "$EDITOR" ] && export EDITOR=$(which vi)

# Point PAGER at less, or failing that, more.
unset PAGER
[ -f /usr/bin/less ] && export PAGER="/usr/bin/less -R"
[ -z "$PAGER" -a -f /usr/bin/more ] && export PAGER=/usr/bin/more

# Run our epilog, if available.
fn="$HOME/.rc-epilog"
if [ -f "$fn" ]; then
  debug "Sourcing $fn"
  source "$fn"
  debug "Finished $fn"
fi
unset fn # So we don't polute our new shell.
