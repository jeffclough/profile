# Run our prolog, if available.
[ -f ~/.profile-prolog ] && source ~/.profile-prolog

export EDITOR=vi
export TERM=xterm-color
if which less >/dev/null ; then
  export PAGER=`which less`
fi
if which ssh >/dev/null ; then
  export RSYNC_RSH=`which ssh`
fi

# Add default identities to ssh agent if needed.
EM=$(ssh-add -l 2>&1); E=$?
if [ $E -eq 0 ]; then
  (echo "$EM" | grep -q 'The agent has no identities.') && ssh-add
fi

#source /sw/bin/init.sh

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

# pip zsh completion start
function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip
# pip zsh completion end

# Run our epilog, if available.
[ -f ~/.profile-epilog ] && source ~/.profile-epilog
