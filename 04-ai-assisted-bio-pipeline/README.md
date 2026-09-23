# 第 04 章：AI 輔助生醫管線 — 用我的 skill 做 FASTQ 質控並讀懂報告

本章用第 03 章 Lab 11 做好的 skill `my-nano4-slurm`，請 AI Agent（Antigravity 內建 Agent、Codex 或 Claude Code）對 FASTQ 定序資料執行 **FastQC** 與 **MultiQC** 品質控制，並和 Agent 一起讀懂報告。您只需要說出想完成的分析，指令與 Slurm 腳本交給 Agent；您負責判斷 Agent 的計畫與結論是否合理。

第 5 節另外保留一套在登入節點手動執行的質控腳本，作為對照組，也是第 03 章 Lab 9（容器）需要的資料來源。

> [!IMPORTANT]
> **💡 跨領域通用學習聲明 (Case Study Disclaimer)**：  
> 本章以「生醫基因定序 FASTQ 質控」作為**具象化的端到端 (End-to-End) 數據處理示範案例**。  
> **非生醫背景的讀者請放心**：無論您的真實研究是**計算流體力學 (OpenFOAM)**、**分子動力學 (GROMACS/LAMMPS)**、**有限元素分析 (ANSYS)** 還是**深度學習模型訓練 (PyTorch)**，本章所傳授的：  
> 1. **如何給予 AI Agent 結構化 Prompt 自動產生處理流程**  
> 2. **如何在登入節點以微型資料快速驗證管線邏輯 (Prototyping)**  
> 3. **如何利用 VS Code 連接埠轉送在瀏覽器預覽互動式報表**  
> 4. **如何讀懂報告中的品質指標，而不只是「看到」報告**（§7 練習）  
> 
> 這套「**數據拉取 ➔ 批次分析 ➔ 結果可視化**」的核心架構與思維，可延伸應用到多數科學運算領域。

---


> [!NOTE]
> 本章實作檔案位於教材 repository。若重新開啟終端機，先回到教材根目錄：
>
> ```bash
> cd "$HOME/Nano4-Docs"
> ```

