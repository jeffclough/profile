# Run our prolog, if available.
[ -f ~/.env-prolog ] && source ~/.env-prolog

# In support of platform dependence ...
osname=$(uname -s)
if [[ "$osname" == "Darwin" ]]; then
  # This is a Mac OS X machine.
  oskernel=$(uname -r|cut -d. -f-2)
  architecture=$(uname -m)
  osrelease=$(defaults read loginwindow SystemVersionStampAsString|cut -d. -f-2)
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
# might be portable.
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

# Point EDITOR at vim, or failing that, vi.
unalias vi vim 2>/dev/null
unset EDITOR
which vim >/dev/null 2>&1 && export EDITOR=$(which vim)
[ -z "$EDITOR" ] && which vi >/dev/null 2>&1 && export EDITOR=$(which vi)

# Point PAGER at less, or failing that, more.
unset PAGER
which less >/dev/null 2>&1 && export PAGER=$(which less)
[ -z "$PAGER" ] && which more >/dev/null 2>&1 && export PAGER=$(which more)

# Make sure rsync uses ssh for communication with other hosts.
unset RSYNC_RSH
if which ssh >/dev/null ; then
  export RSYNC_RSH=`which ssh`
fi

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
# Prepend $app_path/(bin|sbin) to PATH.
# Prepend $app_path/lib to LD_LIBRARY_PATH.
# Prepend $app_path/(man|share/man) to MANPATH.
prepend_paths() {
  dir="$1"
  dir="${dir//\/\///}"
  PATH=$(prepend_path "$dir/bin")
  PATH=$(prepend_path "$dir/sbin")
  export PATH
  LD_LIBRARY_PATH=$(prepend_path "$dir/lib" "$LD_LIBRARY_PATH")
  export LD_LIBRARY_PATH
  MANPATH=$(prepend_path "$dir/man" "$MANPATH")
  MANPATH=$(prepend_path "$dir/share/man" "$MANPATH")
  export MANPATH
}
    
# Prepend bin, sbin, lib, and man subdirectories (if they exist) of the
# following paths to the appropriate environment variables' values.
for p in / /usr /opt/local /sw /usr/local /usr/local/mysql /opt/subversion /usr/local/git "$HOME/my" "$HOME/test"
do
  prepend_paths "$p"
done
export PYTHONPATH=`prepend_path "$HOME/my/lib/python" "$PYTHONPATH"`

# Run our epilog, if available.
[ -f ~/.env-epilog ] && source ~/.env-epilog
