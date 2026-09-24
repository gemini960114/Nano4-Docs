# 第 07 章：nf-core/ampliseq 真實案例——手動操作、AI 重做與 Skill 封裝

本章是前六章的整合實戰。學生先親手完成一次公開 paired-end 16S
資料分析，再讓 AI Agent 使用相同輸入重做，最後比較兩者並把可靠流程
封裝成 `nfcore-ampliseq-nano4` Skill。講師事先跑好的完整結果放在
[GitHub Release](https://github.com/gemini960114/Nano4-Docs/releases/tag/ampliseq-demo-2026-09-23)，真實資料還沒跑完時可先下載觀看（見 §5.1）。

> [!NOTE]
> **課堂安排（第三堂）**：開課先送出 §3.2 下載資料與 §3.3 官方 test profile（約 28 分鐘），等待時上第 05、06 章；§3.4 真實資料（約 1 小時 40 分鐘）、§4 AI 重做與 §6 Skill 封裝由講師示範，學生課後完成並依 §7 繳交。

```text
人工操作一次
    ↓
AI Agent 重做
    ↓
比較資料、設定、結果與資源
    ↓
沉澱為可重用 Skill
```

> [!IMPORTANT]
> 官方 test profile 只驗證 Nextflow、Slurm、Singularity 與 pipeline 能否運作；
> 真實資料才用於學習資料溯源與結果解讀。兩者目的不同，不能互相取代。

> [!IMPORTANT]
> **本章只使用 CPU，不申請 GPU。** 本課程計畫為 `GOV115088`，在 NGS CPU 佇列中**只能使用 `ngs62g`**
> （官方規格：每個作業 `-c 8 --mem=62G`，最長 4 天）。因此 Nextflow driver 與所有 pipeline 子工作都送到 `ngs62g`，並一律依官方規格申請 8 核心 / 62 GB，
> 不使用 `ngs1gpu`～`ngs8gpu`，也不加入 `--gres=gpu`。

> [!NOTE]
> 本章實作檔案位於教材 repository。若重新開啟終端機，先回到本章目錄：
>
> ```bash
> cd "$HOME/Nano4-Docs/07-nfcore-ampliseq-case-study"
> ```

## 📌 目錄 (Table of Contents)
- [0. 本章故事：一位研究生的一天](#0-本章故事一位研究生的一天)
- [1. 本章使用的兩套資料](#1-本章使用的兩套資料)
- [2. 工作目錄與先備檢查](#2-工作目錄與先備檢查)
- [3. 第一階段：學生手動操作一次](#3-第一階段學生手動操作一次)
- [4. 第二階段：讓 AI Agent 重做](#4-第二階段讓-ai-agent-重做)
- [5. 第三階段：查看與解讀結果](#5-第三階段查看與解讀結果)
- [6. 第四階段：封裝並使用 Skill](#6-第四階段封裝並使用-skill)
- [7. 繳交內容](#7-繳交內容)

## 0. 本章故事：一位研究生的一天

> 先讀這一節，再動手。後面每一個指令，都對應到這個故事裡的一個決定。

### 0.1 研究問題

小林是研究「早期生活壓力」的研究生。他讀到一篇論文：
[*Early life stress in mice alters gut microbiota independent of maternal microbiota inheritance*](https://doi.org/10.1152/ajpregu.00072.2020)。

研究者讓一組幼鼠經歷 **MSEW**（Maternal Separation with Early Weaning，**母鼠分離＋提早斷奶**），這是模擬「童年早期壓力」的常用小鼠模型；另一組幼鼠正常飼養，作為 **Control**。他們想知道：

- 早期壓力會不會改變幼鼠的**腸道菌相**（腸道裡有哪些細菌、各佔多少）？
- 如果會改變，是不是只是因為「媽媽的菌傳給了小孩」？論文標題的答案是：**不是，改變與母鼠菌相的遺傳無關**。

要回答「腸道裡有哪些細菌」，研究者對糞便樣本做 **16S rRNA 擴增子定序**：只把細菌共有的 16S 基因中一小段（V4 區）放大後定序。每條 read 就像一張細菌的「條碼」，比對條碼就能知道是哪種細菌。

### 0.2 指導教授的任務

指導教授請小林：「用作者公開的原始資料，在國網 Nano4 上把分析流程重現一次，而且要讓別人看得懂、能重跑。」為了在課堂時間內完成，小林只挑 6 個樣本：3 個 Control、3 個 MSEW，全部是同一批實驗（`exp1`）、出生後第 10 天（`PD10`）、公鼠，並且各來自不同窩（litter）。分組完全照作者的 metadata，**小林沒有自己發明任何分組**。

### 0.3 小林的做法，也就是本章的步驟

| 小林的想法 | 對應章節 | 你要做的事 |
| :--- | :--- | :--- |
| 「先搞懂資料從哪來、為什麼是這 6 個樣本。」 | 1、3.1 | 讀 `study_notes.md`、樣本表與 manifest |
| 「資料要下載完整、而且沒損壞。」 | 3.2 | 在計算節點下載 FASTQ 並逐檔核對 MD5 |
| 「先別急著跑真資料，確認**機器這關**能過。」 | 3.3 | 跑 nf-core 內建的 test profile |
| 「環境沒問題了，才跑真實資料。」 | 3.4 | 跑 6 個樣本的完整分析 |
| 「讀懂結果，不要過度解讀。」 | 5 | 依序看 QC、primer 移除、DADA2、多樣性 |
| 「請 AI 用同樣的資料再做一次，並逐項檢查它。」 | 4 | AI 重做、人工核准、比較差異 |
| 「把做對的規則留下來，下次直接用。」 | 6 | 封裝成 Skill |

### 0.4 為什麼一定要先跑 test？

分析失敗時，原因只有兩大類：**環境問題**（軟體、容器、Slurm 設定、權限）或**資料問題**（檔案損壞、primer 錯誤、樣本表寫錯）。
test profile 使用 nf-core 官方準備好、保證正確的小型資料：

- **test 成功** → 環境沒問題。之後真實資料若失敗，就專心檢查資料與參數。
- **test 失敗** → 問題一定在環境，不必懷疑資料。

先用 test 把兩類問題分開，除錯範圍立刻縮小一半。這是實務上跑任何 nf-core pipeline 的標準做法。也因為 test 資料是「軟體測試用」，**它的分組與圖表不能拿來做任何生物學解讀**。

### 0.5 nf-core/ampliseq 幫小林做了什麼？

nf-core/ampliseq 是社群維護的標準化擴增子分析 pipeline。它把下面這些步驟串在一起，每一步都會變成一個（或數個）Slurm 作業：

| 步驟 | 工具 | 白話說明 | 結果目錄 |
| :--- | :--- | :--- | :--- |
| 1. 原始資料品質檢查 | FastQC / MultiQC | 看定序品質好不好、有沒有異常 | `fastqc/`、`multiqc/` |
| 2. 移除 primer | Cutadapt | 切掉每條 read 開頭的引子（515F / 806R），只留真正的菌種序列；找不到 primer 的 read 會被丟掉 | `cutadapt/` |
| 3. 去雜訊、找出 ASV | DADA2 | 過濾低品質 reads、校正定序錯誤、合併雙端 reads、去除嵌合體，得到 **ASV**（Amplicon Sequence Variant，精確到單一鹼基的「序列種類」）與每個樣本的數量表 | `dada2/` |
| 4. 物種分類 | DADA2 + SILVA 138.2 | 拿每個 ASV 去比對 SILVA 參考資料庫，判斷它是哪個門、綱、目、科、屬 | `dada2/`、`qiime2/abundance_tables/` |
| 5. 多樣性分析 | QIIME 2 | **alpha 多樣性**：單一樣本內菌種有多豐富；**beta 多樣性**：兩個樣本菌相有多不同，並以 PCoA 圖呈現分組 | `qiime2/diversity/` |
| 6. 總結報告 | MultiQC / summary report | 把各步驟的統計彙整成網頁報告 | `multiqc/`、`summary_report/` |

### 0.6 執行時你會看到什麼？

送出 test 或真實資料的作業後，只需要執行**一次** `squeue --me` 查看（不要用 `watch` 反覆刷新）：

```text
 JOBID PARTITION     NAME     USER ST   TIME NODES NODELIST(REASON)
425914    ngs62g ampliseq  student  R  03:12     1 25a-cpn01
425930    ngs62g nf-NFCOR  student  R  00:41     1 25a-cpn01
425931    ngs62g nf-NFCOR  student PD  00:00     1 (Priority)
```

`squeue` 預設只顯示作業名稱的前 8 個字元，所以 `ampliseq_test` 會顯示成 `ampliseq`、`nf-NFCORE_…` 會顯示成 `nf-NFCOR`。

| 你看到的 | 意思 |
| :--- | :--- |
| `ampliseq_test` / `ampliseq_real` | **主控作業（driver）**：裡面跑 Nextflow，負責依序把每個分析步驟送出成子作業。它會一直執行到整條 pipeline 結束 |
| `nf-NFCORE_AMPLISEQ_…` | **子作業**：pipeline 的某一個步驟，例如 `…_DADA2_DENOISING`、`…_QIIME2_DIVERSITY_…`。會陸續出現、結束，數量可達上百個 |
| `ST` = `R` | Running，正在計算節點上執行 |
| `ST` = `PD` + `(Priority)` / `(Resources)` | Pending，正在排隊等資源，屬正常現象 |
| `ST` = `PD` + `(Dependency)` | 等待其他作業先完成 |

每個子作業都依 `ngs62g` 官方規格申請 8 核心 / 62 GB。進度請看 driver 的日誌 `ampliseq_test-<JOB_ID>.out`：每行 `[PROCESS …]` 代表一個步驟被送出；最後出現 **`Pipeline completed successfully`** 才代表成功。

## 1. 本章使用的兩套資料

### 1.1 nf-core/ampliseq 官方 test profile

固定使用 nf-core/ampliseq `2.18.0` 的 `test` profile。該 profile 隨 pipeline
版本提供小型輸入與完整參數，適合確認：

- Nextflow 可以啟動；
- `executor = slurm` 確實提交子工作；
- Singularity/Apptainer 能執行國網預先下載的容器；
- `/work/${USER}` 的 work 與 cache 可由所有節點存取；
- nf-core/ampliseq 能跑到完成。

它不是一個具備完整研究問題的正式 cohort，因此不拿 test profile 的 PCoA
或分組結果做生物學結論。

### 1.2 公開研究 PRJNA605008

真實案例使用論文 [*Early life stress in mice alters gut microbiota independent
of maternal microbiota inheritance*](https://doi.org/10.1152/ajpregu.00072.2020)
公開於 ENA/SRA 的 raw FASTQ，以及作者公開的
[`mapping_file.txt`](https://raw.githubusercontent.com/KMKemp/ELS/main/mapping_file.txt)。

為配合課堂時間，本章選出六個原始樣本：

| Pipeline ID | 作者 SampleID | Treatment | Litter | BioSample | Run |
| --- | --- | --- | --- | --- | --- |
| `C_L1_03` | `C-L1-03` | Control | `CONT-L1` | `SAMN14007776` | `SRR11028771` |
| `C_L2_03` | `C-L2-03` | Control | `CONT-L2` | `SAMN14007781` | `SRR11028740` |
| `C_L3_04` | `C-L3-04` | Control | `CONT-L3` | `SAMN14007789` | `SRR11028776` |
| `M_L1_03` | `M-L1-03` | MSEW | `MSEW-L1` | `SAMN14007807` | `SRR11028732` |
| `M_L2_03` | `M-L2-03` | MSEW | `MSEW-L2` | `SAMN14007818` | `SRR11028720` |
| `M_L3_03` | `M-L3-03` | MSEW | `MSEW-L3` | `SAMN14007827` | `SRR11028758` |

六個樣本均為作者 metadata 中的 `exp1`、`PD10`、`MALE`，並分別來自三個
litter。課堂沒有發明 Control/MSEW 分組。因 nf-core/ampliseq 2.18.0 的 sample
ID 不能包含連字號，只有 pipeline ID 將 `-` 可逆地改成 `_`；原始 SampleID
仍保存在 metadata。

研究使用的 primer 是：

```text
515F  GTGYCAGCMGCCGCGGTAA
806R  GGACTACNVGGGTWTCTAAT
```

本章已抽查 ENA raw reads，read 開頭實際包含相符的 degenerate 515F，因此
正式命令會提供 primer 讓 Cutadapt 移除。這個判斷來自該研究與 FASTQ
內容，不是因為它剛好也是 nf-core 文件的範例 primer。

## 2. 工作目錄與先備檢查

程式碼留在 Git repository，大型資料與 cache 全部寫入 WekaFS（約 286 MB FASTQ 加上 taxonomy 與 Nextflow work）：

```text
/work/${USER}/nfcore-ampliseq-course/
├── data/                       # ENA raw FASTQ
├── metadata/
│   ├── samplesheet.tsv         # 腳本由 manifest 產生
│   └── metadata.tsv            # 作者 metadata 的課堂子集
├── cache/
│   ├── nextflow/
│   ├── singularity/            # 個人補抓的容器 (共享快取缺少時才使用)
│   ├── singularity-library/    # 指向國網共享容器快取的連結
│   ├── singularity-runtime/
│   └── taxonomy/               # SILVA 138.2，第一次正式分析時下載
├── provenance/
├── results-test/
├── results-real/
├── work-test/
└── work-real/
```

> [!WARNING]
> `/work/${USER}/nfcore-ampliseq-course/` 是本案例的**短期運算工作區**，不是永久保存位置，也沒有備份。學生完成分析後，至少要保留 `data/` 的來源紀錄、`metadata/`、`provenance/`、pipeline 版本／命令、Slurm Job ID 與必要的 `results-*`；再依 GP1 官方規範移到長期儲存或核准的備份位置。先用 `hfsquota` 確認配額，避免 FASTQ、container cache 與 Nextflow work 佔滿 `/work`。

### 2.1 國網離線 nf-core 環境

本章使用國網中心預先封裝的 **`biology/nf-core-ampliseq/2.18.0`** 模組，而不是讓每位學生各自從 GitHub 與容器 registry 下載：

| 項目 | 來源 |
| :--- | :--- |
| Nextflow 26.04.6 與 Java | 模組相依的 `biology/Nextflow/26.04.6` |
| nf-core/ampliseq 2.18.0 程式碼 | `$NFCORE_AMPLISEQ_HOME`（國網預載） |
| Singularity 容器 | 國網共享唯讀快取（預先下載） |
| 站台 Slurm／容器設定 | `$NFCORE_SITE_CONFIG`，再疊加本章 `config/nano4.config` |
| SILVA 138.2 taxonomy | 第一次正式分析時由計算節點下載到 `cache/taxonomy/` |
| ENA FASTQ | `01_prepare_real_data.slurm` 在計算節點下載 |

`scripts/nfcore_env.sh` 會在每個 driver job 內執行 `module purge` 與 `module load biology/nf-core-ampliseq/2.18.0`，並把 cache 導向 `/work`。有兩個站台細節由它和 `config/nano4.config` 處理：

- 國網 `site.config` 會依記憶體把每個 process 分到 `ngs8g`、`ngs16g`…，但 `GOV115088` 只能用 `ngs62g`，所以 `nano4.config` 把所有 process（含 `process_high_memory`）固定送到 `NFCORE_PARTITION`，並以 `withName: '.*'` 讓**每個 process 都依 `ngs62g` 官方規格申請 8 CPU / 62 GB**（覆蓋 nf-core 內建的 1 GB、3 GB 等預設值），時間上限 96 小時。
- 共享容器快取中有少數檔案其實是下載失敗的 HTML 錯誤頁（例如 `bioconductor-biostrings-2.58.0`）。`nfcore_env.sh` 只連結有效的映像檔，缺少的會自動下載到個人 `cache/singularity/`，不會因唯讀快取而失敗。

### 2.2 先備檢查

先確認環境，不要在登入節點直接啟動分析：

```bash
cd "$HOME/Nano4-Docs/07-nfcore-ampliseq-case-study"
hostname
wallet GOV115088
module load biology/nf-core-ampliseq/2.18.0
nextflow -version
singularity --version || apptainer --version
module purge
```

執行唯讀 preflight，確認 `GOV115088` 與 `ngs62g` 的授權：

```bash
bash "$HOME/Nano4-Docs/06-skills-hub/nano4-slurm-operations/scripts/slurm-preflight.sh" \
    --project GOV115088 \
    --partition ngs62g
```

`GOV115088` 在 NGS CPU 佇列中只有 `ngs62g` 可用；若日後改用其他計畫，仍須以當天的 wallet、association 與 partition policy 為準。

## 3. 第一階段：學生手動操作一次

### 3.1 閱讀資料來源

先閱讀以下三個檔案：

```bash
cd "$HOME/Nano4-Docs/07-nfcore-ampliseq-case-study"
less metadata/study_notes.md
column -ts $'\t' metadata/course_subset.tsv | less -S
column -ts $'\t' data/ena_manifest.tsv | less -S
```

學生應能回答：為什麼選這六個樣本、哪些欄位來自作者、為什麼 sample ID
需要正規化，以及為什麼六個樣本不能代表完整研究。

### 3.2 下載及驗證真實 FASTQ

下載在計算節點進行。script 會下載約 286 MB 的 ENA FASTQ、逐檔核對 ENA
MD5，並由固定 manifest 建立 samplesheet。課前實測（2026-09-23）約 5 分鐘完成；
ENA 伺服器偶爾會在傳輸中途斷線，script 會自動重試並從斷點續傳，`.err` 日誌中出現
`Will retry` 屬正常現象：

```bash
export NFCORE_ACCOUNT=GOV115088
export NFCORE_PARTITION=ngs62g

sbatch \
    --account="${NFCORE_ACCOUNT}" \
    --partition="${NFCORE_PARTITION}" \
    scripts/01_prepare_real_data.slurm
```

提交後記下 Job ID，只做一次狀態快照：

```bash
squeue -j '<JOB_ID>'
```

完成後檢查：

```bash
sacct -j '<JOB_ID>' \
    --format=JobID,JobName%24,Account,Partition,State,ExitCode,Elapsed,ReqMem,MaxRSS

column -ts $'\t' \
    "/work/${USER}/nfcore-ampliseq-course/metadata/samplesheet.tsv"
```

### 3.3 執行官方 test profile

`-profile test,singularity` 會載入 test 資料設定與 Singularity 執行環境；
國網 `site.config` 與本章 `config/nano4.config` 才負責將各個 nf-core process 送進 Slurm。
pipeline 與容器都來自國網離線環境，只有 test profile 的小型輸入與 taxonomy 會從網路下載。
課前實測（2026-09-23）約 28 分鐘完成，共 125 個 Slurm 子工作、0 個失敗（實際時間視排隊狀況而定）。最後顯示 `Pipeline completed successfully` 即為成功。

```bash
export NFCORE_ACCOUNT=GOV115088
export NFCORE_PARTITION=ngs62g

sbatch \
    --account="${NFCORE_ACCOUNT}" \
    --partition="${NFCORE_PARTITION}" \
    --export=ALL,NFCORE_ACCOUNT,NFCORE_PARTITION \
    scripts/02_run_official_test.slurm
```

這裡有兩層 Slurm 工作：

```text
Slurm driver job
    └── Nextflow
          ├── Slurm process: FastQC
          ├── Slurm process: Cutadapt
          ├── Slurm process: DADA2
          └── Slurm process: QIIME2 / MultiQC / reports
```

主控 Nextflow 也放在 Slurm 作業中（同樣依 `ngs62g` 官方規格 8 核心 / 62 GB），避免在登入節點長時間執行 Java 程序。
執行時 `squeue` 的畫面與各欄位意思，請見 [0.6 執行時你會看到什麼？](#06-執行時你會看到什麼)。

### 3.4 執行真實資料

只有在下載工作和官方 test 都成功後才提交。官方 test 約需 28 分鐘，若期間重新開過終端機，請先重新設定變數：

```bash
cd "$HOME/Nano4-Docs/07-nfcore-ampliseq-case-study"
export NFCORE_ACCOUNT=GOV115088
export NFCORE_PARTITION=ngs62g

sbatch \
    --account="${NFCORE_ACCOUNT}" \
    --partition="${NFCORE_PARTITION}" \
    --export=ALL,NFCORE_ACCOUNT,NFCORE_PARTITION \
    scripts/03_run_real_data.slurm
```

正式作業固定：

- nf-core/ampliseq `2.18.0`；
- 研究原始 515F/806R primer；
- 作者原始 metadata 與 treatment；
- DADA2 taxonomy `silva=138.2`（國網離線資料只有 SILVA 138 的 QIIME 2 格式與 GTDB，因此由計算節點下載一次到 `cache/taxonomy/`）；
- `-resume` 支援安全續跑；
- container、taxonomy 與 work cache 位於 `/work/${USER}`。

課前實測（2026-09-23）約 1 小時 40 分鐘完成，共 79 個 Slurm 子工作、0 個失敗。其中 QIIME 2 稀釋曲線（`QIIME2_ALPHARAREFACTION`）一個步驟就佔約 1 小時 30 分鐘，這段時間 `squeue` 只會看到它一個子作業在跑，log 也不再更新，屬正常現象，不是卡住。

> [!NOTE]
> nf-core/ampliseq 2.18.0 使用 `--FW_primer` 與 `--RV_primer`。開發版文件可能
> 顯示新版名稱；因本課固定 2.18.0 版，參數也必須依 2.18.0 文件與 schema。

## 4. 第二階段：讓 AI Agent 重做

人工版完成後才使用 [`prompts/ai_reproduce.md`](./prompts/ai_reproduce.md)。這份 prompt 會要求 AI 使用 `nfcore-ampliseq-nano4` 等 Skills；若尚未在第 06 章安裝，請先執行：

```bash
cd "$HOME/Nano4-Docs/06-skills-hub"
bash sync_skills.sh
```

AI
必須先讀取研究資料、提出計畫並完成 live preflight，在學生確認 account、
partition、資源與實際命令前不得提交工作。

AI 版應使用獨立位置，例如：

```text
/work/${USER}/nfcore-ampliseq-course-ai/
```

不要讓 AI 覆寫人工版。兩版完成後比較：

```bash
# samplesheet：人工版 vs AI 版
diff -u /work/${USER}/nfcore-ampliseq-course/metadata/samplesheet.tsv \
        /work/${USER}/nfcore-ampliseq-course-ai/metadata/samplesheet.tsv

# Nextflow 設定：課程提供的 config vs AI 產生的 config（路徑依 AI 實際輸出調整）
diff -u "$HOME/Nano4-Docs/07-nfcore-ampliseq-case-study/config/nano4.config" \
        /work/${USER}/nfcore-ampliseq-course-ai/nano4.config
```

比較重點：

- accessions、MD5 與配對是否一致；
- sample ID mapping 是否可逆；
- metadata 是否被 AI 擅自改組；
- pipeline、primer、taxonomy 是否固定；
- `singularity` profile 與 `slurm` executor 是否都有設定；
- cache、work、results 是否正確放在 `/work`；
- AI 是否先跑 test、先 preflight、取得確認後才提交；
- AI 版與人工版的結果和資源需求是否有實質差異。

## 5. 第三階段：查看與解讀結果

### 5.1 還沒跑完真實資料？先看講師的示範結果

真實資料（3.4）約需 1 小時 40 分鐘。課堂上請先下載講師事先跑好的結果，在自己的電腦用瀏覽器打開即可，不需要連上 Nano4：

📦 **[第 07 章示範結果（GitHub Release）](https://github.com/gemini960114/Nano4-Docs/releases/tag/ampliseq-demo-2026-09-23)**

| 檔案 | 內容 | 建議 |
| :--- | :--- | :--- |
| [`ampliseq_summary_report.html`](https://github.com/gemini960114/Nano4-Docs/releases/download/ampliseq-demo-2026-09-23/ampliseq_summary_report.html)（8.5 MB） | nf-core 總結報告：每個步驟保留的 reads、分類結果、多樣性 | **先看這份** |
| [`ampliseq_multiqc_report.html`](https://github.com/gemini960114/Nano4-Docs/releases/download/ampliseq-demo-2026-09-23/ampliseq_multiqc_report.html)（2.6 MB） | 原始 reads 與 Cutadapt 品質報告 | 第二份 |
| `overall_summary.tsv`、`ASV_table.tsv`、`ASV_tax_species.silva_138_2.tsv`、`rel-table-6_genus.tsv` | 主要結果表格 | 可用 Excel 開啟 |
| `ampliseq_results-real.tar.gz`（17 MB） | 完整結果，保留資料夾結構 | 想對照下方閱讀順序時再下載 |

> 報告中的執行路徑已將講師帳號改寫為 `USER`。示範結果與你自己跑出來的結果應該非常接近；若差很多，先回頭檢查 samplesheet 與 primer。

**看報告時回答這幾個問題**（答案為講師 2026-09-23 的實測結果）：

1. 6 個樣本分別有多少 reads 通過 Cutadapt 與 DADA2？最後得到幾個 ASV？
2. 門（phylum）與屬（genus）層級最多的是哪些？
3. Control 與 MSEW 的 Shannon 多樣性看起來有差嗎？
4. Beta diversity 的 PERMANOVA p 值是多少？可以說兩組微生物相不同嗎？

<details>
<summary><b>參考答案（先自己作答再展開）</b></summary>

1. 每個樣本約 12–30 萬條 raw reads，Cutadapt 保留約 88–97%；經過 DADA2 過濾、去噪、合併與去除嵌合體後，每個樣本剩約 9–24 萬條，全部樣本共得到 **125 個 ASV**（見 `overall_summary.tsv`）。
2. 幾乎全部是 **Bacillota**（約 99.7%）；屬層級以 **Lactobacillus**（約 87%）與 **Staphylococcus**（約 12%）為主，符合出生第 10 天（PD10）幼鼠腸道的特徵。
3. MSEW 組的 Shannon 值（約 0.43–1.03）整體比 Control 組（約 0.13–0.54）高，但每組只有 3 個樣本，差異可能只是個體變異。
4. Bray-Curtis 的 PERMANOVA **p = 0.291**，沒有統計顯著。即使 PCoA 圖上兩組看起來有分開，也不代表統計上不同；樣本數太少，不能據此宣稱重現論文結論。

</details>

### 5.2 檢查你自己跑出來的結果

真實資料（3.4）完成後，先列出主要報告與表格（此 script 只檢查 `results-real`）：

```bash
bash scripts/04_inspect_results.sh
```

HTML 報告可用第 04 章 §6 的方式開啟，或在 VS Code / Antigravity 檔案總管對檔案按右鍵下載到自己的電腦。

閱讀順序：

1. `pipeline_info/`：確認版本、參數、process 狀態與執行時間。
2. `multiqc/multiqc_report.html`：查看 raw-read QC；這裡顯示的是未修剪 reads。
3. `cutadapt/`：確認 primer 找到率與 retained reads，避免 primer 填錯卻繼續分析。
4. `dada2/`：追蹤 filtering、denoising、merging、chimera removal 與 ASV 數量。
5. `qiime2/abundance_tables/`：查看 feature table 與 taxa abundance。
6. `qiime2/diversity/`：查看 alpha/beta diversity 與 PCoA。
7. `seff <JOB_ID>`：檢查 driver job；再用 `sacct` 查看 Nextflow 子工作資源。

PCoA 是視覺化，不等於統計顯著。本章只有六個樣本，不能宣稱重現完整論文，
也不能忽略 litter、dam 與其他研究設計因素。

## 6. 第四階段：封裝並使用 Skill

本課程已提供：

```text
06-skills-hub/nfcore-ampliseq-nano4/
```

同步後，AI 可在 nf-core/ampliseq 的 Nano4 資料準備、test、正式執行與結果
檢查任務中自動載入它：

```bash
cd "$HOME/Nano4-Docs/06-skills-hub"
bash sync_skills.sh
```

Skill 不會把本章六個樣本硬編碼成所有研究的標準。它封裝的是可重用規則：

```text
資料溯源與 MD5
→ primer 與實際 reads 核對
→ sample/metadata 驗證
→ Nano4 live preflight
→ 官方 test profile
→ 使用者確認後正式提交
→ 結果與資源檢查
```

## 7. 繳交內容

```text
1. manual-run-summary.md
   人工操作、Job IDs、版本、參數與主要結果

2. ai-run-summary.md
   AI 的計畫、人工核准點、Job IDs 與主要結果

3. comparison-report.md
   人工版和 AI 版的差異、錯誤與風險

4. skill-review.md
   哪些規則適合封裝、哪些生物學判斷仍需人工負責

5. my-nano4-slurm/SKILL.md
   第 03 章做的 skill，含第 06 章比較後補強的內容
```

完成本章後，學生不只是「會跑 nf-core」，而是能理解、監督、驗證並重用
一套真實 HPC 生物資訊 workflow。

---

👈 **回到**：[課程總綱與學習地圖](../README.md)
