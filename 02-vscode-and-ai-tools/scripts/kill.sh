#!/usr/bin/env bash
set -euo pipefail

# WARNING: this terminates all matching AI/VS Code agent processes owned by the
# current user on the current login node. Do not run while an active session is needed.
USER_NAME="$(whoami)"
PATTERN='codex|claude|gemini|chatgpt|antigravity|agy|code-server|vscode-server|\.vscode-server'
AUTO_YES=false

if [[ "${1:-}" == "-y" || "${1:-}" == "--yes" ]]; then
    AUTO_YES=true
fi

echo "User: ${USER_NAME}"
echo "Host: $(hostname)"
echo "Matched processes:"
echo "----------------------------------------"
pgrep -u "${USER_NAME}" -af "${PATTERN}" || true
echo "----------------------------------------"

if ${AUTO_YES}; then
    answer="y"
else
    read -r -p "Kill all matched processes owned by ${USER_NAME} on $(hostname)? [y/N] " answer
fi

case "${answer}" in
    y|Y|yes|YES)
        pkill -9 -u "${USER_NAME}" -f "${PATTERN}" || true
        echo "Done. Reconnect the IDE and create a fresh session."
        ;;
    *)
        echo "Cancelled."
        ;;
esac
