# usage: realpath PATH
# Returns the absolute, canonical, no-symlinks path to PATH.
realpath() {
  python2 <<EOF
import os.path
print(os.path.realpath("$@"))
EOF
}
export -f realpath >/dev/null

# If bash (<shudder/>) is sourcing this script, remember that and play nice.
#echo "D: .zshenv: \$0='$0'"
#echo "D: .zshenv: \$SHELL='$SHELL' (before)"
# Resolve any sym-linking nonsense that might be going on with our shell.
SHELL=$(realpath "$SHELL")
if [[ "${0##*/}" == "bash" ]]; then
  SHELL=$(which bash)
fi
export SHELL
#echo "D: .zshenv: \$SHELL='$SHELL' (after)"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
# Set up basic output functions here so that they're available EVERYWHERE.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
fg_black=30
fg_red=31
fg_green=32
fg_yellow=33
fg_blue=34
fg_magenta=35
fg_cyan=36
fg_white=37
bg_black=40
bg_red=41
bg_green=42
bg_yellow=43
bg_blue=44
bg_magenta=45
bg_cyan=46
bg_white=47

colorNorm="0"
colorDebug="$bg_blue;$fb_white"
colorInfo="1;$bg_black;$fg_green"
colorNotice="1;$bg_black;$fg_cyan"
colorWarning="1;$bg_black;$fg_yellow"
colorError="1;$bg_black;$fg_red"

# Usage: echo_tc ANSI_COLOR_NUMBER text ...
#
# The text will be prefixed with a timestamp and colored according to the first
# argument's ANSI value formatted as "[[attr;]background;]foreground". The text
# will only be colored if standard output is going to a terminal.

echo_tc() {
  local c="$1";shift
  if [ -t 1 ]; then
    echo -e "\e[${c}m$(date) $@\e[${colorNorm}m"
  else
    echo -e "$(date) $@"
  fi
}
export -f echo_tc >/dev/null

debug() {
  [ -n "$SCRIPT_DEBUG" ] && echo_tc "$colorDebug" D: $@
}
export -f debug >/dev/null

info() {
  [ -n "$SCRIPT_INFO" ] && echo_tc "$colorInfo" I: $@
}
export -f info >/dev/null

notice() {
  [ -n "$SCRIPT_NOTICE" ] && echo_tc "$colorNotice" N: $@
}
export -f notice >/dev/null

warning() {
  [ -n "$SCRIPT_WARNING" ] && echo_tc "${colorWarning}" W: $@
}
export -f warning >/dev/null

error() {
  [ -n "$SCRIPT_ERROR" ] && echo_tc "${colorError}" E: $@
}
export -f error >/dev/null

#SCRIPT_DEBUG='yes'
SCRIPT_INFO='yes'
SCRIPT_NOTICE='yes'
SCRIPT_WARNING='yes'
SCRIPT_ERROR='yes'

# If we're on a system where there's no python2, try just using python.
which python2 >/dev/null 2>&1 || alias python2='python '

# Usage:
#   date [OPTION]... [+FORMAT]
#   date [-u|--utc|--universal] [MMDDhhmm[[CC]YY][.ss]]
#
# This is just like the "standard" date command, but the default format is:
#   %Y-%m-%d %H:%M:%S
#
date() {
  /bin/date "${@:-+%Y-%m-%d %H:%M:%S}"
}
export -f date >/dev/null

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Here begins the real profile work.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Run our prolog, if available.
fn="$HOME/.env-prolog"
if [ -f "$fn" ]; then
  debug "Sourcing $fn"
  source "$fn"
  debug "Finished $fn"
fi

# In support of platform dependence ...
osname=$(uname -s)
if [[ "$osname" == "Darwin" ]]; then
  # This is a Mac OS X machine.
  oskernel=$(uname -r|cut -d. -f-2)
  architecture=$(uname -m)
  osrelease=$(sw_vers -productVersion|cut -d. -f-2)
