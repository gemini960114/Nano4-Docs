#!/usr/bin/env bash
# ==============================================================================
# install_my_skill.sh - 把自己做的 skill 複製給三個 AI Agent
#   來源：~/.agents/skills/<名稱>/          Codex 讀取（AI 把 skill 寫在這裡）
#   複製：~/.claude/skills/<名稱>/          Claude Code 讀取
#         ~/.gemini/config/skills/<名稱>/   Antigravity 讀取
# 用法：bash install_my_skill.sh [名稱，預設 my-nano4-slurm]
# ==============================================================================
set -euo pipefail

NAME="${1:-my-nano4-slurm}"
SRC="${HOME}/.agents/skills/${NAME}"

if [ ! -f "${SRC}/SKILL.md" ]; then
    echo "❌ 找不到 ${SRC}/SKILL.md，請先請 AI 把 skill 存到 ${SRC}/" >&2
    exit 1
fi

for DEST in "${HOME}/.claude/skills" "${HOME}/.gemini/config/skills"; do
    mkdir -p "${DEST}"
    rm -rf "${DEST:?}/${NAME}"
    cp -r "${SRC}" "${DEST}/${NAME}"
    echo "✅ ${DEST}/${NAME}"
done

echo "👉 三個 Agent 都要開一個新對話，才會讀到更新後的 skill。"
