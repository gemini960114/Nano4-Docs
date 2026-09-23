# 第 02 章：Antigravity Remote-SSH 與三個 AI Agent

歡迎來到第 02 章！在第 01 章中，您已經學會 SSH 登入、雙因子認證（2FA）、`/home` 與 `/work` 的分工，以及用 `module` 載入生醫工具。

本章的目的只有一個：**把 AI Agent 帶到 Nano4 上**。我們用以 VS Code 為基礎的 **Google Antigravity**，透過「Remote - SSH」連上 Nano4，再裝上 **Codex** 與 **Claude Code** 兩個擴充套件，加上 Antigravity 內建的 Agent，一共三個 Agent 可以隨時切換、對同一個問題比較回答。

有了 AI Agent，您不必背誦複雜的指令：用自然語言說出想完成的分析（例如「幫我檢查這 4 個定序樣本的品質」），由 Agent 撰寫 Slurm 腳本、送到計算節點、再用白話解讀結果；**您的工作是確認 Agent 的計畫與結果是否正確**。本章最後的示範會讓您親眼看到這件事。

> [!NOTE]
> 本章指令預設已完成第 01 章的 repository clone。若重新開啟終端機，先回到教材根目錄：
>
> ```bash
> cd "$HOME/Nano4-Docs"
> ```

