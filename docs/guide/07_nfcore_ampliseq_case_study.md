# 第 07 章：nf-core/ampliseq 真實案例——手動操作、AI 重做與 Skill 封裝

本章是前六章的整合實戰。學生先親手完成一次公開 paired-end 16S 分析，
再讓 AI Agent 使用相同輸入重做，最後比較兩者並將可靠方法封裝為 Skill。

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
> 官方 test profile 只驗證 Slurm、Nextflow、Singularity 與 nf-core 能否運作；
> 真實資料才用於學習資料溯源與結果解讀。兩者不能互相取代。

> [!NOTE]
> 本章實作檔案位於教材 repository。若重新開啟終端機，先回到教材根目錄：
>
> ```bash
> cd "$HOME/Nano4-Docs"
> ```

## 1. 兩套資料與不同目的

### 官方 test profile

本章固定 nf-core/ampliseq `2.18.0`，先以 `-profile test,singularity`
確認：

- Nextflow 可以啟動；
- pipeline processes 確實透過 Slurm 執行；
- Singularity/Apptainer 能自動取得並執行所需 image；
- `/work/${USER}` 的 container cache 與 work directory 可由各節點存取；
- pipeline 能正常完成。

test profile 是軟體與基礎設施測試，不是正式研究 cohort，不應解讀其中的
分組、PCoA 或差異分析。

### 公開研究 PRJNA605008

