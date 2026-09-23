# Nano4 GP1 生醫 HPC 課程規劃（講師版）

> 對象：授課講師與助教
> 計畫：`GOV115088`（國網生技醫藥高效能運算推廣與應用計畫），CPU-only，所有 Slurm 作業使用 `ngs62g`，每個作業固定 `-c 8 --mem=62G`
> 線上講義：<https://gemini960114.github.io/Nano4-Docs/>

## 1. 課程總覽

| 場次 | 章節 | 時間 | 學員結束時能做到 |
| :--- | :--- | :---: | :--- |
| **第一堂：連線與 AI Agent** | 第 01 章（精簡）<br>第 02 章 | 3 小時 | 用 Antigravity 連上 Nano4（透過 ssh-proxy 只認證一次），裝上三個 AI Agent 並比較回答；看過同一個 FastQC / MultiQC 作業「手動 `sbatch`」與「一句自然語言」兩種送法 |
| **第二堂：Slurm 與我的 skill** | 第 03 章<br>第 04 章 | 3 小時 | 親手送出標準、陣列、相依作業並用 `seff` 檢查；用自然語言請 Agent 多輪完成同樣的工作並糾正它；把經驗存成自己的 skill `my-nano4-slurm`，再用它完成 FASTQ 質控並讀懂報告 |
| **第三堂：進階與真實案例** | 第 05 章<br>第 06 章<br>第 07 章 | 3 小時 | 讓 Agent 把流程改寫成離線與外網直連兩種 Slurm 管線；比較自己的 skill 與課程 Skills 並補強；看懂 nf-core/ampliseq 官方測試與真實 16S 結果 |

設計原則：

- **重點是請 AI Agent 協助完成生醫分析，而不是讓學員一直打困難的指令。** 每個主題都先讓學員親手做一次（知道 Agent 該做什麼），再用自然語言請 Agent 做；學員的角色是確認 Agent 的計畫與結果。
- **學員自己做出 skill 是這門課最有價值的產出**，第二堂留完整時間做；第三堂再拿自己的 skill 和課程 Skills 比較，前後銜接。
- 每堂都留有處理連線問題的緩衝（開場重新連線 10 分鐘、中場休息時助教處理卡住的學員），不會因為幾位學員卡住就拖到整班。
- 三個 Agent：Antigravity 內建 Agent（Google 帳號即可）、Codex（`openai.chatgpt`，需 ChatGPT 帳號）、Claude Code（`anthropic.claude-code`，需 Claude 帳號）。**只用 Antigravity 內建 Agent 也能完成所有練習**。
- 第 07 章的 pipeline 需要長時間執行（官方測試實測約 28 分鐘），第三堂一開始就送出，等待時上第 05、06 章。

---

## 2. 課前準備

### 2.1 學員（課前寄出，第一堂開始前完成）

| # | 項目 | 參考 | 檢核方式 |
| :---: | :--- | :--- | :--- |
| 1 | 註冊 iService 帳號，並由講師加入計畫 `GOV115088` | 第 01 章 §2 | iService 計畫成員清單中有自己 |
| 2 | 手機安裝 IDExpert App 並完成 2FA 綁定 | 第 01 章 §2 | 能收到推播或產生 OTP |
| 3 | 用終端機 `ssh 帳號@nano4.nchc.org.tw` **登入一次**（系統才會建立 `$HOME`） | 第 01 章 §3 | 看到 `[帳號@25a-lgn0X ~]$` 提示字元 |
| 4 | 安裝 Google Antigravity，並以 Google 帳號登入 | 第 02 章 §2 步驟 A | 能開啟 Antigravity 與 Agent 面板 |
| 5 | 下載 ssh-proxy 執行檔（Windows / macOS Apple Silicon / Linux） | 第 02 章 §2 步驟 E | 檔案已存在電腦中 |
| 6 | （選做）準備 ChatGPT 帳號（Codex）或 Claude 帳號（Claude Code） | 第 02 章 §3 | 能在瀏覽器登入 chatgpt.com 或 claude.ai |

### 2.2 講師 / 助教

