#!/usr/bin/env bash
# ==============================================================================
# workflow_dependency.sh - Slurm 工作流相依性串接示範 (Pipeline Dependency)
# ==============================================================================
set -euo pipefail

echo "========================================================"
echo "🔗 示範 Slurm 作業相依性 (Dependency) 自動流水線"
echo "========================================================"

# 1. 提交第一階段作業 (例如：資料下載或前處理)
# --parsable 讓 sbatch 只印出純 Job ID
JOB_STAGE1=$(sbatch --parsable standard_cpu_job.slurm)
echo "階段 1 作業已送出，Job ID: ${JOB_STAGE1}"

# 2. 提交第二階段作業 (例如：質控分析)
# 使用 --dependency=afterok:<JOB_ID>，只有第一階段回傳 0 (成功) 才觸發第二階段
JOB_STAGE2=$(sbatch --parsable --dependency=afterok:${JOB_STAGE1} standard_cpu_job.slurm)
echo "階段 2 作業已送出 (依賴階段 1 成功)，Job ID: ${JOB_STAGE2}"

# 3. 提交第三階段作業 (例如：MultiQC 報告匯整)
JOB_STAGE3=$(sbatch --parsable --dependency=afterok:${JOB_STAGE2} standard_cpu_job.slurm)
echo "階段 3 作業已送出 (依賴階段 2 成功)，Job ID: ${JOB_STAGE3}"

echo "--------------------------------------------------------"
echo "✅ 流水線任務全部已成功加入排程佇列！"
echo "查詢狀態指令: squeue -u $(whoami)"
echo "========================================================"
