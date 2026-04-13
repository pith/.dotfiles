#!/bin/zsh

# setup.sh - Deprecated wrapper kept for backward compatibility.
# Use bootstrap.sh for new machine setup, sync.sh to stay in sync with remote.

echo "[WARN] setup.sh is deprecated. Use ./bootstrap.sh instead." >&2
exec "$(dirname "$0")/bootstrap.sh" "$@"