| 時間點 | 項目 | 說明 |
| :--- | :--- | :--- |
| 課前一週 | 確認所有學員已加入 `GOV115088` | 用學員帳號執行 `sbatch --test-only -A GOV115088 -p ngs62g -c 8 --mem=62G --wrap true`，出現 `to start at` 即代表帳號與分區可用 |
| 課前一週 | 確認計畫錢包額度 | `wallet GOV115088` |
| 課前一天 | 講師帳號完整跑過當堂所有練習 | 包含第 02 章練習 6 的自然語言派送、第 03 章 Lab 10–11，三個 Agent 各試一次 |
| 課前一天 | 確認兩個 Agent 擴充套件可從 Antigravity 安裝到遠端 | Antigravity 使用 Open VSX 市集；2026-09-23 確認可取得 `anthropic.claude-code` 2.1.280 與 `openai.chatgpt`，登入節點也連得到兩家的 API |
| 課前一天 | 確認 `ngs62g` 空閒狀況 | `sinfo -p ngs62g -o "%C"`，顯示「已用/空閒/其他/總數」核心 |
| 第三堂前 | 確認第 07 章 `config/nano4.config` 的 `queueSize = 5`（見 §6） | 已於 2026-09-23 調整並實測 |
| 第三堂前 | 確認第 07 章示範結果可下載 | [GitHub Release `ampliseq-demo-2026-09-23`](https://github.com/gemini960114/Nano4-Docs/releases/tag/ampliseq-demo-2026-09-23)：兩份 HTML 報告、4 個結果表格與完整結果壓縮檔；報告中的帳號已改寫為 `USER` |
| 每堂課 | 準備一台可投影的電腦示範 Windows 與 macOS 兩種 ssh-proxy 啟動方式 | 最常見的問題 |

---

## 3. 第一堂：連線與 AI Agent（第 01–02 章，3 小時）

| 時間 | 單元 | 講義位置 | 學員實作 | 講師重點 / 常見狀況 |
| :---: | :--- | :--- | :--- | :--- |
| 0:00–0:15 | 開場、確認課前準備 | 課程總綱 | 舉手確認課前作業 1–6 完成情況 | 未完成 2FA 綁定者請助教一對一協助 |
| 0:15–0:25 | Nano4 與 GP1 架構：登入節點、計算節點、DTN、`/work` | 第 01 章 §1 | — | 強調 GP1 生醫節點是 Nano4 的一部分；本課程只用 `ngs62g` |
| 0:25–0:45 | SSH 登入與 2FA、設定 `~/.ssh/config`、取得教材 | 第 01 章 §3、§4 | 用 `ssh nano4` 登入；`git clone` 課程教材到 `$HOME/Nano4-Docs` | Windows 需確認已安裝 OpenSSH Client；推播沒收到時改選 OTP |
| 0:45–1:00 | 儲存空間與模組 | 第 01 章 §7、§8 | 第 01 章**練習 1** 環境健檢、**練習 3** 載入生醫模組 | 大型資料放 `/work/$USER`；計算節點沒有 Java，FastQC 要和 `biology/JDK` 一起載入（練習 6 的 Agent 常漏掉這點） |
| 1:00–1:25 | Antigravity Remote-SSH 連線 | 第 02 章 §1、§2 步驟 A–D | 第 02 章**練習 1** 開啟遠端工作區 | 學員會體驗到「每開一次資料夾就要再認證一次」，作為下一段的動機 |
| 1:25–1:35 | 休息 | | | 助教處理前面卡住的學員 |
| 1:35–2:00 | **ssh-proxy：只認證一次** | 第 02 章 §2 步驟 E | **練習 2** | 最容易出錯的一段。確認 `User` 已改成自己的帳號、proxy 視窗保持開啟；啟動時加 `--max-lifetime 10h` |
| 2:00–2:25 | **裝上三個 AI Agent**、`AGENTS.md` | 第 02 章 §3–§5 | **練習 3** 安裝擴充套件、登入、打招呼 | 沒有 ChatGPT / Claude 帳號的學員只用 Antigravity 內建 Agent；工作資料夾要開 `$HOME/Nano4-Docs`，Agent 才讀得到規則（Antigravity 讀 `.agents/rules/nano4.md`） |
| 2:25–2:40 | 三個 Agent 比較、人工驗證 | 第 02 章 §6 | **練習 4**、**練習 5** | 請一兩位學員分享 Agent 的錯誤建議（例如把 `--mem` 調小）；`--test-only` 不檢查規格 |
| 2:40–3:00 | **結尾示範：手動 vs 自然語言** | 第 02 章練習 6 | **練習 6**（講師示範，學員可跟做） | 先手動 `sbatch day1_fastqc_multiqc.slurm`（約 10 秒），再用一句話請 Agent 做同一件事；帶全班逐項對照比較表。提醒：下課前在 proxy 視窗按 `Ctrl+C` |

**時間不夠時可略過（改為課後自學）**：第 01 章 §5 DTN 傳檔、§6 T3 搬遷、§9 Apptainer、§10 `uv`、練習 2、4、5、6；第 02 章 §7 session 清理；練習 4 只用一個 Agent。

**有多的時間可加入**：第 01 章**練習 6** `salloc` 互動節點；練習 6 B 換另一個 Agent 再做一次，比較兩個 Agent 的腳本。

**第一堂結束檢核點**：每位學員都能 (1) 透過 `nano4-proxy` 用 Antigravity 開啟 `/work/<帳號>` 而不再輸入 OTP，(2) 至少一個 Agent 能說出 `GOV115088`、`ngs62g` 與 `-c 8 --mem=62G`，(3) 執行 `sacct` 查得到練習 6 的作業。

---

## 4. 第二堂：Slurm 與我的 skill（第 03–04 章，3 小時）

| 時間 | 單元 | 講義位置 | 學員實作 | 講師重點 / 常見狀況 |
| :---: | :--- | :--- | :--- | :--- |
| 0:00–0:10 | 複習、重新連線 | 第 02 章 §2 步驟 E | 啟動 ssh-proxy、連上 `nano4-proxy` | 先確認全班都連上再開始 |
| 0:10–0:30 | 為什麼需要 Slurm、`ngs62g` 官方規格、`#SBATCH` 參數 | 第 03 章 §1–§4 | **Lab 1**（講師帶過）、**Lab 2** 提交標準 CPU 作業 | 用第一堂練習 6 的 `day1_fastqc_multiqc.slurm` 逐行講解；`ngs62g` 一律 `-c 8 --mem=62G`；日誌用 `%x-%j.out` |
| 0:30–0:50 | 陣列作業與相依作業 | 第 03 章 §5 A–B | **Lab 4** 陣列作業；**Lab 5** 相依流水線 | 作業約 17 秒就跑完，`squeue` 不一定看得到；用 `sacct -j <JOB_ID> -X -o JobID,Start,End` 看開始時間分成 4、4、2 三批，即可看出 `%4` 的效果 |
| 0:50–1:10 | **自己改寫陣列作業** | 第 03 章 Lab 8 | **Lab 8** 一個子任務處理一個 FASTQ 樣本 | 常見錯誤：陣列索引忘了 `-1`、`--array` 沒改成 `1-4`。卡住可對照 `templates/array_fastq.slurm` |
| 1:10–1:20 | 效能分析 | 第 03 章 §6 | **Lab 7** `seff`（Lab 6 `salloc` 選做） | 說明 exit 137 = 記憶體不足 |
| 1:20–1:30 | 休息 | | | |
| 1:30–2:10 | **讓 AI Agent 接手：多輪對話** | 第 03 章 §9 Lab 10 | 執行 `setup_agent_workspace.sh`，在 `/work/<帳號>/slurm_lab` 依序輸入四輪 prompt，填寫檢查表 | 重點是「用說的糾正 Agent」，不要自己改腳本。第 4 輪故意要求 `--mem=16G`，正確反應是拒絕；照做的 Agent 正好是教材 |
| 2:10–2:30 | **存成我的 skill** | 第 03 章 Lab 11 | 請 Agent 寫 `~/.agents/skills/my-nano4-slurm/`；執行 `install_my_skill.sh`；換另一個 Agent 開新對話驗收 | 檢查 SKILL.md 有沒有寫進 Lab 10 被糾正的錯誤；三個 Agent 都要開新對話才會讀到 skill |
| 2:30–2:55 | **用我的 skill 做質控並讀懂報告** | 第 04 章 §1、§2、§6、§7 | 用 `my-nano4-slurm` 請 Agent 跑 FastQC / MultiQC；開啟報告，回答 §7 的 5 個問題並和 Agent 的解讀比對 | 答案見本節下方「第 04 章 §7 參考答案」；Agent 還犯錯時，請它把教訓補進 skill |
| 2:55–3:00 | 總結、預告第三堂 | | | 預告：第三堂拿自己的 skill 和課程 Skills 比較 |

**時間不夠時可略過**：第 03 章 Lab 1、Lab 5（改講師示範）、Lab 6、§5 C/E GPU 與跨節點內容、Lab 3（本來就跳過）；Lab 10 第 3 輪；第 04 章 §3 prompt 技巧、§5 對照組（第三堂 Lab 9 前再跑）。

**第二堂結束檢核點**：每位學員都能 (1) 完成 Lab 8，4 個日誌各自對應一個樣本，(2) `~/.agents/skills/my-nano4-slurm/SKILL.md` 存在，且 `install_my_skill.sh` 顯示兩個 ✅，(3) 在瀏覽器打開 Agent 產生的 MultiQC 報告。

**第 04 章 §7 參考答案**（依教材附的 4 個 FASTQ，2026-09-23 實測）：

| 題目 | 答案 |
| :--- | :--- |
| 1. reads 數與 GC 含量 | 每個樣本 1000 條 reads；GC 約 46–47% |
| 2. 長度範圍與警告 | 約 50–101 bp；長度不一致所以 Sequence Length Distribution 為 `warn` |
| 3. Per Base Sequence Quality | 4 個樣本都是 `pass`（綠色） |
| 4. 紅色項目 | `sample_04_R1` 的 Per Sequence GC Content 為 `fail`；其他 3 個樣本同一項為 `warn`；`sample_04_R1` 另有 Overrepresented Sequences `warn` |
| 5. 能不能用 | 不一定。1000 條 reads 太少，GC 分布容易有鋸齒；紅黃綠是提醒「去看這張圖」，不是自動淘汰 |

---

## 5. 第三堂：進階與真實案例（第 05–07 章，3 小時）

> 關鍵安排：**開課後 25 分鐘內就送出第 07 章的下載與官方測試**，讓 pipeline 在背景執行，同時上第 05、06 章。

| 時間 | 單元 | 講義位置 | 學員實作 | 講師重點 / 常見狀況 |
| :---: | :--- | :--- | :--- | :--- |
| 0:00–0:10 | 複習、重新連線 | | 啟動 ssh-proxy | |
| 0:10–0:25 | **先送出第 07 章作業** | 第 07 章 §2.2、§3.2、§3.3 | 執行先備檢查 → 送出 `01_prepare_real_data.slurm`（約 5 分鐘）→ 送出 `02_run_official_test.slurm`（約 28 分鐘） | 兩個作業都用 `NFCORE_ACCOUNT=GOV115088`、`NFCORE_PARTITION=ngs62g`；送出後就不用管它 |
| 0:25–0:35 | 第 07 章故事：一位研究生的一天 | 第 07 章 §0 | — | 用故事說明為什麼先跑 test、pipeline 做了哪些步驟；§0.6 教學員看懂 `squeue` 畫面 |
| 0:35–0:50 | Apptainer 容器 | 第 04 章 §5、第 03 章 §7、Lab 9 | 先執行第 04 章 §5 對照組（約 15 秒），再送出 **Lab 9** | 這次完全沒有 `module load`；nf-core 也是用容器運作。第一次拉取約 40 秒 |
| 0:50–1:15 | 讓 AI Agent 把流程改寫成 Slurm 管線 | 第 05 章 §1–§4 | **Case A** 離線運算模式 | 比較 Agent 產生的腳本與講義提供的腳本；Agent 已載入 `my-nano4-slurm`，看看它是否不需提醒就做對 |
| 1:15–1:25 | 休息 | | 執行一次 `squeue --me` 看第 07 章進度 | 外網直連模式（第 05 章 §5 Case B）改為講師示範或課後自學 |
| 1:25–1:45 | 安裝課程 Skills，並用 Skill 抓錯 | 第 06 章 | 執行 `sync_skills.sh`；完成「讓 Skill 抓出不合規的 Slurm 腳本」練習 | 重點：`sbatch --test-only` 會讓 `--mem=16G` 的錯誤腳本通過，`validate_slurm.sh` 才抓得到 |
| 1:45–2:05 | **比較我的 skill 與課程 Skills** | 第 06 章「練習：比較我的 skill 與課程 Skills」 | 請 Agent 列出比較表、挑兩項補進自己的 skill、重新 `install_my_skill.sh` | 引導討論：課程 Skills 有哪些檢查是 Lab 10 沒遇到的？學員的 skill 又記下了哪些課程沒寫的經驗？ |
| 2:05–2:15 | 檢查官方測試結果 | 第 07 章 §3.3 | 查看 log 最後的 `Pipeline completed successfully` | 若仍在跑，先講 §1 資料來源 |
| 2:15–2:50 | **講師示範：解讀 ampliseq 結果** | 第 07 章 §5.1、§4、§6 | 從 Release 下載 `ampliseq_summary_report.html` 與 `ampliseq_multiqc_report.html`，跟著講師回答 §5.1 的 4 個問題 | 真實資料（§3.4）需約 1 小時 40 分鐘，不在課堂上執行。重點：125 個 ASV、Lactobacillus 約 87%、PERMANOVA p = 0.291（不顯著）。最後示範請 Agent 解讀結果並封裝成 Skill（§4、§6） |
| 2:50–3:00 | 總結、說明繳交內容 | 第 07 章 §7 | — | 繳交內容加上自己的 `my-nano4-slurm/SKILL.md` |

**時間不夠時可略過**：Lab 9（改示範）；第 05 章 Case B（本來就改示範）；第 07 章 §3.4 真實資料（改由講師展示）、§4、§6（改為課後作業）。

**第三堂結束檢核點**：每位學員都能 (1) 說明 Agent 產生的 Slurm 腳本與講義版本的差異，(2) 讓 `validate_slurm.sh` 對三份練習腳本都顯示驗證通過，(3) 說出自己的 skill 從課程 Skills 補進了哪兩項，(4) 看到自己的 nf-core/ampliseq 官方測試顯示 `Pipeline completed successfully`。

**Lab 9 下載限制**：映像檔由每位學員自行從 Docker Hub 下載，講師不另外提供。Docker Hub 對未登入的下載次數有限制，全班同時下載時可能有人出現 `toomanyrequests`；請該學員等 10–15 分鐘後重新提交即可，下載成功的 `.sif` 會保留在學員自己的 `/work/<帳號>/apptainer_lab/`。可請學員分兩批提交，降低同時下載的人數。

---

## 6. 資源容量與排隊注意事項

`ngs62g` 共有 13 個節點（`25a-cpn[01-10,16-18]`）、1,664 個核心。以 2026-09-23 晚間的空閒量（約 1,600 核心）估算，整個分區大約可同時執行 **200 個** 8 核心作業；每位使用者最多 120 個作業。以下以第一班 **20 位學員**估算：

| 練習 | 每位學員同時作業數 | 20 位學員合計 | 評估 |
| :--- | :---: | :---: | :--- |
| 第 02 章練習 6（手動 + Agent） | 1–2 | 20–40 | 沒問題 |
| 第 03 章 Lab 2 | 1 | 20 | 沒問題 |
| 第 03 章 Lab 4 陣列作業（`%4`） | 4 | 80 | 沒問題 |
| 第 03 章 Lab 8 陣列作業（`1-4`） | 4 | 80 | 沒問題 |
| 第 03 章 Lab 6 `salloc` | 1 | 20 | 沒問題；提醒用完 `exit` |
| 第 03 章 Lab 10 Agent 多輪操作 | 最多約 5（4 個陣列子任務 + 相依作業） | 約 100 | 沒問題；作業都在數秒內結束。留意 Agent 是否一次送出過多作業 |
| 第 04 章 §2 用 skill 做質控 | 1–2 | 20–40 | 沒問題 |
| 第 03 章 Lab 9 容器 | 1 | 20 | 運算沒問題；注意 Docker Hub 下載次數（見 §5「Lab 9 下載限制」） |
| 第 05 章 Case A / B | 1 | 20 | 沒問題 |
| 第 07 章官方測試（`queueSize = 5`） | 1 + 5 | 約 120 | 沒問題 |

建議：

- `07-nfcore-ampliseq-case-study/config/nano4.config` 的 `executor.queueSize` 已由 10 調為 5，實測官方測試時間不變（約 28 分鐘）。學員超過 30 人時，可再調低（例如 3），但官方測試會跑得更久。
- 第 07 章 §3.4 真實資料不要全班同時執行，改用講師事先跑好、放在 [GitHub Release `ampliseq-demo-2026-09-23`](https://github.com/gemini960114/Nano4-Docs/releases/tag/ampliseq-demo-2026-09-23) 的示範結果。

---

## 7. 實測時間參考（講師帳號，2026-09-23）

| 項目 | 實測時間 | 備註 |
| :--- | :---: | :--- |
| 第 02 章練習 6 手動 `day1_fastqc_multiqc.slurm` | 約 9 秒 | 4 個樣本各 1000 reads，FastQC + MultiQC |
| 第 01 章練習 5、第 03 章 Lab 2 | 約 5 秒 | 當天沒有排隊，送出後 1 秒內開始執行 |
| 第 03 章 Lab 4 陣列（10 個任務，`%4`） | 約 17 秒 | 分三批執行，可觀察到同時最多 4 個 |
| 第 03 章 Lab 5 三段相依流水線 | 約 17 秒 | 三段依序執行 |
| 第 03 章 Lab 8 陣列（4 個樣本） | 每個子任務約 1 秒 | 4 個樣本各 1000 reads |
| 第 03 章 Lab 9 容器 MultiQC | 第一次約 1 分鐘，之後約 15 秒 | 拉取 `multiqc/multiqc:v1.35`（約 350 MB）約 40 秒 |
| 第 04 章 §5 FastQC / MultiQC（登入節點） | 約 15 秒 | 4 個樣本各 1000 reads |
| 第 05 章 Case A / Case B | 約 10 秒 | 產生真實 MultiQC 報告 |
| 第 06 章 Skill 抓錯練習 | 數秒 | `validate_slurm.sh` 對三份腳本分別回傳 0、1、1 |
| 第 07 章 §3.2 下載資料 | 約 5 分鐘 | ENA 偶爾中途斷線，腳本會自動重試續傳 |
| 第 07 章 §3.3 官方測試 | 約 28 分鐘 | `queueSize = 5`：27 分 41 秒；`queueSize = 10`：27 分 06 秒。皆為 125 個子作業、0 個失敗 |
| 第 07 章 §3.4 真實資料 | 約 1 小時 40 分鐘 | 1 小時 41 分 05 秒，79 個子作業、0 個失敗；其中 QIIME 2 稀釋曲線一個步驟約 1 小時 30 分鐘 |

Agent 對話（第 02 章練習 6 B、第 03 章 Lab 10–11、第 04 章 §2）的時間取決於 Agent 回應速度與學員確認的次數，上表未列；請講師課前實際跑一次估算。

未採用的容器候選：`biobakery/humann:3.9` 映像檔約 941 MB，拉取需 9 分 25 秒（`humann_test` 186 項測試 40 秒通過），不適合整班同時拉取；quay.io 的 MultiQC 映像檔從 Nano4 下載速度很慢（10 分鐘以上），因此 Lab 9 改用 Docker Hub。