真實案例來自論文 [*Early life stress in mice alters gut microbiota independent
of maternal microbiota inheritance*](https://doi.org/10.1152/ajpregu.00072.2020)、
[BioProject PRJNA605008](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA605008/)
與作者公開的 [`mapping_file.txt`](https://raw.githubusercontent.com/KMKemp/ELS/main/mapping_file.txt)。

為控制課堂下載與運算時間，選用同為 `exp1`、`PD10`、`MALE` 的六個原始
ENA runs，每組來自三個不同 litter：

| Pipeline ID | 原始 SampleID | Treatment | Litter | BioSample | Run |
| --- | --- | --- | --- | --- | --- |
| `C_L1_03` | `C-L1-03` | Control | `CONT-L1` | `SAMN14007776` | `SRR11028771` |
| `C_L2_03` | `C-L2-03` | Control | `CONT-L2` | `SAMN14007781` | `SRR11028740` |
| `C_L3_04` | `C-L3-04` | Control | `CONT-L3` | `SAMN14007789` | `SRR11028776` |
| `M_L1_03` | `M-L1-03` | MSEW | `MSEW-L1` | `SAMN14007807` | `SRR11028732` |
| `M_L2_03` | `M-L2-03` | MSEW | `MSEW-L2` | `SAMN14007818` | `SRR11028720` |
| `M_L3_03` | `M-L3-03` | MSEW | `MSEW-L3` | `SAMN14007827` | `SRR11028758` |

Control/MSEW、litter、dam、sex 與時間點都直接來自作者 metadata，沒有為了
教學自行創造分組。nf-core/ampliseq 2.18.0 不接受 sample ID 中的連字號，
因此 pipeline ID 只做可逆的 `- → _` 正規化，metadata 仍保留原始 ID。

研究使用並且 raw reads 實際保留的 primer 為：

```text
515F  GTGYCAGCMGCCGCGGTAA
806R  GGACTACNVGGGTWTCTAAT
```

## 2. 檔案與 WekaFS 目錄

教材原始檔位於：

```text
07-nfcore-ampliseq-case-study/
├── config/nano4.config
├── data/ena_manifest.tsv
├── metadata/
│   ├── course_subset.tsv
│   └── study_notes.md
├── prompts/
└── scripts/
```

約 286 MB FASTQ、container、taxonomy 與 Nextflow work 都寫到：

```text
/work/${USER}/nfcore-ampliseq-course/
├── data/
├── metadata/
├── cache/{nextflow,singularity,singularity-runtime,taxonomy}/
├── provenance/
├── results-test/
├── results-real/
├── work-test/
└── work-real/
```


> [!WARNING]
> `/work/${USER}/nfcore-ampliseq-course/` 是本案例的**短期運算工作區**，不是永久保存位置，也沒有備份。學生完成分析後，至少要保留 `data/` 的來源紀錄、`metadata/`、`provenance/`、pipeline 版本／命令、Slurm Job ID 與必要的 `results-*`；再依 GP1 官方規範移到長期儲存或核准的備份位置。先用 `hfsquota` 確認配額，避免 FASTQ、container cache 與 Nextflow work 佔滿 `/work`。

## 3. 第一階段：學生手動操作

> [!IMPORTANT]
> **本章只使用 CPU，不申請 GPU。** 官方 GP1 說明列出 CPU、GPU 與大記憶體節點；本次 nf-core/ampliseq
> 案例使用 GP1 CPU 服務與 NGS CPU partition（通常可從 `ngs32g` 或 `ngs62g` 開始），
> 不使用 `ngs1gpu`～`ngs8gpu`，也不在命令列加入 `--gres=gpu`。
> 若使用 GP1 核心設施，請先依官方流程加入可用服務計畫；實際 account 仍以你的
> Slurm association、`wallet` 與 preflight 結果為準。

### 3.1 Preflight

```bash
hostname
wallet
nextflow -version
singularity --version || apptainer --version

bash .agents/skills/nano4-slurm-operations/scripts/slurm-preflight.sh \
    --project '<PROJECT_ID>' \
    --partition '<PARTITION>'
```

`ngs62g` 只是常見的生醫 CPU 候選；必須以當天 wallet、association 與
partition policy 為準。

### 3.2 下載真實資料並核對 MD5

```bash
cd 07-nfcore-ampliseq-case-study

sbatch \
    --account='<PROJECT_ID>' \
    --partition='<PARTITION>' \
    scripts/01_prepare_real_data.slurm
```

script 會從固定 ENA manifest 下載 paired FASTQ、檢查 ENA MD5，並產生含
絕對路徑的 `samplesheet.tsv`。下載不在登入節點執行。

### 3.3 先執行官方 test profile

```bash
export NFCORE_ACCOUNT='<PROJECT_ID>'
export NFCORE_PARTITION='<PARTITION>'

sbatch \
    --account="${NFCORE_ACCOUNT}" \
    --partition="${NFCORE_PARTITION}" \
    --export=ALL,NFCORE_ACCOUNT,NFCORE_PARTITION \
    scripts/02_run_official_test.slurm
```

`-profile singularity` 只負責容器；`config/nano4.config` 才設定
`executor = slurm`、queue、account 傳遞與資源上限。Nextflow driver 本身也
放入一個小型 Slurm allocation，避免登入節點長時間執行 Java process。

### 3.4 執行真實資料

只有下載與 test 成功後才提交：

```bash
sbatch \
    --account="${NFCORE_ACCOUNT}" \
    --partition="${NFCORE_PARTITION}" \
    --export=ALL,NFCORE_ACCOUNT,NFCORE_PARTITION \
    scripts/03_run_real_data.slurm
```

正式分析固定：

- nf-core/ampliseq `2.18.0`；
- 作者使用的 515F/806R；
- 作者原始 Control/MSEW metadata；
- `--dada_ref_taxonomy 'silva=138.2'`；
- shared taxonomy/container cache；
- `-resume`。

> [!NOTE]
> 2.18.0 使用 `--FW_primer` 與 `--RV_primer`。參數名稱必須跟著固定的
> pipeline release，而不是混用開發版文件。

## 4. 第二階段：AI Agent 重做

人工版完成後，才把
[`ai_reproduce.md`](https://github.com/gemini960114/Nano4-Docs/blob/main/07-nfcore-ampliseq-case-study/prompts/ai_reproduce.md)
交給 AI。AI 版必須使用獨立的 `/work/${USER}/nfcore-ampliseq-course-ai/`，
不得覆寫人工結果。

AI 必須：

1. 先讀研究來源、manifest 與 metadata；
2. 核對 primer 與 reads；
3. 執行 live preflight；
4. 顯示 account、partition、資源與命令；
5. 等學生明確核准後才能提交；
6. 先跑 test，再跑真實資料；
7. 回報 Job ID，不使用輪詢迴圈。

兩版完成後比較 samplesheet、config、參數、結果與 `seff`，找出 AI 的正確
改進、無根據假設與潛在風險。

## 5. 第三階段：查看結果

```bash
bash scripts/04_inspect_results.sh
```

依序閱讀：

1. `pipeline_info/`：版本、命令、軟體與 process 狀態。
2. `multiqc/`：raw-read QC。
3. `cutadapt/`：primer 找到率與 retained reads。
4. `dada2/`：filtering、denoising、merging、chimera 與 ASV。
5. `qiime2/abundance_tables/`：feature/taxa abundance。
6. `qiime2/diversity/`：alpha、beta diversity 與 PCoA。
7. `sacct`、`seff`：資源與執行效率。

PCoA 分離不等於統計顯著。本章六個樣本是教學子集，不能宣稱重現完整
論文，也不能忽略 litter、dam 與 compositional-data 限制。

## 6. 封裝為 Skill

本章新增 `06-skills-hub/nfcore-ampliseq-nano4/`，封裝的是通用判斷流程，
不是硬編碼本章六個樣本：

```text
資料溯源與 checksum
→ primer/read 核對
→ metadata 驗證
→ Nano4 live preflight
→ test profile
→ 人工核准後正式提交
→ 結果與資源檢查
```

安裝方式：

```bash
cd 06-skills-hub
bash sync_skills.sh
```

## 7. 繳交成果

- `manual-run-summary.md`：人工版 Job IDs、版本、參數與結果。
- `ai-run-summary.md`：AI 計畫、核准點、Job IDs 與結果。
- `comparison-report.md`：人工版與 AI 版的實質差異及風險。
- `skill-review.md`：適合自動化的規則及仍需人工負責的生物學判斷。

完成本章後，學生不只會跑 nf-core，也能理解、監督、驗證並重用一套真實
HPC 生物資訊 workflow。
