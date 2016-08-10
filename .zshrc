# BEFORE sourcing any .rc-prolog code for this interactive session,
# enable iTerm's shell integration.
#fn="$(dirname "$(realpath "$HOME/.zshrc")")/.iterm2_shell_integration.zsh"
fn="$HOME/.iterm2_shell_integration.zsh"
debug "fn=$fn"
if [ -f "$fn" ]; then
  debug "Sourcing $fn"
  source "$fn"
  debug "Finished $fn"
fi
[ -n "${functions[iterm2_set_user_var]}" ] && export iTermShellIntegration=YES

# Run our prolog, if available.
fn="$HOME/.rc-prolog"
if [ -f "$fn" ]; then
  debug "Sourcing $fn"
  source "$fn"
  debug "Finished $fn"
fi

# Some general ZShell settings.
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
export CLICOLOR=1
# Good ls colors for dark terminal backgrounds:
export LSCOLORS=gxfxcxdxbxegbdabafacge
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=31;43:su=30;41:sg=30;45:tw=30;42:ow=36;44'
# Good ls colors for light terminal backgrounds:
#export LSCOLORS=exfxcxdxbxeghdhbafhcge
#export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=37;43:su=37;41:sg=30;45:tw=37;42:ow=36;44'
setopt appendhistory
bindkey -v
if [[ "$osname" != "SunOS" ]] then
  autoload -Uz compinit
  compinit
fi

# Set the title of the emulator window.
windowtitle() {
  [[ -t 1 ]] || return
  case $TERM in
  sun-cmd) print -Pn "\e]l$1\e\\"
    ;;
  vt220|*xterm*|ansi|rxvt|(dt|k|E)term) print -Pn "\e]2;$1\a"
    ;;
  esac
}

# Set the title of the emulator tab.
tabtitle() {
  [[ -t 1 ]] || return
  case $TERM in
  vt220|*xterm*|ansi|rxvt|(dt|k|E)term) print -Pn "\e]1;$1\a"
    ;;
  esac
}

# Get the name of the current host and cook it a bit.
get_host_name() {
  /bin/hostname | sed -e 's/\.gatech\.edu$//' -e 's/.*\.bluehost\.com$/bluehost.com/' -e 's/\.local$//' -e 's/^ipsec-.*/GTmactop/' -e 's/^lawn-.*/GTmactop/' -e 's/192\.168\..*/mactop/'
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
    if [[ $(( t - real_ip_time )) -gt 10 ]] then
      real_ip=$(curl -s ipchicken.com | pygrep -f '{}' '(^\d+\.\d+\.\d+\.\d+)')
      real_ip_time=$t
    fi
  fi
  echo $real_ip
}

# Before each prompt, show the host name in the terminal window's title bar.
precmd() {
  mname=$(get_host_name)
  #ip=$(get_real_ip)
  my_network=$(get_network_name)
  windowtitle "%n@$mname"
  tabtitle "$mname"
  [ -n "$iTermShellIntegration" ] && iterm2_set_user_var badge "$(echo -e "$USERNAME\n$mname\n$my_network")"
}

# Set our prompt according to our effective uid.
setopt PROMPT_SUBST
mname=$(get_host_name)
if [[ `uname -s` = "AIX" ]]; then
  PS1="%d%# "
else
  # Root gets a yellow prompt. Others get a green one.
  PS1=$'%{\e[0;%(#.33.32)m%}$mname:%~%#%{\e[0m%} '
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
alias lla='ll -a'
alias lld='ll -d'
alias lrt='ll -rt'
alias lrtail='lrt|tail '

alias vi="$(which vim) "
alias view="$(which vim) -R "

# Use MD to colorize diff output.
alias MD='mark -Idiff'

# Usage: ML [RE]
# The optional regular expression limits output to matching lines.
function ML {
  local OPT=''
  [ $# -gt 0 ] && OPT="--keep $1"
  mark $(echo $OPT) '(FATAL:.*)|(E(RROR)?:.*)|(.*\bRED\b.* )' '(I(NFO)?:.*)|(.*\bGREEN\b.*)' '(W(ARN(ING)?)?:.*)|(.*\bYELLOW\b.*)' 'D(EBUG)?:.*' 'N(OTICE)?:.*'
}
export -f ML >/dev/null

# Usage: svn-modified [args to "svn status"]
# This just runs "svn status $@" and filters the output with "grep -v '^\?'".
function svn-status {
  svn status $@ | grep -v '^\?'
}
export -f svn-status >/dev/null

# Point EDITOR at vim, or failing that, vi.
export EDITOR=$(which vim)
[ -z "$EDITOR" -o ! -f ] && export EDITOR=$(which vi)

# Point PAGER at less, or failing that, more.
unset PAGER
[ -f /usr/bin/less ] && export PAGER=/usr/bin/less
[ -z "$PAGER" -a -f /usr/bin/more ] && export PAGER=/usr/bin/more

# Run our epilog, if available.
fn="$HOME/.rc-epilog"
if [ -f "$fn" ]; then
  debug "Sourcing $fn"
  source "$fn"
  debug "Finished $fn"
fi