## 📌 目錄 (Table of Contents)
- [1. 為什麼要用 Antigravity Remote-SSH？](#1-為什麼要用-antigravity-remote-ssh)
- [2. 連上 Nano4 (Antigravity / VS Code Remote-SSH)](#2-連上-nano4-antigravity--vs-code-remote-ssh)
- [3. 裝上三個 AI Agent](#3-裝上三個-ai-agent)
- [4. 三個 Agent 怎麼讀到 Nano4 的規則與 Skills](#4-三個-agent-怎麼讀到-nano4-的規則與-skills)
- [5. 超算專屬 AI Agent 治理守則：AGENTS.md](#5-超算專屬-ai-agent-治理守則agentsmd)
- [6. 動手實戰練習 (Hands-on Labs 1 ~ 6)](#6-動手實戰練習-hands-on-labs-1--6)
- [7. 多登入節點與 Agent session 清理](#7-多登入節點與-agent-session-清理)
- [8. 常見踩坑與連線排錯 (FAQ)](#8-常見踩坑與連線排錯-faq)

---

## 1. 為什麼要用 Antigravity Remote-SSH？

Remote-SSH 讓您的編輯器介面在個人電腦上執行，而檔案、終端機與 AI Agent 都在 Nano4 遠端執行：

1. **AI Agent 直接看得到遠端的檔案**：Agent 可以讀取 `/work` 裡的資料、撰寫 Slurm 腳本、執行 `sbatch` 並查看日誌，不必在網頁和終端機之間複製貼上。
2. **三個 Agent 可以自由切換**：Antigravity 內建 Agent、Codex、Claude Code 裝在同一個視窗，同一個問題可以請三個 Agent 各回答一次，互相比對。
3. **不用記 `vim`**：左側檔案總管用滑鼠開檔、存檔；按下 **``Ctrl + ` ``** 就有遠端終端機。
4. **直接在瀏覽器看報告**：MultiQC 等 HTML 報告可透過連接埠轉送或下載，在筆電瀏覽器打開。

```text
[ 學員個人電腦 (Windows / macOS / Linux) ]
   └─ Antigravity（本地介面、快捷鍵）
            │
            ▼ (加密 SSH 連線，使用第 01 章設定之 Host nano4)
[ 晶創26 (Nano4) 登入節點 (25a-lgn01~05) ]
   ├─ Antigravity Server（背景執行）
   ├─ 三個 AI Agent：Antigravity 內建 Agent、Codex、Claude Code
   ├─ WekaFS 高速工作區 (/work/$USER)
   └─ Slurm 指令 (sbatch, squeue, sacct) → 計算節點 ngs62g
```

> [!NOTE]
> Antigravity 以 VS Code 為基礎，本章步驟在 VS Code 上也完全相同，差別只在 VS Code 沒有內建 Agent。

---

## 2. 連上 Nano4 (Antigravity / VS Code Remote-SSH)

### 步驟 A：在個人電腦安裝 Antigravity
1. 前往 [Antigravity 官網](https://antigravity.google/) 下載安裝，並以 Google 帳號登入。
2. 在擴充套件面板（`Ctrl + Shift + X`，macOS 為 `Cmd + Shift + X`）確認已有 **Remote - SSH** 套件（若已內建則略過安裝）。
3. 首次連線時，Antigravity 會在 Nano4 的 `~/.antigravity-ide-server` 安裝伺服器端。

> [!TIP]
> **使用 VS Code**：到 [VS Code 官網](https://code.visualstudio.com/) 下載安裝，在擴充套件市場搜尋 **`Remote - SSH`**（Microsoft 官方發行）並安裝。首次連線會在 Nano4 的 `~/.vscode-server` 安裝伺服器端。VS Code 可以使用第 3 節的 Codex 與 Claude Code，但沒有 Antigravity 內建 Agent。

### 步驟 B：確認本機 SSH Config 已配置
在第 01 章中，我們已經在您本機的 `~/.ssh/config` 中加入了 `nano4` 設定：
```ssh-config
Host nano4
    HostName nano4.nchc.org.tw
    User your_account
    Port 22
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

### 步驟 C：一鍵連入 Nano4
1. 點擊視窗左下角的遠端按鈕（圖示 `><`），在上方彈出的選單中選擇：  
   👉 **`Connect to Host... (連線至主機...)`**
2. 清單中會自動列出 **`nano4`**，點擊選取它。
3. 系統會開啟新視窗並提示連線。在上方提示列選擇連線平台（選擇 **`Linux`**）。
4. 終端機或上方輸入框會彈出 2FA 選項：
   ```text
   Login method (1: Mobile APP OTP, 2: Mobile APP PUSH, 3: Email OTP): 
   ```
   輸入 **`2`** 按 Enter，解鎖手機在 **IDExpert App** 點擊「同意」；隨後輸入您的主機密碼。
5. 驗證通過後，左下角會顯示 **`SSH: nano4`**，表示您已成功連進晶創26！

### 步驟 D：開啟遠端工作區
1. 點擊左側選單的「檔案總管 (Explorer)」➔ 點擊 **Open Folder (開啟資料夾)**。
2. 在上方輸入框填入您的 WekaFS 高速工作區路徑：
   ```text
   /work/your_account
   ```
   （教材 repository 位於 `/home/your_account/Nano4-Docs`；本章練習 4、6 要讓 Agent 讀到教材裡的 `AGENTS.md`，屆時改用 File ➔ Open Folder 開啟這個資料夾。）
3. 按下確定，您就能在左側清單中看到所有遠端檔案與目錄！

### 步驟 E（強烈建議）：用 ssh-proxy 只做一次 2FA 認證

Nano4 的**每一條新 SSH 連線**都要輸入密碼與 OTP。Antigravity / VS Code 的 Remote-SSH 在「連線」、「Open Folder 選目錄」、「切換資料夾或重新載入視窗」時都會開新連線，所以同一堂課可能要認證好幾次。

[`ssh-proxy`](https://github.com/gemini960114/ssh-proxy) 是在**您個人電腦上**執行的小工具：它先用密碼 + OTP 連上 Nano4 並保持連線，再在本機 `127.0.0.1:2222` 開一個入口。之後 Antigravity 改連 `nano4-proxy`，所有連線都走這條已認證的通道，不必再輸入 OTP。

```text
Antigravity / VS Code / 終端機
        │  連 nano4-proxy（不需 OTP）
        ▼
127.0.0.1:2222   ← ssh-proxy（在您的電腦上執行，視窗保持開著）
        │  已完成密碼 + OTP 的連線
        ▼
nano4.nchc.org.tw:22
```

**1. 下載執行檔**（[Releases 頁面](https://github.com/gemini960114/ssh-proxy/releases/latest)，免安裝 Python）：

| 您的電腦 | 下載檔案 |
| :--- | :--- |
| Windows 10 / 11 | `ssh-proxy-windows-x64.exe` |
| macOS Apple Silicon (M1–M4) | `ssh-proxy-macos-arm64` |
| Linux x64 | `ssh-proxy-linux-x64` |

Intel Mac 沒有預先編譯的檔案，請依 ssh-proxy README 的「Run from Source with uv」方式執行。

**2. 在本機 `~/.ssh/config` 加入 proxy 專用的主機**（保留第 01 章的 `Host nano4`，ssh-proxy 會從它讀取主機名稱與帳號）：

```ssh-config
Host nano4-proxy
    HostName 127.0.0.1
    Port 2222
    User your_account
    # 本機 proxy 每次啟動都會產生新的暫時金鑰；這兩行只能用在這個 127.0.0.1 別名，
    # 絕對不要加到 nano4 或其他遠端主機
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel ERROR
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

**3. 啟動 proxy，完成一次認證**（在本機終端機 / PowerShell 執行，並讓這個視窗保持開著）：

```bash
# Windows (PowerShell)
.\ssh-proxy-windows-x64.exe nano4

# macOS Apple Silicon（第一次需加執行權限並解除下載隔離）
chmod +x ssh-proxy-macos-arm64
xattr -d com.apple.quarantine ssh-proxy-macos-arm64
./ssh-proxy-macos-arm64 nano4
```

- 第一次連線會顯示 Nano4 的主機金鑰指紋，確認後輸入完整的 `yes`；之後依提示輸入密碼與 OTP。
- 若之後出現 `REMOTE HOST IDENTIFICATION HAS CHANGED`，proxy 會在送出密碼前停止；請先向國網中心確認，不要直接刪除舊金鑰。

**4. 改連 `nano4-proxy`**：

- 終端機：`ssh nano4-proxy`，應直接進入 Nano4，不再要求 OTP。
- Antigravity / VS Code：`Connect to Host...` 時選 **`nano4-proxy`**（不是 `nano4`），之後 Open Folder、切換資料夾都不必再認證。

**5. 使用注意**

- 預設**沒有任何連線 60 分鐘**或**總執行 8 小時**後，proxy 會自動停止；整天的課程可在啟動時加上 `--max-lifetime 10h`。proxy 停止後 Antigravity 會斷線，重新啟動 proxy（再認證一次）並重新連線即可。
- 只在**自己的電腦**上使用：proxy 在執行期間，同一台電腦上的其他程式也能透過它連進您的帳號。使用共用電腦或離開座位前，請在 proxy 視窗按 `Ctrl+C` 停止。
- 若出現 `Address already in use`，表示已有另一個 proxy 在使用 2222 埠，請先關閉它。

---

## 3. 裝上三個 AI Agent

| Agent | 怎麼取得 | 需要的帳號 | 在哪裡開啟 |
| :--- | :--- | :--- | :--- |
| **Antigravity 內建 Agent** | Antigravity 內建，不需安裝 | Google 帳號（登入 Antigravity 時已完成） | Agent 面板 |
| **Codex** | 擴充套件 `openai.chatgpt` | ChatGPT 帳號 | 左側活動列的 Codex 圖示 |
| **Claude Code** | 擴充套件 `anthropic.claude-code` | Claude 帳號（Pro / Max 訂閱）或 Anthropic API key | 左側活動列的 Claude 圖示 |

> [!IMPORTANT]
> Codex 與 Claude Code 需要學員自己的帳號。**只有 Antigravity 內建 Agent 也能完成本課程所有練習**；有其他帳號的學員，再加裝對應的擴充套件來比較。

### A. 安裝擴充套件（裝在遠端 SSH: nano4-proxy）

連上 Nano4 後，擴充套件分為「本地」與「遠端（SSH）」。**AI Agent 與 Python、Jupyter 套件都要裝在遠端**，Agent 才能讀取 Nano4 上的檔案、在 Nano4 上執行指令。

按下 **``Ctrl + ` ``** 開啟整合式終端機，執行本章隨附的安裝腳本（Antigravity 與 VS Code 都適用）：

```bash
cd "$HOME/Nano4-Docs/02-vscode-and-ai-tools/scripts"
bash install_vscode_extensions.sh
```

腳本會安裝下列套件：

| 套件類別 | 識別碼 (Extension ID) | 核心功能 |
| :--- | :--- | :--- |
| **Codex** | `openai.chatgpt` | OpenAI 的 AI Agent |
| **Claude Code** | `anthropic.claude-code` | Anthropic 的 AI Agent |
| **Python 核心環境** | `ms-python.python` | Python 語法高亮、虛擬環境自動偵測 |
| **Python 除錯器** | `ms-python.debugpy` | 斷點除錯、單步執行與變數檢視 |
| **Jupyter 互動運算** | `ms-toolsai.jupyter` | 執行 `.ipynb` Notebook 的運算引擎 |
| **Jupyter 渲染器** | `ms-toolsai.jupyter-renderers` | 支援 Plotly 互動圖表與 DataFrame 表格檢視 |

*(也可以在左側 Extensions 面板搜尋套件名稱，點選 **Install in SSH: nano4-proxy** 安裝。)*

### B. 登入各個 Agent

1. **Codex**：點左側活動列的 Codex 圖示 ➔ **Sign in with ChatGPT**，依畫面在本機瀏覽器完成授權。
2. **Claude Code**：點左側活動列的 Claude 圖示 ➔ 依畫面登入 Claude 帳號（或填入 API key）。
3. **Antigravity 內建 Agent**：打開 Agent 面板即可使用。

> [!TIP]
> 三個 Agent 都在**登入節點**上執行指令。登入節點只適合編輯、小型測試與送出作業；請讓 Agent 把運算用 `sbatch` 送到計算節點（`AGENTS.md` 已寫明這條規則，見第 5 節）。

---

## 4. 三個 Agent 怎麼讀到 Nano4 的規則與 Skills

Agent 會從**您開啟的工作資料夾**讀取規則檔，並從固定的資料夾載入 Skills（第二堂會做自己的 skill）：

| Agent | 讀取的規則檔 | 工作資料夾的 Skills | 個人（所有資料夾）的 Skills |
| :--- | :--- | :--- | :--- |
| Antigravity 內建 Agent | `.agents/rules/` 裡的規則（本教材的 `.agents/rules/nano4.md` 會引用 `AGENTS.md`） | `.agents/skills/` | `~/.gemini/config/skills/` |
| Codex | `AGENTS.md` | `.agents/skills/` | `~/.agents/skills/` |
| Claude Code | `CLAUDE.md`（本教材的 `CLAUDE.md` 內容為 `@AGENTS.md`，也就是匯入 `AGENTS.md`） | `.claude/skills/` | `~/.claude/skills/` |

- 用 File ➔ Open Folder 開啟 **`$HOME/Nano4-Docs`**，三個 Agent 都會讀到本教材的 `AGENTS.md`；Antigravity 與 Codex 也會自動載入 `Nano4-Docs/.agents/skills/` 裡課程提供的 Skills（第 06 章介紹）。
- 開啟其他資料夾（例如 `/work/<帳號>`）時，Agent **不會**讀到這份規則。第 03 章會用腳本在工作資料夾放好 `AGENTS.md`、`CLAUDE.md` 與 `.agents/rules/nano4.md`。
- 不確定 Agent 有沒有讀到時，在對話開頭加一句「請先閱讀 AGENTS.md」。

---

## 5. 超算專屬 AI Agent 治理守則：AGENTS.md

**AI 預設並不知道超級電腦是多人共用的**，可能會建議執行 `sudo apt install`、在 `$HOME` 下載 50 GB 模型，或在登入節點直接跑大型運算。本教材在根目錄建立了 **[`AGENTS.md`](./agents_governance)** 系統守則，告訴 AI 這台機器的規矩：

1. **嚴禁 `sudo`**：軟體需求改以 Lmod 模組、`uv` 虛擬環境或 Apptainer 容器解決。
2. **大資料放 `/work/$USER`**：大資料集、模型與虛擬環境一律放在 `/work`，不塞爆 `$HOME`，不寫 `/tmp`。
3. **登入節點不跑重度運算**：超過 5 分鐘、4 核心或 8 GB 的工作，一律封裝成 Slurm 作業送到計算節點。
4. **Slurm 作業標準**：腳本執行內容第一行是 `module purge`，日誌格式一律使用 `%x-%j.out`；送出後不要在迴圈中反覆查詢 `squeue`。
5. **本課程設定**：`GOV115088` 只能使用 `ngs62g`，每個作業固定 `-c 8 --mem=62G`，不可為了「省資源」調小。
6. **Agent 替使用者操作**：使用者多為第一次使用超級電腦的生醫研究者。Agent 應先用白話說明計畫、撰寫並驗證腳本、經使用者同意後送出，最後用白話解讀結果，而不是丟給使用者一長串指令去打。

---

## 6. 動手實戰練習 (Hands-on Labs 1 ~ 6)

| 練習 | 內容 | 本課程 |
| :---: | :--- | :--- |
| 1 | 在 Antigravity 開啟遠端工作區 | **必做** |
| 2 | 確認 ssh-proxy 只需認證一次 | **必做** |
| 3 | 裝上三個 AI Agent 並打招呼 | **必做**（至少 Antigravity 內建 Agent） |
| 4 | 三個 Agent 解釋同一支 Slurm 範本並比較 | **必做**（可用的 Agent 都試） |
| 5 | 人工驗證 AI 的建議 | **必做** |
| 6 | 手動送出 vs 自然語言派送 FastQC / MultiQC | **講師示範**，學員可跟著做 |

### 🧪 練習 1：在 Antigravity 開啟遠端工作區
1. 依照第 2 節步驟，在您個人筆電打開 Antigravity（或 VS Code）。
2. 透過 Remote-SSH 連線至 `nano4`（完成練習 2 後改連 `nano4-proxy`）。
3. 開啟 `/work/$USER` 目錄，在檔案清單中點擊右鍵新增一個檔案 `my_test.py`。
4. 寫入一行 `print("Hello from VS Code Remote on Nano4!")` 並存檔（`Ctrl + S`）。
5. 按下 **``Ctrl + ` ``** 打開整合終端，執行 `python my_test.py`，驗證程式碼確實在 Nano4 登入節點上執行！

---

### 🧪 練習 2：確認 ssh-proxy 只需認證一次
**目標**：完成第 2 節步驟 E 後，確認之後的連線都不再要求 OTP。

1. 在**本機**終端機 / PowerShell 啟動 proxy，完成一次密碼與 OTP 認證，並讓視窗保持開著：
   ```bash
   # Windows
   .\ssh-proxy-windows-x64.exe nano4 --max-lifetime 10h
   # macOS Apple Silicon
   ./ssh-proxy-macos-arm64 nano4 --max-lifetime 10h
   ```
2. 另開一個本機終端機，連續連線兩次：
   ```bash
   ssh nano4-proxy hostname
   ssh nano4-proxy 'echo $USER; hfsquota'
   ```
   **預期結果**：兩次都直接顯示結果（例如 `25a-lgn03` 與您的帳號），**不會再要求密碼或 OTP**。
3. 在 Antigravity 選 `Connect to Host... → nano4-proxy`，依序用 **Open Folder** 開啟 `/work/<帳號>`，再切換到 `/home/<帳號>/Nano4-Docs`。
   **預期結果**：切換資料夾時不再出現 OTP 提示。
4. 在整合終端執行 `hostname`，與步驟 2 的結果比較：透過 proxy 的連線都會落在同一台登入節點。

> 若出現 `Connection refused`，代表 proxy 已停止（例如視窗被關掉或超過時間上限），請回到步驟 1 重新啟動。

---

### 🧪 練習 3：裝上三個 AI Agent 並打招呼
1. 用 File ➔ Open Folder 開啟 `/home/<帳號>/Nano4-Docs`。
2. 依第 3 節執行 `install_vscode_extensions.sh`，並登入您有帳號的 Agent。
3. 對每個 Agent 輸入同一句話：
   ```text
   請先閱讀 AGENTS.md。用三句話告訴我：我現在在哪一台電腦上？這門課我能用哪個計畫和佇列？每個作業要申請多少核心和記憶體？
   ```
   **預期結果**：三個 Agent 都能說出登入節點（`25a-lgn0X`）、`GOV115088`、`ngs62g` 與 `-c 8 --mem=62G`。說不出來的 Agent，多半是沒有讀到 `AGENTS.md`（檢查工作資料夾是否為 `Nano4-Docs`）。

---

### 🧪 練習 4：三個 Agent 解釋同一支 Slurm 範本並比較
以同一個任務測試可用的 Agent：解釋 `sbatch` 腳本中的 `--account`、`--partition`、`--cpus-per-task`、`--mem`，並說明為什麼本課程一律使用 `-c 8 --mem=62G`。

對每個 Agent 輸入相同的 prompt：
```text
請先閱讀 AGENTS.md，再解釋 03-slurm-syntax-and-job-management/templates/standard_cpu_job.slurm 每一個 #SBATCH 參數的用途，但先不要修改檔案。
```

比較它們的回答：
- 是否都正確說出 `GOV115088` 只能使用 `ngs62g`？
- 是否有 Agent 建議把 `--mem` 調小？（依國網官方規定，`ngs62g` 必須固定 `-c 8 --mem=62G`，這是錯誤建議。）
- 哪個 Agent 的說明最容易懂？哪個最精確？

---

### 🧪 練習 5：人工驗證 AI 的建議
AI 的回答只是建議，最後要由學生自己驗證。無論練習 4 採用了哪些建議，都手動執行：

```bash
cd "$HOME/Nano4-Docs"
sinfo -p ngs62g
bash -n 03-slurm-syntax-and-job-management/templates/standard_cpu_job.slurm
sbatch --test-only --account=GOV115088 03-slurm-syntax-and-job-management/templates/standard_cpu_job.slurm
```

**預期結果**：`bash -n` 沒有任何輸出，代表 shell 語法正確；`--test-only` 顯示 `Job ... to start at ...`，代表帳號與分區組合可被接受（不會真的送出作業）。

> `sbatch --test-only` **不會檢查 QoS 與官方規格**（例如 `ngs62g` 必須固定 `-c 8 --mem=62G`），這部分仍需自行對照第 01 章的佇列表。

記錄哪個 Agent 的建議被採用、哪些建議被拒絕，以及實際驗證結果。

---

### 🧪 練習 6：手動送出 vs 自然語言派送 FastQC / MultiQC（第一堂結尾示範）

**目標**：用教材附的 4 個 FASTQ 定序樣本（各 1000 條 reads），做同一件事兩次：先手動送出寫好的 Slurm 腳本，再用一句自然語言請 AI Agent 完成。兩種方式都在計算節點 `ngs62g` 上執行 FastQC 與 MultiQC，約 10 秒就跑完。

**A. 手動：送出寫好的腳本**

```bash
cd /work/$USER
sbatch "$HOME/Nano4-Docs/02-vscode-and-ai-tools/templates/day1_fastqc_multiqc.slurm"
sacct -X -o JobID,JobName,State,Elapsed      # 跑完後 State 為 COMPLETED
tail -3 day1_qc-*.out
```

**預期結果**：日誌最後一行是 `✅ 完成！MultiQC 報告：/work/<帳號>/day1_qc/multiqc_out/multiqc_report.html`。腳本內容見 [`templates/day1_fastqc_multiqc.slurm`](https://github.com/gemini960114/Nano4-Docs/blob/main/02-vscode-and-ai-tools/templates/day1_fastqc_multiqc.slurm)，第二堂會學會每一行的意思。

**B. 自然語言：請 AI Agent 做同一件事**

在工作資料夾為 `Nano4-Docs` 的 Antigravity 中，對任一個 Agent 輸入：

```text
我有 4 個定序樣本（FASTQ），放在 04-ai-assisted-bio-pipeline/demo_data/fastq_raw/。
請幫我檢查這些樣本的定序品質：用 FastQC 逐一檢查，再用 MultiQC 彙整成一份報告，結果放在 /work/$USER/day1_qc_ai/。
請依照 AGENTS.md 把工作送到計算節點執行。送出前先用三到五句話告訴我你的計畫，等我同意再送出；跑完後用白話告訴我這 4 個樣本的品質如何。
```

**比較兩種方式**：

| 檢查項目 | 手動腳本 | AI 產生的腳本 |
| :--- | :---: | :---: |
| `--account=GOV115088`、`--partition=ngs62g` | ✅ | ? |
| `--cpus-per-task=8`、`--mem=62G` | ✅ | ? |
| `module purge` 後載入 `biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC` | ✅ | ? |
| 用 `sbatch` 送到計算節點，而不是在登入節點直接執行 FastQC | ✅ | ? |
| 送出後沒有在迴圈中反覆查詢 `squeue` | ✅ | ? |
| 用白話解讀品質結果 | — | ? |

> [!TIP]
> 若 Agent 在登入節點直接執行 FastQC、漏掉 `biology/JDK`，或把 `--mem` 調小，請直接告訴它哪裡違反 `AGENTS.md`，讓它修正後重來。這種「指出錯誤、請 AI 修正」的多輪對話，就是第二堂的主軸：第二堂會把這些經驗存成您自己的 skill。

---

## 7. 多登入節點與 Agent session 清理

Nano4 登入節點可能把同一次 SSH / Antigravity / VS Code 連線分派到
`25a-lgn01`～`25a-lgn05` 的不同主機。若舊主機上的 Antigravity / VS Code Server、Codex、
Claude Code 或 Antigravity agent 沒有正常結束，重新連線到另一台主機時可能
看起來像「session 卡住」或無法接續原本的對話。

> [!TIP]
> 使用本章步驟 E 的 `ssh-proxy` 時，所有 Antigravity / VS Code / 終端機連線都走同一條已認證的連線，會固定在同一台登入節點上，比較不會遇到這個問題。

本教材提供兩支清理腳本。它們只會處理**目前使用者自己的程序**，但會終止所有匹配的
AI/IDE agent；執行前請先儲存檔案、結束不需要保留的工作，並確認沒有正在執行的分析。

> [!WARNING]
> 請從**一般 SSH 終端機**（例如 `ssh nano4`）執行，不要在 Antigravity / VS Code 整合終端機內執行：腳本會連同您目前使用的伺服器端一起終止，造成立即斷線。
> `kill_login.sh` 會從目前的登入節點以 SSH 連到其他四台登入節點；若出現密碼或 2FA 提示，請依畫面完成驗證，無法連線的主機會顯示警告並略過。

```bash
cd "$HOME/Nano4-Docs"
chmod +x 02-vscode-and-ai-tools/scripts/kill.sh \
           02-vscode-and-ai-tools/scripts/kill_login.sh

# 只清理目前這台登入節點：會先列出匹配程序，再要求確認
bash 02-vscode-and-ai-tools/scripts/kill.sh

# 清理五台登入節點上的 stale agent（不會再詢問確認，會直接執行）
bash 02-vscode-and-ai-tools/scripts/kill_login.sh
```

清理完成後，重新啟動 Antigravity / VS Code Remote-SSH，讓它在目前取得的登入節點
建立新的 agent session。若某台主機無法連線，腳本會顯示警告並繼續處理其他主機。

> [!CAUTION]
> `kill_login.sh` 不是一般登出指令；它會在五台登入節點上使用 `pkill -9` 終止匹配
> 程序。不要在有重要互動工作或未保存修改時執行。

---

## 8. 常見踩坑與連線排錯 (FAQ)

### Q1：Remote-SSH 連線時卡在「Waiting for 2FA...」？
* **原因**：連線時，終端驗證提示有時會縮在視窗頂部或終端輸出分頁中。
* **解法**：請留意視窗頂部的文字輸入框，或點開「Output (輸出)」分頁切換至「Remote - SSH」，在提示時輸入 `2` (PUSH) 或 `1` (OTP)。

### Q2：開啟檔案總管時找不到 `/work` 目錄？
* **原因**：預設開啟的是家目錄 `$HOME`。
* **解法**：點擊選單「File ➔ Open Folder」，在路徑列手動輸入 `/work/您的帳號/` 即可。

### Q3：在擴充套件面板找不到 Codex 或 Claude Code？
* **原因**：套件裝到了「本地」，或搜尋時沒有連上遠端。
* **解法**：確認左下角顯示 `SSH: nano4-proxy`，再執行第 3 節的 `install_vscode_extensions.sh`；或在 Extensions 面板中點選 **Install in SSH: nano4-proxy**。

### Q4：Agent 的回答不知道 `GOV115088`、`ngs62g`？
* **原因**：工作資料夾裡沒有規則檔（Codex 讀 `AGENTS.md`、Claude Code 讀 `CLAUDE.md`、Antigravity 讀 `.agents/rules/`）。
* **解法**：用 File ➔ Open Folder 開啟 `$HOME/Nano4-Docs`，開一個新對話再問一次；或在對話開頭要求「請先閱讀 AGENTS.md」。

### Q5：Jupyter Notebook 無法選擇 Python Kernel？
* **原因**：未安裝遠端 Python / Jupyter 擴充套件，或尚未啟動虛擬環境。
* **解法**：
  1. 確保已在遠端安裝 `ms-toolsai.jupyter` 與 `ms-python.python`。
  2. 確認虛擬環境已安裝 Jupyter kernel 套件（第 01 章的 `lab_env` 預設沒有）：
     ```bash
     uv pip install --python /work/${USER}/lab_env/bin/python ipykernel
     ```
  3. 點擊 Notebook 右上角的「Select Kernel ➔ Python Environments」，選擇 `/work/$USER/lab_env` 或自訂環境路徑。

---

恭喜您！現在您的 Antigravity 已經連上 Nano4，並帶著三個熟悉超算規則的 AI Agent！  
👉 **下一步**：進入 **[第 03 章：Slurm 語法與作業調度](./03_slurm_syntax_and_job_management)**：先親手寫 Slurm 腳本，再請 AI Agent 用自然語言完成同樣的工作，最後把經驗存成您自己的 skill。
