# Herdr configuration
# Live tab renaming from herdr-automatic-rename: herdr has no "foreground command
# changed" event, so this shell hook renames the tab as each command starts.
# The hook no-ops outside herdr panes; the glob finds herdr's hashed install dir.

[[ -n "${HERDR_PANE_ID:-}" ]] || return

for _har_hook in "$HOME"/.config/herdr/plugins/github-installations/herdr-automatic-rename-*/*/checkout/shell/hook.zsh(N); do
  source "$_har_hook"
  break
done
unset _har_hook
