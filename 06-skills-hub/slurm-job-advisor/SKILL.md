---
name: slurm-job-advisor
description: >-
  Comprehensive guide, interactive questionnaire system, and resource sizing engine for generating
  production-ready Slurm batch scripts on NCHC Nano4 (晶創26) and HPC clusters.
  Inspects real-time `wallet` project balances and `sinfo` partition capabilities, conducts a guided
  interactive interview to elicit missing user requirements, prevents absurd resource allocations
  (such as missing --mem in ngs62g triggering QOSMaxMemoryPerJob or omitting --gres=gpu:1 in dev),
  maps scientific software workloads to realistic hardware profiles, and provides automated script
  generation and pre-flight validation via `sbatch --test-only`.
---

# Slurm Job Advisor & Resource Sizing Expert (國網晶創26 / Nano4 專用)

本技能（Skill）專門指導 AI Assistant 在超級電腦（HPC，特別是國網中心晶創26 Nano4 / `nano4.nchc.org.tw`）環境中，引導使用者完成合理、合規、絕不踩坑的 Slurm 排程腳本規劃與生成。

---

## 📌 核心觸發情境 (When to Activate)

當使用者出現以下任何一種意圖時觸發本技能：
1. **明確提出需求**：指定了計畫代號、CPU 核心數、記憶體或 GPU、運行時間，要求產生 `.slurm` 排程腳本。
2. **提出計算軟體但不知如何配置**：例如「我要跑 GATK / FastQC / PyTorch / LLM 微調，幫我寫 Slurm 腳本」，需要 AI 依據軟體特性推薦適當的 CPU、記憶體或 GPU。
3. **需求模糊或未提供說明**：僅表示「幫我寫個 Slurm 腳本」或「我想派送作業到計算節點」，缺少帳號、佇列、核心或時間等關鍵資訊。

---

> 💡 **可攜性與腳本路徑說明**：本 Skill 所有輔助腳本皆位於此 Skill 自身安裝目錄的 `scripts/` 資料夾內（載入本 Skill 時系統會提供實際安裝路徑），完全獨立自足。AI 執行或引導執行輔助腳本時，務必以當次實際安裝路徑調用（以下範例以 `<此 skill 的 scripts 目錄>/xxx.sh` 表示），而非沿用固定字串。

## 🏛️ 第一部分：Nano4 硬體真相與資源約束矩陣

在給出任何建議前，AI **必須嚴格基於 Nano4 叢集真實硬體與排程架構**，杜絕幻覺與不合理配置：

### 1. 節點與佇列架構
* **登入節點主機**：`25a-lgn01~05`（Intel Xeon 8480+，216 核心，503GB RAM，1x H100 NVL GPU）。
* **高速工作磁區**：WekaFS 高速共享檔案系統掛載於 **`/work/${USER}`**（嚴禁使用 `/work1` 或 `/tmp` 存放大檔）。
* **計算節點對外連網**：**Nano4 計算節點具備外網直連能力 (Direct Internet)**，可直接連線 GitHub、Hugging Face 或 NCBI 下載資料，不需要任何 HTTP Proxy 隧道。

### 2. 專案類別與佇列對應限制 (Project vs. Partition)
* **本課程計畫 `GOV115088`（CPU-only）**：
  * **唯一 NGS 分區**：`ngs62g`（4天，官方規格每作業固定 -c 8 --mem=62G）。送到其他 `ngs*` 分區會被拒絕。
* **生醫平台計畫（如 `MST109178`, `ENT109430`）**：
  * **專屬分區**：`ngstest`（10分鐘、1 核 / 8GB）、`ngs8g`～`ngs1000g`、`ngs1500g`～`ngs6t`（超大記憶體 6TB）、`ngs1gpu~8gpu`（生醫專屬 GPU 佇列，最長 14 天）。
  * ❌ **禁止派送至一般 GPU 佇列**：`dev` 等分區將生醫專案列為 `DenyAccounts`。
* **一般 AI / 大模型訓練專案（如 `GOV113021`, `GOV114022`）**：
  * **H200 GPU 分區**：`dev`（最長 4 小時，除錯測試）、`8gpus`（最長 48 小時，單節點 8x H200 141GB）、`16gpus~256gpus`（多節點分散式平行）。
  * **GB200 Arm 分區**：`gb200-dev`（最長 2 小時，Blackwell Arm 架構除錯）、`gb200-r1/r2`（24 小時）。
  * ❌ **禁止派送至 `ngs*` 生醫分區**。

---

## 🚫 第二部分：不合理狀況檢測與防禦機制 (Guardrails)

AI 必須主動攔截並糾正以下「不合邏輯」或「必定失敗」的資源配置請求：

