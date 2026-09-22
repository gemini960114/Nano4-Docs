# Nano4 AI Agent 技能總匯庫 (Skills Hub)

本目錄為國網中心晶創26（Nano4 / `nano4.nchc.org.tw`）超級電腦量身設計的 **AI Agent 專家技能庫（Skills Hub）**。

透過將這些技能掛載至使用者的 Agent 環境（如 Google Antigravity、Claude Code、OpenCode CLI、Cursor 等），AI 助手將從通用程式設計師，進化為**精通 Nano4 超算排程、專案錢包授權、QoS 防呆規則與大數據生醫管線的專屬專家**。

---

## 📦 技能庫清單 (Skills Catalog)

| 技能名稱 | 核心功能 | 適用場景 |
| :--- | :--- | :--- |
| **[`nano4-slurm-operations`](./nano4-slurm-operations/)** | • 執行唯讀 preflight 檢查<br>• 驗證 `wallet` 專案與 Slurm association<br>• 檢查生醫專案 (`GOV115088`) 與 `ngs*` 佇列政策相容性 | 準備派送作業、查詢專案權限或確認佇列政策時 |
| **[`slurm-job-advisor`](./slurm-job-advisor/)** | • 引導式 4 步問答挖掘運算需求<br>• Nano4 硬體約束防呆（`ngs62g` 漏填 `--mem` 攔截、`dev` 需 `--gres=gpu:1`）<br>• `sbatch --test-only` 免扣點模擬預檢 | 需要規劃、配置、診斷或撰寫 Slurm 排程腳本時 |
| **[`ai-agent-slurm-pipeline`](./ai-agent-slurm-pipeline/)** | • 互動式腳本自動重構為 Slurm 批次管線<br>• 高速離線 (Case A) vs 外網直連 (Case B) 架構選型<br>• 多階段相依管線自動串接 (`--dependency=afterok:`) | 將 VS Code / 登入節點執行的資料分析流程派送至計算節點時 |

---

## 🚀 快速安裝與啟用

### 方法一：Nano4 登入節點一鍵同步腳本 (最推薦)

在 Nano4 登入節點上執行隨附的同步腳本：

```bash
cd 06-skills-hub
bash sync_skills.sh
```

執行後，所有技能將自動複製至 `~/.agents/skills/`，AI Agent（如 OpenCode、Antigravity）啟動時會自動辨識並載入這些能力！

### 方法二：現代標準 `npx skills add` 全域安裝

相容 [skills.sh](https://skills.sh/) 規範，支援 Google Antigravity、Claude Code、Cursor 等各類 AI Agent：

```bash
# 1. 檢視倉庫內所有可用技能
npx -y skills add gemini960114/F1-docs -l

# 2. 一鍵全域安裝所有技能 (~/.agents/skills/)
npx -y skills add gemini960114/F1-docs -g -y
```

---

## 🛠️ 內建實用工具速查

```bash
# 1. 執行 Nano4 唯讀環境與計畫預檢 (nano4-slurm-operations)
bash 06-skills-hub/nano4-slurm-operations/scripts/slurm-preflight.sh --project GOV115088 --partition ngs62g

# 2. 查詢 wallet 額度與可用佇列即時資源 (slurm-job-advisor)
bash 06-skills-hub/slurm-job-advisor/scripts/check_slurm_env.sh

# 3. 驗證 Slurm 腳本合規性與免扣點模擬預檢 (slurm-job-advisor)
bash 06-skills-hub/slurm-job-advisor/scripts/validate_slurm.sh your_script.slurm
```

---

## 💡 AI Agent 實戰調用示範

當您在 VS Code 中開啟 OpenCode 或 Antigravity 並對 AI 說：

> **使用者提問**：  
> 「我想在 Nano4 上跑一個 FASTQ 質控任務，有 8 個樣本，幫我寫一份 Slurm 批次腳本。」

AI Agent 偵測到掛載的 `slurm-job-advisor` 技能後，將自動進行以下專業動作：
1. **呼叫 `wallet`** 盤點使用者的可用計畫（如生醫 `GOV115088` 或一般 AI `GOV113021`）。
2. **主動防呆**：為生醫任務推薦 `ngs62g` 分區，並**主動加入 `#SBATCH --mem=16G`**，防止初學者漏寫導致的 `QOSMaxMemoryPerJob` 卡死。
3. **自動使用萬用日誌格式**：`#SBATCH --output=%x-%j.out`，避免子目錄不存在的崩潰問題。
4. **自動調用 `sbatch --test-only`** 進行免扣點模擬預檢，確認 100% 能在排程器中排隊後才回覆給使用者！