## 📌 目錄 (Table of Contents)
- [1. 生醫資訊前處理概念：FASTQ、FastQC 與 MultiQC](#1-生醫資訊前處理概念fastqfastqc-與-multiqc)
- [2. 用我的 skill 請 AI Agent 做質控（第二堂主線）](#2-用我的-skill-請-ai-agent-做質控第二堂主線)
- [3. 請 AI Agent 撰寫分析腳本 (Prompt 提示詞技巧)](#3-請-ai-agent-撰寫分析腳本-prompt-提示詞技巧)
- [4. 檔案結構與腳本說明](#4-檔案結構與腳本說明)
- [5. 對照組：在登入節點手動執行質控流程](#5-對照組在登入節點手動執行質控流程)
- [6. 檢視互動式報告：連接埠轉送與本機預覽](#6-檢視互動式報告連接埠轉送與本機預覽)
- [7. 練習：讀懂 MultiQC 報告](#7-練習讀懂-multiqc-報告)
- [8. 登入節點之限制與進入 Slurm 排程的必要性](#8-登入節點之限制與進入-slurm-排程的必要性)

---

## 1. 生醫資訊前處理概念：FASTQ、FastQC 與 MultiQC

在生物資訊（Bioinformatics）與次世代定序（NGS、16S 擴增子定序、總體基因體學）研究中：

1. **FASTQ 檔案**：定序儀（如 Illumina、PacBio、ONT）輸出的標準格式，每個 Read 由 4 行組成：
   * `@Header`：定序儀機型與座標資訊
   * `Sequence`：鹼基序列（A, T, C, G, N）
   * `+`：分隔符號
   * `Quality`：對應每個鹼基的 Phred 品質分數（ASCII 字元編碼）
2. **FastQC**：針對單一 FASTQ 樣本進行品質檢驗，檢查項目包括：
   * **Per Base Sequence Quality**（鹼基品質分數曲線，Q30 代表 99.9% 準確率）
   * **Per Base Sequence Content**（ATCG 比例均衡度）
   * **Per Sequence GC Content**（GC 含量分佈，檢驗是否有外源物種污染）
   * **Adapter Content**（接頭序列殘留程度）
3. **MultiQC**：如果分析 30~100 個樣本，逐一開啟 FastQC HTML 報告耗時費力。MultiQC 能夠**一鍵掃描整個目錄，將所有樣本的 FastQC 數據聚合為一份互動式網頁報告**！

---

## 2. 用我的 skill 請 AI Agent 做質控（第二堂主線）

> [!NOTE]
> 需要先完成第 03 章 Lab 10–11：`/work/<帳號>/slurm_lab` 已建立，`my-nano4-slurm` 已用 `install_my_skill.sh` 複製給三個 Agent。

1. 在 Antigravity 用 File ➔ Open Folder 開啟 `/work/<帳號>/slurm_lab`，選一個 Agent **開新對話**（新對話才會讀到最新的 skill）。
2. 用自然語言說出您的分析需求：
   ```text
   請使用 my-nano4-slurm skill。fastq_raw/ 裡是 4 個 16S 定序樣本，我想知道它們的定序品質好不好、適不適合做後續分析。
   請用 FastQC 檢查每個樣本，再用 MultiQC 彙整成一份報告，結果放在 qc_skill/。
   送出前先告訴我你的計畫；跑完後告訴我報告的位置，並用白話說明：每個樣本有幾條 reads、品質分數如何、有沒有需要注意的警告。
   ```
3. 對照您的 skill，檢查 Agent 這次有沒有**不需要提醒**就做對：

   | 檢查項目 | ✅ / ❌ |
   | :--- | :---: |
   | 先說明計畫，等您同意才送出 | |
   | `GOV115088` + `ngs62g` + `-c 8 --mem=62G` | |
   | `module purge`，FastQC 一起載入 `biology/JDK/26.0.1` | |
   | 用 `sbatch` 送到計算節點；確認 FastQC 報告數量等於樣本數 | |
   | 用白話回報結果與報告位置 | |

   若還有 ❌，請 Agent 說明原因並修正，再請它**把這次的教訓補進 my-nano4-slurm**，然後重新執行 `install_my_skill.sh`。這就是 skill 的成長方式：每用一次，就更少犯錯。
4. 依第 6 節打開 Agent 產生的 MultiQC 報告（第 6 節方式 A 可以在腳本後面加上報告所在的資料夾），完成第 7 節的練習，並把您的答案和 Agent 的白話解讀互相比對：Agent 說的和報告上看到的一致嗎？

> [!TIP]
> 讀報告時，也可以直接問 Agent：「sample_04 的 Per Sequence GC Content 為什麼是紅色？這代表樣本不能用嗎？」請它用報告中的數據回答，您再對照圖表確認。

---

## 3. 請 AI Agent 撰寫分析腳本 (Prompt 提示詞技巧)

若沒有現成的 skill，也可以用一段具體、具備架構要求的提示詞請 Agent（Antigravity 內建 Agent、Codex 或 Claude Code）撰寫腳本：

```text
你是一位熟悉生物資訊分析與 Linux HPC 環境的工程師。
我目前在國網中心 Nano4 登入節點上，需要建立一套 FASTQ 資料前處理與品質控制（QC）管線。

請幫我編寫一個 Bash 腳本 `run_qc_pipeline.sh`，要求包含以下步驟：
1. 自動下載 QIIME 2 Moving Pictures 的示範 FASTQ 資料，存放在 `./fastq_raw/`。
2. 使用 Nano4 官方模組 `module load biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC` 載入 FastQC 與 MultiQC，找不到時要明確報錯停止。
3. 批次對 `./fastq_raw/` 下的所有 FASTQ 檔案執行 FastQC 分析，輸出至 `./fastqc_out/`。
4. 使用 MultiQC 彙整 `./fastqc_out/` 下的所有分析數據，生成 `./multiqc_out/multiqc_report.html`。
5. 包含完善的錯誤處理（set -euo pipefail），並在結尾輸出報告路徑。
```
*(完整提示詞可見 [`prompts/ai_prompt_bio_pipeline.md`](./prompts/ai_prompt_bio_pipeline.md))*

> 這是示範用 prompt，讓你練習如何向 AI 描述需求。第 5 節的對照組請使用本章已提供、驗證過的 `run_fastqc_multiqc.sh`；你可以拿 AI 產生的 `run_qc_pipeline.sh` 和它比較差異。

---

## 4. 檔案結構與腳本說明

```text
04-ai-assisted-bio-pipeline/
├── README.md                          # 本章完整教學手冊
├── prompts/
│   └── ai_prompt_bio_pipeline.md      # AI Agent 引導提示詞範本
├── scripts/
│   ├── download_demo_fastq.sh         # [1] 自動準備/取樣 4 組示範 FASTQ 檔案
│   ├── run_fastqc_multiqc.sh          # [2] 執行 FastQC 分析與 MultiQC 聚合
│   └── view_multiqc_report.sh         # [3] 啟動 HTTP 服務並引導 VS Code 轉送預覽
└── demo_data/                         # 資料與報告存放區
    ├── fastq_raw/                     # 原始 FASTQ 檔案 (*.fastq.gz)
    ├── fastqc_out/                    # FastQC 輸出產物 (*_fastqc.zip)
    └── multiqc_out/                   # MultiQC 匯總產物 (multiqc_report.html)
```

---

## 5. 對照組：在登入節點手動執行質控流程

這是不經過 AI、也不經過 Slurm 的手動版本：4 個微型樣本直接在登入節點跑，只需數秒。第三堂的第 03 章 Lab 9（容器）會用到這裡產生的 `demo_data/fastqc_out/`，請在 Lab 9 之前執行一次。

按下 **``Ctrl + ` ``** 展開整合式終端機：

### 步驟 1：下載示範 FASTQ 資料
```bash
cd "$HOME/Nano4-Docs/04-ai-assisted-bio-pipeline/scripts"
bash download_demo_fastq.sh
```
repository 已附 4 組示範樣本（`sample_01_R1.fastq.gz` ~ `sample_04_R1.fastq.gz`，各 1000 條 reads），此腳本會直接沿用；若檔案不存在，才會下載 QIIME 2 Moving Pictures 資料並重新拆分。

> [!NOTE]
> 質控腳本會以 `module load biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC` 載入 Nano4 官方模組，執行真正的 FastQC 與 MultiQC。4 個微型樣本在登入節點只需數秒、使用 4 核心，符合登入節點微型測試規範。

### 步驟 2：執行質控管線
```bash
bash run_fastqc_multiqc.sh
```
**執行日誌輸出範例：**
```text
========================================================
🔬 [1/3] 檢查 FASTQ 原始資料與質控工具...
FastQC 執行檔 : /work/envstack/apps/application/biology/FastQC/fastqc_v0.11.9/bin/fastqc
MultiQC 執行檔: /work/envstack/apps/application/biology/MultiQC/multiqc_v1.35/bin/multiqc
========================================================
🧬 [2/3] 執行 FastQC 品質控制分析...
========================================================
Analysis complete for sample_01_R1.fastq.gz
...
Analysis complete for sample_04_R1.fastq.gz
📊 [3/3] 執行 MultiQC 彙整產生單一 HTML 報告...
========================================================
/// MultiQC 🔍 v1.35
            fastqc | Found 4 reports
     write_results | Report : demo_data/multiqc_out/multiqc_report.html
           multiqc | MultiQC complete
--------------------------------------------------------
🎉 質控管線執行完畢！
MultiQC 報告位置: demo_data/multiqc_out/multiqc_report.html
```

> 實際畫面中的報告路徑會顯示為完整的絕對路徑（例如 `/home/<帳號>/Nano4-Docs/04-ai-assisted-bio-pipeline/scripts/../demo_data/multiqc_out/multiqc_report.html`），指的是同一個檔案。

---

## 6. 檢視互動式報告：連接埠轉送與本機預覽

產生的 `multiqc_report.html` 位於遠端 Nano4 伺服器上。在 Antigravity / VS Code Remote-SSH 架構下，有兩種預覽方式：

### 方式 A：一鍵啟動預覽並透過連接埠轉送 (Port Forwarding)
```bash
cd "$HOME/Nano4-Docs/04-ai-assisted-bio-pipeline/scripts"
bash view_multiqc_report.sh                                   # 第 5 節對照組的報告
bash view_multiqc_report.sh /work/$USER/slurm_lab/qc_skill/<報告所在資料夾>   # 第 2 節 Agent 產生的報告
```
**終端機提示：**
```text
========================================================
📊 MultiQC HTML 報告預覽服務已啟動！
========================================================
主機節點 : 25a-lgn01
分配埠號 : 43821
--------------------------------------------------------
👉 檢視報告方式 (VS Code Remote-SSH 使用者推薦)：
   1. VS Code 終端機通常會跳出提示：「在瀏覽器中開啟通訊埠 43821」
   2. 若無提示，請切換至 VS Code 下方面板「連接埠 (Ports)」頁籤
      點擊「轉送通訊埠 (Forward a Port)」並輸入 43821
   3. 在筆電瀏覽器打開：http://localhost:43821/multiqc_report.html
========================================================
```
點擊連結即可直接在個人電腦瀏覽器中操作互動式圖表、縮放品質曲線、下載統計圖檔！

看完報告後，請關閉在登入節點背景執行的預覽服務：
```bash
tmux kill-session -t svc-multiqc-report
```

### 方式 B：VS Code 檔案總管直接下載
在左側檔案總管找到 `multiqc_report.html`（第 2 節：`/work/<帳號>/slurm_lab/qc_skill/` 底下；第 5 節：`Nano4-Docs/04-ai-assisted-bio-pipeline/demo_data/multiqc_out/`），按右鍵 ➔ 選擇 **「下載... (Download...)」**，存至筆電桌面雙擊打開！

---

## 7. 練習：讀懂 MultiQC 報告

打開第 6 節的 MultiQC 報告，回答下列問題（約 5–10 分鐘）：

1. **General Statistics** 表格：4 個樣本各有幾條 reads？GC 含量大約是多少？
2. **Sequence Length Distribution**：reads 的長度範圍是多少？為什麼這一項會出現黃色警告？
3. **Per Base Sequence Quality**：4 個樣本的品質分數落在哪個顏色區域？整體品質好不好？
4. **Status Checks** 熱圖：哪個樣本的哪一項出現紅色（fail）？其他 3 個樣本同一項是什麼顏色？
5. 綜合判斷：第 4 題的紅色代表這個樣本不能用嗎？（提示：每個樣本只有 1000 條 reads。）

<details>
<summary><b>參考答案（先自己作答再展開）</b></summary>

1. 每個樣本 1000 條 reads（第 03 章 Lab 8 算出的數字也是 1000）；GC 含量約 46–47%。
2. 長度介於約 50–101 bp。FastQC 預期所有 reads 一樣長，長度不一致就會給警告；定序資料經過品質修剪（trimming）後長度不一很常見，通常不是問題。
3. 4 個樣本都落在綠色區域（`pass`），定序品質良好。
4. `sample_04_R1` 的 **Per Sequence GC Content** 為紅色（`fail`）；其他 3 個樣本同一項為黃色（`warn`）。`sample_04_R1` 另外還有 **Overrepresented Sequences** 警告。
5. 不一定。GC 含量分布需要足夠的 reads 才會平滑；只有 1000 條 reads 時分布很容易有鋸齒，就會觸發警告或失敗。FastQC 的紅黃綠是提醒「去看這張圖」，不是自動淘汰樣本；真正判斷要看完整資料與實驗設計。

</details>

---

## 8. 登入節點之限制與進入 Slurm 排程的必要性

第 5 節在登入節點上執行微型樣本（4 個樣本、各 1000 條 Reads）僅花費數秒鐘，是驗證程式碼邏輯的極佳方式。

**然而，在真實科研專案中：**
* 真實樣本文庫通常有 **數十到數千個樣本**。
* 每個 FASTQ 壓縮檔動輒 **數百 MB 到數十 GB**。
* 若直接在登入節點執行大型 FastQC、BWA 比對、SAMtools 排序或 QIIME 2 DADA2 去噪，會佔用高達數十個 CPU 核心與幾百 GB 記憶體，導致整台登入節點卡死。
* **國網中心官方安全鐵律**：登入節點上執行超過 5 分鐘的重度運算，系統守護程式將會**自動無預警強制清除該用戶的所有行程（Killed）**！

這也是第 2 節一開始就請 **AI Agent** 把分析寫成 **Slurm 批次作業**、派送到 Nano4 的 `ngs62g` 計算節點執行的原因（本課程唯一使用的佇列，每個作業固定 `-c 8 --mem=62G`）。

---

> 💡 **學習脈絡導讀 (Roadmap)**：  
> * 在 **第 03 章**，您學會了 Nano4 的 Slurm 語法，並把和 AI Agent 合作的經驗存成 `my-nano4-slurm`。  
> * 本章用這個 skill 完成了 FASTQ 質控與報告判讀。  
> * 在 **第 05 章**（第三堂），我們請 AI Agent 把登入節點的分析流程重構為離線與外網直連兩種 Slurm 管線；**第 06 章**再把您的 skill 和課程提供的 Skills 比較。

👉 **下一課**：[第 05 章：AI Agent 自動化 Slurm 排程](../05-ai-agent-slurm-pipeline/)