| 不合理狀況 (Fallacy) | 發生場景與危害 | AI 糾正與防禦措施 |
| :--- | :--- | :--- |
| **1. `ngs62g` 漏填 `--mem`** | 在 `ngs62g` 申請 4 核心但未寫 `#SBATCH --mem`。Slurm 預設為全節點 1024GB 記憶體，超過 QoS 限額，作業永遠卡在 `(QOSMaxMemoryPerJob)` 排隊或被拒絕！ | **主動介入說明**：「在 Nano4 `ngs62g` 佇列中，必須依官方規格明確指定 `-c 8 --mem=62G`，否則會因預設全額超限而卡死！」 |
| **2. `dev` 申請 0 GPU** | 用戶在 `dev` 分區申請 CPU 任務，未寫 `--gres=gpu:1`。系統拋出 `job violates accounting/QOS policy (0 < 1)` 直接拒絕提交。 | **主動介入說明**：「Nano4 `dev` 為 H200 GPU 測試分區，QoS 規範最少必須申請 1 顆 GPU（`#SBATCH --gres=gpu:1`）！」 |
| **3. 使用舊 F1 佇列名稱** | 用戶寫 `#SBATCH -p ct112` 或 `-p cf112` 或 `-p visual-dev`。 | **指出分區不存在**：「這些是舊版超級電腦 (F1) 的佇列名稱。Nano4 請改用 `ngs62g`（CPU）或 `dev`（H200 GPU）！」 |
| **4. 測試作業直接掛 96 小時** | 新手除錯腳本直接申請 `--time=96:00:00`，導致在佇列中排隊數小時甚至數天。 | **推薦測試佇列**：「首次測試腳本建議把 `--time` 設為 10～30 分鐘：`GOV115088` 用 `ngs62g`，`MST109178` 可用 `ngstest`（限時 10 分鐘、1 核 / 8GB）。」 |
| **5. 遺漏 `--account`** | 未指定計畫代號。Nano4 排程器會強制攔截並終止提交。 | **強制要求指定**：必須於腳本標頭填入 `wallet` 查詢到的正數點數計畫代號（生醫專案如 `#SBATCH -A GOV115088`，AI 專案如 `#SBATCH -A GOV113021`）。 |
| **6. 日誌路徑目錄不存在** | 寫 `#SBATCH -o logs/job-%j.out` 但當前目錄沒有 `logs/` 資料夾，導致 Slurm 拋出 `_open_output_file: No such file or directory` 瞬間失敗。 | **推薦萬用 Token**：統一建議使用 `#SBATCH -o %x-%j.out` 與 `#SBATCH -e %x-%j.err`。 |

---

## 💬 第三部分：引導式問答流程 (Interactive Guided Questionnaire)

當使用者未提供完整規格時，AI **嚴禁盲目胡亂猜測**，應發起精準的「四步引導式提問」：

```markdown
您好！為了為您規劃最合適且符合國網晶創26（Nano4）硬體規格的 Slurm 排程腳本，請協助提供以下 4 項資訊：

1. 💳 【計費計畫代號 (Account)】
   系統查詢到您帳號目前可用的計畫代號如下（執行 wallet 查詢）：
   - GOV113021 (一般 AI 計畫，可用於 H200 dev / 8gpus)
   - GOV115088 (本課程計畫，僅可用 ngs62g)
   請問此作業要使用哪一個計畫代號？

2. 🔬 【運算任務類型與軟體】
   您預計執行的程式為何？
   (A) 生物資訊基因比對 / 質控 (如 FastQC, BWA, GATK, Amplicon ➔ 推薦生醫 ngs62g)
   (B) 基因體組裝 / 大矩陣運算 (高記憶體需求 ➔ 推薦 ngs250g 或 6.2TB ngs6t)
   (C) 深度學習模型微調 / 推論 (PyTorch, vLLM ➔ 推薦 H200 dev 或 8gpus)
   (D) 批次多樣本平行處理 (Array Job ➔ 推薦 ngs62g)
   (E) 快速語法邏輯除錯 (GOV115088 → ngs62g 搭配 --time=00:10:00；MST109178 → ngstest)

3. ⚡ 【預估 CPU 核心、記憶體與 GPU 需求】
   - 一般 CPU (官方規格 8 核 / 62GB RAM) ➔ ngs62g
   - 滿載 CPU (8 核 / 62GB RAM) ➔ ngs62g
   - 超高記憶體 (64~124 核 / 250GB~6TB RAM) ➔ ngs250g / ngs6t (僅 MST109178 等生醫平台計畫)
   - H200 GPU 運算 (1 顆 H200 / 12 核 / 64GB RAM) ➔ dev

4. ⏱️ 【運行時間預估 (Walltime)】
   預計作業需要執行多久？
   是否需要設定作業完成或失敗時發送 Email 通報？
```

---

## 🚀 第四部分：自動驗證與派送 (Pre-Flight Validation)

在生成腳本後，AI 應主動透過腳本驗證合規性：

```bash
# 1. 執行靜態合規與排程器免扣點預檢
bash <此 skill 的 scripts 目錄>/validate_slurm.sh your_job.slurm

# 2. 或直接調用原生 Slurm 模擬預檢指令
sbatch --test-only your_job.slurm
# 注意：--test-only 只檢查帳號/分區組合，不檢查 QoS 上限 (例如 ngs62g 的 8 核 / 62GB)
```
若預檢成功印出 `sbatch: Job <ID> to start at ...`，即可放心告知使用者正式提交：`sbatch your_job.slurm`！
