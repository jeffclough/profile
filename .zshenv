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
colorDebug="1;$bg_black;$fg_blue"
colorInfo="1;$bg_black;$fg_green"
colorNotice="$bg_black;$fg_cyan"
colorWarning="$bg_black;$fg_yellow"
colorError="$bg_black;$fg_red"

debug() {
  [ -n "$SCRIPT_DEBUG" ] && echo -e "\e[${colorDebug}mD: $@\e[${colorNorm}m"
}
export -f debug >/dev/null

info() {
  [ -n "$SCRIPT_INFO" ] && echo -e "\e[${colorInfo}mI: $@\e[${colorNorm}m"
}
export -f info >/dev/null

notice() {
  [ -n "$SCRIPT_NOTICE" ] && echo -e "\e[${colorNotice}mN: $@\e[${colorNorm}m"
}
export -f notice >/dev/null

warning() {
  [ -n "$SCRIPT_WARNING" ] && echo -e "\e[${colorWarning}mW: $@\e[${colorNorm}m"
}
export -f warning >/dev/null

error() {
  [ -n "$SCRIPT_ERRORS" ] && echo -e "\e[${colorError}mE: $@\e[${colorNorm}m"
}
export -f error >/dev/null

#SCRIPT_DEBUG='yes'
SCRIPT_INFO='yes'
SCRIPT_NOTICE='yes'
SCRIPT_WARNING='yes'
SCRIPT_ERRORS='yes'

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

# usage: realpath PATH
# Returns the absolute, canonical, no-symlinks path to PATH.
realpath() {
  python <<EOF
import os.path
print os.path.realpath("$1")
EOF
}
export -f realpath >/dev/null

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
  x=/etc/redhat-release
  if [[ "$osname" == "Linux" && -f "$x" ]]; then
    # It must be Red Hat.
    unset y
    grep -q 'Red Hat Enterprise Linux' $x && y='rhel'
    osrelease="$y$(grep -Po '(?<=release )\d+' $x)"
    # Keep Redhat's sadistically crafted /etc/zlogout from running.
    setopt noglobalrcs
  fi
fi

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
export ARCHOS # Things like "make" will need access to this variable.
for branch in bin sbin lib man share share/man; do
  d="$ARCHOS/$branch"
  if [ ! -d "$d" ]; then
    mkdir "$d"
    chmod 755 "$d"
  fi
done

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

  PYTHONPATH=$(prepend_path "$dir/lib" "$PYTHONPATH")
  PYTHONPATH=$(prepend_path "$dir/lib/python" "$PYTHONPATH")
  export PYTHONPATH

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

# Run our epilog, if available.
fn="$HOME/.env-epilog"
if [ -f "$fn" ]; then
  debug "Sourcing $fn"
  source "$fn"
  debug "Finished $fn"
fi
