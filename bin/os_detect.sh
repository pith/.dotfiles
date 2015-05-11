# OS detection
function is_osx() {
  [[ "$OSTYPE" =~ ^darwin ]] || return 1
}

function is_cygwin() {
  [[ "$(uname -a)" =~ ^Cygwin ]] || return 1
}

function get_os() {
  for os in osx cygwin; do
    is_$os; [[ $? == ${1:-0} ]] && echo $os
  done
}
