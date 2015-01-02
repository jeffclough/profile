export EDITOR=vi
export TERM=xterm-color
if which less >/dev/null ; then
  export PAGER=`which less`
fi
if which ssh >/dev/null ; then
  export RSYNC_RSH=`which ssh`
fi

# Add default identities to ssh agent if needed.
(ssh-add -l | grep 'The agent has no identities.' >/dev/null) && ssh-add

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
    
# Prepend bin, sbin, lib, and man subdirectories (if they exist) of the
# following paths to the appropriate environment variables' values.
for p in / /usr /opt/local /sw /usr/local /usr/local/mysql /opt/subversion /usr/local/git "$HOME/my" "$HOME/test"
do
  export PATH=`prepend_path "$p/bin"`
  export PATH=`prepend_path "$p/sbin"`
  export LD_LIBRARY_PATH=`prepend_path "$p/lib" "$LD_LIBRARY_PATH"`
  export MANPATH=`prepend_path "$p/man" "$MANPATH"`
  export MANPATH=`prepend_path "$p/share/man" "$MANPATH"`
done
export PYTHONPATH=`prepend_path "$HOME/my/lib/python" "$PYTHONPATH"`
export LD_LIBRARY_PATH=`prepend_path "$HOME/my/lib/ImageMagick-6.6.3" "$LD_LIBRARY_PATH"`
export MAGICK_HOME="$HOME/my"
export PATH=`prepend_path "/android-sdk-mac_x86/tools"`

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


# Setting PATH for Python 3.4
# The orginal version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.4/bin:${PATH}"
export PATH
