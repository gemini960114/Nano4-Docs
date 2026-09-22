# AI Agent Slurm Pipeline Refactoring Skill

指導 AI Agent 將終端機互動式腳本自動重構成高強固性 Slurm 批次排程管線的專家技能。

## 🎯 核心功能
1. **雙架構評估**：純離線模式（Case A）與動態 HTTP Proxy 模式（Case B）智慧選型。
2. **安全規範注入**：自動注入 `set -euo pipefail`、萬用日誌命名、錯誤檢查與資源日誌輸出。
3. **相依排程串接**：支援多步驟自動串接（`--dependency=afterok:`）。
4. **免扣點驗證**：產出後自動引導 `sbatch --test-only` 預檢。
