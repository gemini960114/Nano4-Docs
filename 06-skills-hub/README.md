# 第 06 章：Nano4 AI Agent 技能總匯庫 (Skills Hub)

本目錄為國網中心晶創26（Nano4 / `nano4.nchc.org.tw`）超級電腦量身設計的 **AI Agent 專家技能庫（Skills Hub）**。

透過將這些技能掛載至使用者的 Agent 環境（本課程的 Antigravity 內建 Agent、Codex、Claude Code，以及 Cursor 等），AI 助手將從通用程式設計師，進化為**精通 Nano4 超算排程、專案錢包授權、QoS 防呆規則與大數據生醫管線的專屬專家**。

---

> [!NOTE]
> 本章 Skills 位於教材 repository。若重新開啟終端機，先回到教材根目錄：
>
> ```bash
> cd "$HOME/Nano4-Docs"
> ```

> [!TIP]
> **第三堂的主軸：把您的 skill 和課程 Skills 比較。** 第二堂您在第 03 章 Lab 11 做了 `my-nano4-slurm`；本章的 Skills 是講師整理的版本。兩者比較後，把值得學的地方補進自己的 skill，見本章最後的「練習：比較我的 skill 與課程 Skills」。

## 📦 技能庫清單 (Skills Catalog)

| 技能名稱 | 核心功能 | 適用場景 |
| :--- | :--- | :--- |
| **[`nano4-slurm-operations`](./nano4-slurm-operations/)** | • 執行唯讀 preflight 檢查<br>• 驗證 `wallet` 專案與 Slurm association<br>• 檢查生醫專案 (`GOV115088`) 與 `ngs*` 佇列政策相容性 | 準備派送作業、查詢專案權限或確認佇列政策時 |
| **[`slurm-job-advisor`](./slurm-job-advisor/)** | • 引導式 4 步問答挖掘運算需求<br>• Nano4 硬體約束防呆（`ngs62g` 必須 `-c 8 --mem=62G`、`GOV115088` 只能用 `ngs62g`、`dev` 需 `--gres=gpu:1`）<br>• `validate_slurm.sh` 靜態檢查 + `sbatch --test-only` 免扣點預檢，任何一項不符即判定失敗 | 需要規劃、配置、診斷或撰寫 Slurm 排程腳本時 |
| **[`ai-agent-slurm-pipeline`](./ai-agent-slurm-pipeline/)** | • 互動式腳本自動重構為 Slurm 批次管線<br>• 高速離線 (Case A) vs 外網直連 (Case B) 架構選型<br>• 多階段相依管線自動串接 (`--dependency=afterok:`) | 將 VS Code / 登入節點執行的資料分析流程派送至計算節點時 |
| **[`nfcore-ampliseq-nano4`](./nfcore-ampliseq-nano4/)** | • 真實 amplicon 資料溯源與 checksum<br>• nf-core test → 正式資料的 Slurm 執行<br>• primer、metadata、結果與資源驗證 | 在 Nano4 準備、執行或審查 nf-core/ampliseq 分析時 |

---

## 🚀 快速安裝與啟用

### 方法一：Nano4 登入節點一鍵同步腳本 (最推薦)

在 Nano4 登入節點上執行隨附的同步腳本：

```bash
cd "$HOME/Nano4-Docs/06-skills-hub"
bash sync_skills.sh
```

執行後，所有技能會複製到三個位置：`~/.agents/skills/`（Codex 讀取）、`~/.claude/skills/`（Claude Code 讀取）與 `~/.gemini/config/skills/`（Antigravity 讀取）。三個 Agent 開新對話時就會載入這些技能。

> [!NOTE]
> 以 `$HOME/Nano4-Docs` 為工作資料夾時，Antigravity 與 Codex 也會直接載入 repository 裡 `.agents/skills/` 的同一批技能，不需要安裝；`sync_skills.sh` 讓您在其他資料夾（例如 `/work/<帳號>`）也能使用。

### 方法二：現代標準 `npx skills add` 全域安裝

（需先有 Node.js / npm；登入節點若沒有 `npx`，請改用方法一。兩種方法擇一即可；本課程建議用方法一，它會同時安裝到三個 Agent 的技能目錄。）

