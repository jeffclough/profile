# Some general ZShell settings.
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
setopt appendhistory
bindkey -v
autoload -Uz compinit
compinit

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
precmd() {
  mname=`print -Pn %m|sed -e 's/^lawn-.*/GTmactop/' -e 's/192\.168\..*/mactop/'`
  windowtitle "%n@$mname"
}

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

alias MD='mark -Idiff'

