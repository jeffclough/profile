# BEFORE sourcing any .rc-prolog code for this interactive session,
# enable iTerm's shell integration.
fn="$(dirname "$(realpath "$HOME/.zshrc")")/.iterm2_shell_integration.zsh"
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
export LSCOLORS=GxFxCxDxBxegedabagaced
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

# Before each prompt, show the host name in the terminal window's title bar.
if [[ "$osname" == "SunOS" ]] then
  precmd() {
    mname=$(/bin/hostname | sed -e 's/.gatech\.edu//' -e 's/^lawn-.*/GTmactop/')
    windowtitle "%n@$mname"
    [ -n "$iTermShellIntegration" ] && iterm2_set_user_var badge "$(echo -e "$USERNAME\n$mname")"
  }
elif [[ "$osname" == "Darwin" ]] then
  precmd() {
    mname=`print -Pn %M|sed -Ee 's/\.gatech\.edu$//' -e 's/\.local$//' -e 's/^(ipsec|lawn)-.*/GTmactop/' -e 's/192\.168\..*/mactop/'`
    windowtitle "%n@$mname"
    [ -n "$iTermShellIntegration" ] && iterm2_set_user_var badge "$(echo -e "$USERNAME\n$mname")"
  }
else # Assume a tolerably modern Linux of some kind.
  precmd() {
    mname=`print -Pn %M|sed -re 's/\.gatech\.edu$//' -e 's/\.local$//' -e 's/^(ipsec|lawn)-.*/GTmactop/' -e 's/192\.168\..*/mactop/'`
    windowtitle "%n@$mname"
    [ -n "$iTermShellIntegration" ] && iterm2_set_user_var badge "$(echo -e "$USERNAME\n$mname")"
  }
fi

# Set our prompt according to our effective uid.
setopt PROMPT_SUBST
mname=`print -Pn %m|sed -e 's/^lawn-.*/GTmactop/' -e 's/192\.168\..*/mactop/'`
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

alias ls='ls -F'
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
  mark $(echo $OPT) '(E(RROR)?:.*)|(.*\bRED\b.* )' '(I(NFO)?:.*)|(.*\bGREEN\b.*)' '(W(ARN(ING)?)?:.*)|(.*\bYELLOW\b.*)' 'D(EBUG)?:.*' 'N(OTICE)?:.*'
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
