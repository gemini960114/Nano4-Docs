# 第 07 章：nf-core/ampliseq 真實案例——手動操作、AI 重做與 Skill 封裝

本章是前六章的整合實戰。學生先親手完成一次公開 paired-end 16S
資料分析，再讓 AI Agent 使用相同輸入重做，最後比較兩者並把可靠流程
封裝成 `nfcore-ampliseq-nano4` Skill。

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

## 1. 本章使用的兩套資料

### 1.1 nf-core/ampliseq 官方 test profile

固定使用 nf-core/ampliseq `2.18.0` 的 `test` profile。該 profile 隨 pipeline
版本提供小型輸入與完整參數，適合確認：

- Nextflow 可以啟動；
- `executor = slurm` 確實提交子工作；
- Singularity/Apptainer 能取得及執行容器；
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

程式碼留在 Git repository，大型資料與 cache 全部寫入 WekaFS：

```text
/work/${USER}/nfcore-ampliseq-course/
├── data/                       # ENA raw FASTQ
├── metadata/
│   ├── samplesheet.tsv         # 腳本由 manifest 產生
│   └── metadata.tsv            # 作者 metadata 的課堂子集
├── cache/
│   ├── nextflow/
│   ├── singularity/
│   ├── singularity-runtime/
│   └── taxonomy/
├── provenance/
├── results-test/
├── results-real/
├── work-test/
└── work-real/
```

先確認環境，不要在登入節點直接啟動分析：

```bash
hostname
wallet
nextflow -version
singularity --version || apptainer --version
```

選定 `<PROJECT_ID>` 與 `<PARTITION>` 後執行唯讀 preflight：

```bash
bash .agents/skills/nano4-slurm-operations/scripts/slurm-preflight.sh \
    --project '<PROJECT_ID>' \
    --partition '<PARTITION>'
```

課堂的 CPU 生醫案例通常會評估 `ngs62g`，但實際授權、QoS 與分區狀態必須
以當天查詢結果為準，不可只照教材填值。

## 3. 第一階段：學生手動操作一次

### 3.1 閱讀資料來源

先閱讀以下三個檔案：

```bash
cd 07-nfcore-ampliseq-case-study
less metadata/study_notes.md
column -ts $'\t' metadata/course_subset.tsv | less -S
column -ts $'\t' data/ena_manifest.tsv | less -S
```

學生應能回答：為什麼選這六個樣本、哪些欄位來自作者、為什麼 sample ID
需要正規化，以及為什麼六個樣本不能代表完整研究。

### 3.2 下載及驗證真實 FASTQ

下載在計算節點進行。script 會下載約 286 MB 的 ENA FASTQ、逐檔核對 ENA
MD5，並由固定 manifest 建立 samplesheet：

```bash
sbatch \
    --account='<PROJECT_ID>' \
    --partition='<PARTITION>' \
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
`config/nano4.config` 才負責將各個 nf-core process 送進 Slurm。第一次執行時
Nextflow 會下載 pipeline、test data、taxonomy 與所需 container image，後續則
重用 `/work` cache。

```bash
export NFCORE_ACCOUNT='<PROJECT_ID>'
export NFCORE_PARTITION='<PARTITION>'

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

主控 Nextflow 也放在低資源 Slurm allocation 中，避免在登入節點維持長時間
Java process。

### 3.4 執行真實資料

只有在下載工作和官方 test 都成功後才提交：

```bash
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
- DADA2 taxonomy `silva=138.2`；
- `-resume` 支援安全續跑；
- container、taxonomy 與 work cache 位於 `/work/${USER}`。

> [!NOTE]
> nf-core/ampliseq 2.18.0 使用 `--FW_primer` 與 `--RV_primer`。開發版文件可能
> 顯示新版名稱；因本課固定 `-r 2.18.0`，參數也必須依 2.18.0 文件與 schema。

## 4. 第二階段：讓 AI Agent 重做

人工版完成後才使用 [`prompts/ai_reproduce.md`](./prompts/ai_reproduce.md)。AI
必須先讀取研究資料、提出計畫並完成 live preflight，在學生確認 account、
partition、資源與實際命令前不得提交工作。

AI 版應使用獨立位置，例如：

```text
/work/${USER}/nfcore-ampliseq-course-ai/
```

不要讓 AI 覆寫人工版。兩版完成後比較：

```bash
diff -u manual/samplesheet.tsv ai/samplesheet.tsv
diff -u manual/nano4.config ai/nano4.config
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

先列出主要報告與表格：

```bash
bash scripts/04_inspect_results.sh
```

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
cd 06-skills-hub
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
```

完成本章後，學生不只是「會跑 nf-core」，而是能理解、監督、驗證並重用
一套真實 HPC 生物資訊 workflow。
