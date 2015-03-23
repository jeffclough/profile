# Run our prolog, if available.
[ -f ~/.profile-prolog ] && source ~/.profile-prolog

# pip zsh completion start. (This corrects a bug in the default implementation.)
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
