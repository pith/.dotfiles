# Cygwin-only stuff
is_cygwin || return 1

packages=( 
    tmux 
    weechat 
)

e_header "Installing packages: ${packages[*]}"
for package in "${packages[@]}"; do
    pact install $package
done
