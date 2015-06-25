# Copy fonts
export DOTFILES=~/.dotfiles
{
  pushd $DOTFILES/vendor/fonts/; setdiffA=(*); popd
  pushd /cygdrive/c/Windows/Fonts; setdiffB=(*); popd
  setdiff
} >/dev/null

if (( ${#setdiffC[@]} > 0 )); then
  e_header "Copying fonts (${#setdiffC[@]})"
  for f in "${setdiffC[@]}"; do
    e_arrow "$f"
    cp "$DOTFILES/vendor/fonts/$f" /cygdrive/c/Windows/Fonts
  done
fi

$DOTFILES/bin/FontReg.exe