相容 [skills.sh](https://skills.sh/) 規範，支援 Google Antigravity、Claude Code、Cursor 等各類 AI Agent：

```bash
# 1. 檢視倉庫內所有可用技能
npx -y skills add gemini960114/Nano4-Docs -l

# 2. 一鍵全域安裝所有技能 (~/.agents/skills/)
npx -y skills add gemini960114/Nano4-Docs -g -y
```

---

## 🛠️ 內建實用工具速查

```bash
# 1. 執行 Nano4 唯讀環境與計畫預檢 (nano4-slurm-operations)
bash "$HOME/Nano4-Docs/06-skills-hub/nano4-slurm-operations/scripts/slurm-preflight.sh" --project GOV115088 --partition ngs62g

# 2. 查詢 wallet 額度與可用佇列即時資源 (slurm-job-advisor)
bash "$HOME/Nano4-Docs/06-skills-hub/slurm-job-advisor/scripts/check_slurm_env.sh"

# 3. 驗證 Slurm 腳本合規性與免扣點模擬預檢 (slurm-job-advisor)
bash "$HOME/Nano4-Docs/06-skills-hub/slurm-job-advisor/scripts/validate_slurm.sh" \
    "$HOME/Nano4-Docs/03-slurm-syntax-and-job-management/templates/standard_cpu_job.slurm"
```

---

## 🧪 練習：讓 Skill 抓出不合規的 Slurm 腳本

**目標**：`sbatch --test-only` 只檢查帳號與分區，不會發現「`ngs62g` 記憶體沒有用 62G」這類違反官方規格的錯誤。本練習用 `slurm-job-advisor` 的驗證工具抓出這些錯誤，再讓 AI Agent 依 Skill 修正。

1. 準備一份正確、兩份故意寫錯的腳本：
   ```bash
   mkdir -p /work/$USER/skill_lab && cd /work/$USER/skill_lab
   cp "$HOME/Nano4-Docs/03-slurm-syntax-and-job-management/templates/standard_cpu_job.slurm" good.slurm
   sed 's/^#SBATCH --mem=62G .*/#SBATCH --mem=16G/' good.slurm > bad_mem.slurm
   sed 's/^#SBATCH --partition=ngs62g .*/#SBATCH --partition=ngs32g/' good.slurm > bad_partition.slurm
   ```
2. 先用 `sbatch --test-only` 檢查 `bad_mem.slurm`：
   ```bash
   sbatch --test-only bad_mem.slurm
   ```
   **會顯示 `Job ... to start at ...`**，也就是排程器沒有發現記憶體設定錯誤。
3. 改用 Skill 的驗證工具檢查三份腳本：
   ```bash
   V="$HOME/Nano4-Docs/06-skills-hub/slurm-job-advisor/scripts/validate_slurm.sh"
   bash "$V" good.slurm;          echo "exit=$?"
   bash "$V" bad_mem.slurm;       echo "exit=$?"
   bash "$V" bad_partition.slurm; echo "exit=$?"
   ```
   **預期結果**：

   | 腳本 | 驗證結果 | 回傳值 |
   | :--- | :--- | :---: |
   | `good.slurm` | `🎉 [驗證通過]` | 0 |
   | `bad_mem.slurm` | `❌ [規格錯誤] 'ngs62g' 官方規格為 --mem=62G，目前設定為 16G！` | 1 |
   | `bad_partition.slurm` | `❌ [授權錯誤] 計畫 GOV115088 只能使用 ngs62g` | 1 |
4. 讓 AI Agent 修正：在 Antigravity（或 Claude Code）開啟 `/work/<帳號>/skill_lab`，輸入：
   ```text
   請使用 slurm-job-advisor skill 檢查 bad_mem.slurm 與 bad_partition.slurm，說明錯在哪裡並修正，修正後執行 validate_slurm.sh 確認通過，但不要提交作業。
   ```
5. 自己再執行一次步驟 3，確認三份腳本都顯示 `🎉 [驗證通過]`。

---

## 💡 AI Agent 實戰調用示範

當您在 Antigravity（內建 Agent、Codex 或 Claude Code）對 AI 說：

> **使用者提問**：  
> 「我想在 Nano4 上跑一個 FASTQ 質控任務，有 8 個樣本，幫我寫一份 Slurm 批次腳本。」

AI Agent 偵測到掛載的 `slurm-job-advisor` 技能後，將自動進行以下專業動作：
1. **呼叫 `wallet`** 盤點使用者的可用計畫（如生醫 `GOV115088` 或一般 AI `GOV113021`）。
2. **主動防呆**：為生醫任務推薦 `ngs62g` 分區，並依官方規格**主動加入 `#SBATCH --cpus-per-task=8` 與 `#SBATCH --mem=62G`**，防止初學者漏寫導致的 `QOSMaxMemoryPerJob` 卡死。
3. **自動使用萬用日誌格式**：`#SBATCH --output=%x-%j.out`，避免子目錄不存在的崩潰問題。
4. **自動調用 `sbatch --test-only`** 進行免扣點預檢，確認帳號與分區組合可被接受；CPU / 記憶體是否超過 QoS 上限，則由技能內建的佇列規則另外比對（`--test-only` 不會檢查 QoS）。

---

## 🧪 練習：比較我的 skill 與課程 Skills

**目標**：第二堂您把和 Agent 合作的經驗存成 `my-nano4-slurm`；課程的 `slurm-job-advisor`、`ai-agent-slurm-pipeline` 解決的是類似的問題。比較兩者，把值得學的地方補進自己的 skill。

1. 在 Antigravity 開啟 `$HOME/Nano4-Docs`，選一個 Agent 開新對話，輸入：
   ```text
   請比較我的 skill ~/.agents/skills/my-nano4-slurm/SKILL.md 和課程提供的 06-skills-hub/slurm-job-advisor/SKILL.md、06-skills-hub/ai-agent-slurm-pipeline/SKILL.md。
   用表格列出：兩邊都有的規則、只有課程 Skills 有的檢查、只有我的 skill 有的經驗。先不要修改任何檔案。
   ```
2. 和同學討論：課程 Skills 有哪些檢查是您在 Lab 10 沒有遇到、但真實研究會遇到的（例如 `validate_slurm.sh` 抓出 `sbatch --test-only` 漏掉的規格錯誤）？您的 skill 又記下了哪些課程 Skills 沒寫的經驗？
3. 挑一到兩項補進自己的 skill：
   ```text
   請把剛才表格中「只有課程 Skills 有的檢查」裡，對我最有用的兩項補進 my-nano4-slurm，保留我原本的經驗，改完後讓我看修改的地方。
   ```
4. 重新安裝，讓三個 Agent 都讀到新版本：
   ```bash
   bash "$HOME/Nano4-Docs/03-slurm-syntax-and-job-management/scripts/install_my_skill.sh"
   ```

---

👉 **下一課**：[第 07 章：nf-core/ampliseq 真實 16S 案例](../07-nfcore-ampliseq-case-study/)