else 
  # Treat this is (more or less) straight Unix (whatever that is).
  oskernel=$(uname -r|cut -d. -f-2)
  architecture=$(uname -p)
  if [[ "$architecture" == "unknown" ]]; then
    # Under Raspian, -p reports "unknown", but -m works.
    architecture=$(uname -m)
  fi
  osrelease=''
  if [[ "$osname" == "Linux" ]]; then
    unset y
    # Check for Red Hat.
    for x in /etc/redhat-release /etc/os-release; do
      if [[ -f "$x" ]]; then
        if grep -q 'Red Hat Enterprise Linux' $x; then
          y='rhel'
          osrelease="$y$(grep -Po '(?<=release )\d+' $x)"
          # Keep Redhat's sadistically crafted /etc/zlogout from running.
          #[[ "$(realpath "$SHELL")" =~ "zsh$" ]] && setopt noglobalrcs
          #(realpath "$SHELL" | grep -q "zsh$") && setopt noglobalrcs
          [[ "${SHELL##*/}" == "zsh" ]] && setopt noglobalrcs
        elif grep -q 'Amazon Linux AMI' $x; then
          osrelease="$(grep -Po '(?<=^ID=")[a-z]+' $x)$(grep -Po '(?<=^VERSION_ID=")\d+\.\d+' $x)"
          # AMI inherited RHEL's evil /etc/zlogout.
          #(realpath "$SHELL" | grep -q "zsh$") && setopt noglobalrcs
          [[ "${SHELL##*/}" == "zsh" ]] && setopt noglobalrcs
        fi
      fi
    done
  fi
fi

archos() {
  # Get our command line options.
  O=`getopt -o hnrka -- "$@"`
  if [ $? != 0 ]; then return 1; fi
  eval set -- "$O"

  # Process any options found.
  if [ $# -gt 1 ]; then
    local -a output
    while [[ ${1:0:1} == - ]]; do
      [[ $1 == -- ]] && {shift;break};
      [[ $1 == -h ]] && {
        cat <<EOF
usage: archos [OPTOINS]

OPTIONS:
    -h  This message.
    -n  Write the OS name.
    -r  Write the OS release.
    -k  Write the kernel version.
    -a  Write the CPU architecture.
EOF
        return 0
      };
      [[ $1 == -n ]] && {output+="$osname";shift;continue};
      [[ $1 == -r ]] && {output+="$osrelease";shift;continue};
      [[ $1 == -k ]] && {output+="$oskernel";shift;continue};
      [[ $1 == -a ]] && {output+="$architecture";shift;continue};
      output+="$1"
      shift
    done
    echo $output
  else
    # If there were no options given, output everything.
    echo "$osname $osrelease $oskernel $architecture"
  fi
}

# Make a place for architecture/OS dependent files, because home directories
# might be shared among machines with architectural differences.
ARCHOS="$HOME"
rt_env_type="${osname}${oskernel:+_$oskernel}${architecture:+_$architecture}"
for part in my archos "$rt_env_type"; do
  ARCHOS="$ARCHOS/$part"
  if [ ! -d "$ARCHOS" ]; then
    mkdir "$ARCHOS"
    chmod 755 "$ARCHOS"
  fi
done
export ARCHOS
for branch in bin sbin lib man share share/man; do
  d="$ARCHOS/$branch"
  if [ ! -d "$d" ]; then
    mkdir "$d"
    chmod 755 "$d"
  fi
done
# $ARCHOS is now where this platform's binaries should go. So things like
#     ./configure --prefix "$ARCHOS"
# ought to be the norm when preparing to build binaries.

# Make sure rsync uses ssh for communication with other hosts.
unset RSYNC_RSH
[ -f /usr/bin/ssh ] && export RSYNC_RSH=/usr/bin/ssh

# prepend_path(path[,pathlist])
# Prepend path (if it is a directory) to pathlist. If pathlist is not given,
# the value of the PATH environment variable is used. If path already exists in
# pathlist, it is removed from the list before being prepended to it. The
# result is returned.
prepend_path() {
  # Get our parameters.
  dir="$1"
  dir="${dir//\/\///}"
  if [[ $# -gt 1 ]]; then
    path="$2" 
  else
    path="$PATH"
  fi

  # Prepend dir to path, remove it elsewhere, and return the result.
  if [[ -d "$dir" ]]; then
    path=":$path:"
    path="${path//:${dir}:/:}"
    path="${path#:}"
    path="${path%:}"
    path="$dir:$path"
  fi
  echo "$path" 
}   

# prepend_paths(app_path)
#   Prepend $app_path/(bin|sbin) to PATH.
#   Prepend $app_path/lib to LD_LIBRARY_PATH.
#   Prepend $app_path/(lib/python|lib) to PYTHONPATH.
#   Prepend $app_path/(man|share/man) to MANPATH.
prepend_paths() {
  dir="$1"
  dir="${dir//\/\///}"

  PATH=$(prepend_path "$dir/bin")
  PATH=$(prepend_path "$dir/sbin")
  export PATH

  LD_LIBRARY_PATH=$(prepend_path "$dir/lib" "$LD_LIBRARY_PATH")
  export LD_LIBRARY_PATH

  #PYTHONPATH=$(prepend_path "$dir/lib" "$PYTHONPATH")
  #PYTHONPATH=$(prepend_path "$dir/lib/python" "$PYTHONPATH")
  #export PYTHONPATH

  MANPATH=$(prepend_path "$dir/man" "$MANPATH")
  MANPATH=$(prepend_path "$dir/share/man" "$MANPATH")
  export MANPATH
}

if [ -x "$HOME/go" ]; then
  export GOPATH="$HOME/go"
fi
    
# Prepend bin, sbin, lib, and man subdirectories (if they exist) of the
# following paths to the appropriate environment variables' values.
for p in / /usr /opt/local /sw /usr/local /usr/local/go /usr/local/mysql /opt/subversion /usr/local/git "$GOPATH" /usr/local/jeff "$HOME/my" "$HOME/test"
do
  prepend_paths "$p"
done
PYTHONPATH=$(prepend_path "$HOME/my/lib/python" "$PYTHONPATH")
PYTHONPATH=$(prepend_path "$HOME/my/lib/python2" "$PYTHONPATH")
export PYTHONPATH

# We set up our python2 alias very early in this script because it might be
# needed that early, but we revisit that here (after setting up our PATH) in
# case things have changed.
unalias python2 2>/dev/null
which python2 >/dev/null 2>&1 || alias python2='python '

# Run our epilog, if available.
fn="$HOME/.env-epilog"
if [ -f "$fn" ]; then
  debug "Sourcing $fn"
  source "$fn"
  debug "Finished $fn"
fi

#echo "D: .zshenv: \$SHELL='$SHELL' (at end)"
