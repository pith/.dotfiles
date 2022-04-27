#!/usr/bin/env zsh

# Logging stuff.
function e_header()   { echo -e "\n\033[1m$@\033[0m"; }
function e_success()  { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()    { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()    { echo -e " \033[1;34m➜\033[0m  $@"; }

# Given strings containing space-delimited words A and B, "setdiff A B" will
# return all words in A that do not exist in B. Arrays in bash are insane
# (and not in a good way).
# From http://stackoverflow.com/a/1617303/142339
function setdiff() {
    local debug skip a b
    if [[ "$1" == 1 ]]; then debug=1; shift; fi
    if [[ "$1" ]]; then
        local setdiff_new setdiff_cur setdiff_out
        setdiff_new=($1); setdiff_cur=($2)
    fi
    setdiff_out=()
    for a in "${setdiff_new[@]}"; do
        skip=
        for b in "${setdiff_cur[@]}"; do
            [[ "$a" == "$b" ]] && skip=1 && break
        done
        [[ "$skip" ]] || setdiff_out=("${setdiff_out[@]}" "$a")
    done
    [[ "$debug" ]] && for a in setdiff_new setdiff_cur setdiff_out; do
        echo "$a ($(eval echo "\${#$a[*]}")) $(eval echo "\${$a[*]}")" 1>&2
    done
    [[ "$1" ]] && echo "${setdiff_out[@]}"
}

# Tap Homebrew kegs.
function brew_tap_kegs() {
    kegs=($(setdiff "${kegs[*]}" "$(brew tap)"))
    if (( ${#kegs[@]} > 0 )); then
        e_header "Tapping Homebrew kegs: ${kegs[*]}"
        for keg in "${kegs[@]}"; do
            brew tap $keg
        done
    fi
}

# Install Homebrew recipes.
function brew_install_recipes() {
    recipes=($(setdiff "${recipes[*]}" "$(brew list)"))
    if (( ${#recipes[@]} > 0 )); then
        e_header "Installing Homebrew recipes: ${recipes[*]}"
        for recipe in "${recipes[@]}"; do
            brew install $recipe
        done
    fi
}

# Ensure the cask kegs are installed.
kegs=(
    homebrew/cask-fonts
)
brew_tap_kegs

# Homebrew casks
casks=(
    # Fonts
    font-sauce-code-pro-nerd-font
)

# Install Homebrew casks.
casks=($(setdiff "${casks[*]}" "$(brew cask list 2>/dev/null)"))
if (( ${#casks[@]} > 0 )); then
    e_header "Installing Homebrew casks: ${casks[*]}"
    for cask in "${casks[@]}"; do
        brew install --cask $cask
    done
fi

# Homebrew recipes
recipes=(
    starship
)

brew_install_recipes
