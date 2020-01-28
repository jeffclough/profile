# Make sure we're "home," even if we got here via sudo.
export HOME="$(cd ~jclough;pwd)"
cd

# Run our prolog, if available.
fn="$HOME/.profile-prolog"
if [ -f "$fn" ]; then
  debug "Sourcing $fn"
  source "$fn"
  debug "Finished $fn"
fi

# I know this is wrong. It is also necessary.
source "$HOME/.zshenv"
source "$HOME/.zshrc"

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
fn="$HOME/.profile-epilog"
if [ -f "$fn" ]; then
  debug "Sourcing $fn"
  source "$fn"
  debug "Finished $fn"
fi
