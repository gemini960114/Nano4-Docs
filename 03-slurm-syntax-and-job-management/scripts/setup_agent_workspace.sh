#!/usr/bin/env bash
# ==============================================================================
# setup_agent_workspace.sh - 建立第二堂的 AI Agent 工作資料夾
#   /work/$USER/slurm_lab/
#   ├── AGENTS.md              Nano4 規則（Codex 讀取）
#   ├── CLAUDE.md              內容只有 @AGENTS.md（Claude Code 讀取）
#   ├── .agents/rules/nano4.md 引用 AGENTS.md（Antigravity 讀取）
#   └── fastq_raw/             教材附的 4 個 FASTQ 樣本
# 在教材 repository 以外的資料夾練習，AI 不會事先看到課程提供的 Skills，
# 做出來的 skill 才是自己的經驗；第三堂再和官方 Skills 比較。
# 用法：bash setup_agent_workspace.sh [資料夾，預設 /work/$USER/slurm_lab]
# ==============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LAB="${1:-/work/${USER}/slurm_lab}"

mkdir -p "${LAB}/fastq_raw" "${LAB}/.agents/rules"
[ -e "${LAB}/AGENTS.md" ] || cp "${REPO}/AGENTS.md" "${LAB}/AGENTS.md"
[ -e "${LAB}/CLAUDE.md" ] || echo "@AGENTS.md" > "${LAB}/CLAUDE.md"
[ -e "${LAB}/.agents/rules/nano4.md" ] || cp "${REPO}/.agents/rules/nano4.md" "${LAB}/.agents/rules/nano4.md"
for f in "${REPO}"/04-ai-assisted-bio-pipeline/demo_data/fastq_raw/*.fastq.gz; do
    [ -e "${LAB}/fastq_raw/$(basename "$f")" ] || cp "$f" "${LAB}/fastq_raw/"
done

echo "✅ 工作資料夾已準備好：${LAB}"
ls -la "${LAB}" "${LAB}/fastq_raw"
echo "👉 下一步：在 Antigravity 用 File ➔ Open Folder 開啟 ${LAB}"
