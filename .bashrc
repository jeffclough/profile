# If, under duress, I find myslef running Bash, this make it more tollerable.

export PS1='\[\e[1;31m\]\u@\h \[\e[0;36m\]\w\[\e[1m\]\$ \[\e[0m\]'
set -o vi
alias ls='ls -F --color=auto'
alias la='ls -a'
alias less='less -R '
alias ll='ls -l'
alias lla='ll -a'
alias lld='ll -d'
alias lrt='ll -rt'
alias lrtail='lrt|tail '
alias run-help=man
alias vi='/usr/bin/vim '
alias view='/usr/bin/vim -R '

[ -f /srv/setenv ] && . /srv/setenv
