#!/bin/bash
# ==============================================================================
# sync_skills.sh: 一鍵同步 Nano4 HPC Skills 到使用者的 ~/.agents/skills 目錄
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.agents/skills"

echo "================================================================================"
echo "🚀 正在同步 Nano4 AI Agent 專屬技能至：$TARGET_DIR"
echo "================================================================================"

mkdir -p "$TARGET_DIR"

for skill in slurm-job-advisor ai-agent-slurm-pipeline nano4-slurm-operations; do
    if [ -d "$SCRIPT_DIR/$skill" ]; then
        echo "📦 同步技能: $skill ..."
        cp -ru "$SCRIPT_DIR/$skill" "$TARGET_DIR/"
    fi
done

echo ""
echo "✅ 同步完成！目前已啟用的技能清單："
ls -d "${TARGET_DIR}"/*/ | xargs -n 1 basename
echo "================================================================================"
