#!/usr/bin/env bash
set -euo pipefail

# Run from one Nano4 login node. This clears stale IDE/AI agents on all login nodes.
# WARNING: it terminates matching processes owned by the current user on every host.
for host in 25a-lgn01 25a-lgn02 25a-lgn03 25a-lgn04 25a-lgn05; do
    echo "=== ${host} ==="
    if ! ssh -o ConnectTimeout=10 "${host}" 'bash "$HOME/Nano4-Docs/02-vscode-and-ai-tools/scripts/kill.sh" --yes'; then
        echo "WARNING: unable to reach ${host}; continue." >&2
    fi
done
