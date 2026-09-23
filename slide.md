# Nano4 GP1 生醫 HPC 實戰課程

## 第一堂：連線與 AI Agent

第 01 章　登入、2FA 與環境管理
第 02 章　Antigravity Remote-SSH 與三個 AI Agent

📖 線上講義：https://gemini960114.github.io/Nano4-Docs/

<!-- 講者備註：開場先確認每位學員都有筆電與手機，並已完成課前作業 -->

---

## 今天的時間表

| 時間 | 內容 |
| :---: | :--- |
| 0:00–0:15 | 開場、確認課前準備 |
| 0:15–0:25 | Nano4 與 GP1 架構 |
| 0:25–0:45 | SSH 登入、2FA、取得教材 |
| 0:45–1:00 | 儲存空間與模組（練習 1、練習 3） |
| 1:00–1:25 | Antigravity 遠端連線 |
| 1:25–1:35 | ☕ 休息 |
| 1:35–2:00 | ssh-proxy：只認證一次 |
| 2:00–2:25 | 裝上三個 AI Agent、AGENTS.md |
| 2:25–2:40 | 三個 Agent 比較、人工驗證 |
| 2:40–3:00 | 結尾示範：手動 vs 自然語言派送作業 |

---

## 今天結束時，你會做到

1. 用 **Antigravity** 連上 Nano4，而且**只需認證一次**
2. 分清楚 `$HOME` 與 `/work` 該放什麼，會用 `module` 載入生醫工具
3. 在 Nano4 上裝好 **三個 AI Agent**：Antigravity 內建 Agent、Codex、Claude Code
4. 讓 AI 遵守超算規則（`AGENTS.md`），並自己驗證 AI 說得對不對
5. 看懂同一個質控作業的兩種送法：**手動 `sbatch`** 與**一句自然語言**

---

## 課前準備確認 ✋

| # | 項目 | 完成了嗎？ |
| :---: | :--- | :---: |
| 1 | iService 帳號已加入計畫 `GOV115088` | ☐ |
| 2 | 手機已安裝 **IDExpert App** 並完成 2FA 綁定 | ☐ |
| 3 | 已用 `ssh` 登入 Nano4 **一次**（系統才會建立家目錄） | ☐ |
| 4 | 已安裝 **Google Antigravity** 並用 Google 帳號登入 | ☐ |
| 5 | 已下載 **ssh-proxy** 執行檔 | ☐ |
| 6 | （選做）ChatGPT 帳號（Codex）或 Claude 帳號（Claude Code） | ☐ |

還沒完成的同學請舉手，助教會協助你。

<!-- 講者備註：第 1、2 項沒完成的學員，今天大部分練習都無法進行，請助教優先處理；第 6 項沒有也沒關係，只用 Antigravity 內建 Agent 就能完成所有練習 -->

---

## 本課程的固定設定（請記住）

```text
計畫代號：GOV115088（國網生技醫藥高效能運算推廣與應用計畫）
佇列：    ngs62g
規格：    每個作業固定 -c 8 --mem=62G（國網官方規定，不可自行縮減）
環境：    CPU-only，本次不使用 GPU
```

> 講義裡出現的 H200 / GB200 GPU、`GOV113021`、`MST109178` 等都是**參考資料**，照抄會被排程器拒絕。

---

# 第 01 章

## 登入、2FA 與環境管理

---

## Nano4 長什麼樣子？

```text
          你的筆電
             │  SSH (Port 22)          SFTP / SCP (Port 2222)
             ▼                                 ▼
   ┌───────────────────┐            ┌───────────────────┐
   │ 登入節點           │            │ 資料傳輸節點 (DTN) │
   │ 25a-lgn01～05      │            │ 只能傳檔，不能下指令│
   └─────────┬─────────┘            └─────────┬─────────┘
             │ sbatch 送出作業                  │
             ▼                                 │
   ┌───────────────────────────────┐          │
   │ 計算節點                       │          │
   │ ・GP1 生醫 CPU 25a-cpn*  ← 本課程 │          │
   │ ・H200 / GB200 GPU（參考）       │          │
   └─────────────┬─────────────────┘          │
                 ▼                             ▼
        ┌─────────────────────────────────────────┐
        │ WekaFS 高速共享儲存：/home 與 /work        │
        └─────────────────────────────────────────┘
```

GP1 生醫節點是 **Nano4 的一部分**，和 GPU 節點共用登入節點與儲存空間。

---

## 三個角色：一個比喻

| 角色 | 比喻 | 你在這裡做什麼 |
| :--- | :--- | :--- |
| **登入節點** | 大樓接待大廳 | 連線、看檔案、寫腳本、小型測試 |
| **計算節點** | 工廠 | 真正的運算；不能直接走進去，要透過「工單」 |
| **Slurm** | 廠長 | 審查工單、分配機器、跑完把結果交給你 |

⚠️ **登入節點不能跑重度運算**：超過 5 分鐘、超過 4 核心或超過 8 GB 的工作，一律用 Slurm 送到計算節點。

---

## 新手必知三大鐵律

1. **傳檔用 Port 2222**：資料傳輸節點和登入節點同一個主機名稱 `nano4.nchc.org.tw`，但傳檔要指定 `-P 2222`
2. **只接受台灣境內 IP**：在國外請先連 VPN 回台灣學術網路
3. **沒有 `sudo`**：超算是多人共用系統，軟體請用 `module`、`uv` 或 Apptainer 容器解決

---

## SSH 登入 Nano4

在**自己電腦**的終端機（Windows 請開 PowerShell）輸入：

```bash
ssh your_account@nano4.nchc.org.tw
```

- 第一次連線會問是否信任主機金鑰 → 輸入 `yes`
- 接著會出現 2FA 選單（下一頁）
- 最後輸入主機密碼：**畫面不會顯示任何字元**，這是正常的

---

## 三種 2FA 方式

```text
Login method (1: Mobile APP OTP, 2: Mobile APP PUSH, 3: Email OTP):
```

| 選項 | 方式 | 怎麼做 | 推薦 |
| :---: | :--- | :--- | :---: |
| `2` | **手機推播** | IDExpert App 跳出授權請求 → 按「同意」 | ⭐⭐⭐⭐⭐ |
| `1` | 手機 OTP | 打開 IDExpert App → 左下角「OTP」→ 輸入 6 位數字 | ⭐⭐⭐⭐ |
| `3` | Email OTP | 到註冊信箱收驗證碼 | 備援 |

💡 **推播沒收到？** 手動打開 IDExpert App，請求通常會馬上跳出；還是沒有就按 `Ctrl+C`，重新登入並改選 `1`。

---

## 取得課程教材

登入成功後，把教材下載到家目錄：

```bash
cd "$HOME"
if [[ -d Nano4-Docs/.git ]]; then
    git -C Nano4-Docs pull --ff-only
else
    git clone https://github.com/gemini960114/Nano4-Docs.git
fi
cd "$HOME/Nano4-Docs"
git status --short
```

之後重新開啟終端機，都先回到教材目錄：

```bash
cd "$HOME/Nano4-Docs"
```

---

## 讓登入更快：設定 SSH Config

在**自己電腦**編輯 `~/.ssh/config`（Windows：`C:\Users\<你>\.ssh\config`）：

```ssh-config
Host nano4
    HostName nano4.nchc.org.tw
    User your_account
    Port 22
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

之後只要輸入：

```bash
ssh nano4
```

> 每一條新連線還是要輸入密碼與 OTP。第 02 章的 **ssh-proxy** 會解決這個問題。

---

## 儲存空間：什麼東西放哪裡？

| 路徑 | 放什麼 | 本課程配額 | 注意 |
| :--- | :--- | :---: | :--- |
| `$HOME`（`/home/帳號`） | 程式碼、Git repo、設定檔、skill | 約 100 GB | 不要放大量小檔案或快取 |
| `/work/帳號` | FASTQ、分析結果、容器與暫存檔 | 約 100 GB | **沒有備份**，重要結果要自己備份 |
| `/tmp` | ❌ 不要放任何資料 | — | 隨時會被清除 |

⚠️ 是 **`/work`**，不是舊系統的 `/work1`。

---

## 查詢自己的空間：`hfsquota`

```bash
hfsquota
```

```text
PATH                 USED      HARD LIMIT          USAGE %  STATUS
/home/<帳號>         499,712 B 107,374,182,400 B       0  ACTIVE
/work/<帳號>       2,240,512 B 107,374,182,400 B       0  ACTIVE
```

❌ 不要用 `df -h`：它顯示的是整個叢集好幾 PB 的容量，不是你的配額。

---

## 🧪 練習 1：環境健檢（5 分鐘）

```bash
whoami        # 我是誰
hostname      # 我在哪台登入節點（25a-lgn01～05）
pwd           # 我在哪個資料夾
hfsquota      # 我的 /home 與 /work 配額
```

執行一鍵健檢腳本：

```bash
cd "$HOME/Nano4-Docs/01-nano4-ssh-and-2fa/scripts"
./quick_healthcheck.sh
```

**請確認**：

- `wallet` 那一段有列出 **`GOV115088`**
- 佇列概況顯示 `ngs62g (本課程 GOV115088，固定 -c 8 --mem=62G，96h)`
- 外網測試出現 `✅ 外網連線正常 (NCBI 連通)`

---

## 軟體從哪裡來？`module`

超算上不能 `sudo apt install`，官方已經把常用軟體裝好，用 `module` 載入：

| 指令 | 用途 |
| :--- | :--- |
| `module avail biology/FastQC` | 查詢有哪些版本 |
| `module load 名稱/版本` | 載入 |
| `module list` | 列出目前載入的模組 |
| `module purge` | 全部清空 |

📌 生醫工具都在 `biology/` 底下。

---

## 🧪 練習 3：載入生醫模組（5 分鐘）

```bash
# 1. 清空環境，確認工具還不存在
module purge
command -v fastqc || echo "fastqc: 尚未載入"

# 2. 載入本課程會用到的三個模組
module load biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC

# 3. 確認版本
fastqc --version      # FastQC v0.11.9
multiqc --version     # multiqc, version 1.35
java -version         # java version "26.0.1"
module list

# 4. 再次清空，工具又不見了
module purge
command -v fastqc || echo "fastqc: 已隨 module purge 移除"
```

---

## 為什麼 FastQC 一定要搭配 JDK？

- 計算節點**沒有系統 Java**
- 只載入 `biology/FastQC`、沒載入 `biology/JDK` 時：
  - FastQC 找不到 Java，**不會產生任何報告**
  - 但指令**仍可能顯示成功** ← 最容易被騙的地方
- AI Agent 也常漏掉這一點，今天最後的示範請注意看

> 這也是為什麼 Slurm 腳本第一行要 `module purge`：先清空，再明確載入需要的東西。

---

## 為什麼需要 Slurm？

```text
[個人電腦思維]  雙擊程式 → 馬上在本機執行 → 關掉視窗就中斷

[超級電腦思維]  在登入節點寫腳本 → sbatch 交給 Slurm
               → 計算節點在背景執行 → 你可以關機回家
               → 跑完結果寫進日誌檔
```

📌 今天只看 Slurm 怎麼用，第二堂再學腳本每一行的意思。

---

## `ngs62g` 規格：官方固定搭配

| 佇列 | 核心 `-c` | 記憶體 `--mem` | 最長時間 | 本課程 |
| :--- | :---: | :---: | :---: | :---: |
| `ngs62g` | **8** | **62 GB** | 4 天 | ✅ `GOV115088` 唯一可用 |
| `ngstest`、`ngs8g`～`ngs32g`、`ngs125g`… | — | — | — | ❌ 只開放 `MST109178` 等計畫 |

- 國網規定每個佇列都要用固定的「核心 × 記憶體」申請
- 送到其他 `ngs*` 佇列會被拒絕
- 計費以**核心小時**計算

---

## 第 01 章常見問題

| 狀況 | 解法 |
| :--- | :--- |
| `ssh` 卡住，`Connection timed out` | 是否在國外？單位防火牆擋 Port 22？改用手機熱點試試 |
| 推播一直沒收到 | 手動打開 IDExpert App；或 `Ctrl+C` 重來並改選 `1` OTP |
| `Disk quota exceeded` | `hfsquota` 檢查；大檔案移到 `/work/$USER` |
| `sudo` 被拒絕 | 正常。改用 `module`、`uv` 或容器 |
| 在登入節點跑程式被 `Killed` | 超過 5 分鐘的重度運算會被系統清除，改用 `sbatch` |

---

# 第 02 章

## Antigravity Remote-SSH 與三個 AI Agent

---

## 為什麼要用 Antigravity Remote-SSH？

```text
[ 你的筆電 ]
  └─ Antigravity（本機介面、快捷鍵）
          │  加密 SSH 連線（第 01 章設定的 Host nano4）
          ▼
[ Nano4 登入節點 25a-lgn01～05 ]
  ├─ Antigravity Server（背景執行）
  ├─ 三個 AI Agent：內建 Agent、Codex、Claude Code
  ├─ /work/$USER 高速工作區
  └─ Slurm 指令（sbatch、squeue、sacct）
```

- 目的：**把 AI Agent 帶到超算上**，讓它直接讀檔、寫腳本、送作業
- 滑鼠操作檔案總管，不用記 `vim`；``Ctrl + ` `` 開啟遠端終端機
- 用 VS Code 也可以，步驟相同，只是沒有內建 Agent

---

## 步驟 A：安裝 Antigravity

1. 到 https://antigravity.google/ 下載安裝，用 Google 帳號登入
2. `Ctrl + Shift + X` 開啟擴充套件，確認已有 **Remote - SSH**（已內建就略過）
3. 首次連線時，Antigravity 會在 Nano4 的 `~/.antigravity-ide-server` 安裝伺服器端

**用 VS Code 的同學**

1. 到 https://code.visualstudio.com/ 下載安裝
2. 搜尋 **Remote - SSH**（Microsoft 發行）→ Install

---

## 步驟 B–C：連上 Nano4

1. 點左下角 `><` 圖示 → **Connect to Host...**
2. 選 **`nano4`**（讀取第 01 章設定的 `~/.ssh/config`）
3. 平台選 **Linux**
4. 上方輸入框出現 2FA 選單 → 輸入 `2` → 手機按同意 → 輸入密碼
5. 左下角顯示 **`SSH: nano4`** 就成功了

💡 **卡在「Waiting for 2FA」？** 提示可能縮在視窗頂部，或在「Output → Remote - SSH」分頁裡。

---

## 步驟 D ＋ 🧪 練習 1：開啟遠端工作區

1. 檔案總管 → **Open Folder** → 輸入 `/work/your_account`
2. 右鍵新增檔案 `my_test.py`，寫入：

   ```python
   print("Hello from VS Code Remote on Nano4!")
   ```

3. `Ctrl + S` 存檔，按 ``Ctrl + ` `` 開啟終端機：

   ```bash
   python my_test.py
   ```

👉 注意：剛才 **Open Folder 時，是不是又要輸入一次密碼和 OTP？**

---

## 問題：為什麼要一直認證？

Nano4 的**每一條新 SSH 連線**都要密碼 + OTP。
Antigravity 在這些時候都會開新連線：

- 第一次連線
- Open Folder 選目錄
- 切換資料夾、重新載入視窗

→ 一堂課可能要認證**好幾次** 😩

---

## 解法：ssh-proxy 只認證一次

```text
Antigravity / VS Code / 終端機
        │  連 nano4-proxy（不需 OTP）
        ▼
127.0.0.1:2222   ← ssh-proxy（在你的電腦上執行，視窗保持開著）
        │  已完成密碼 + OTP 的連線
        ▼
nano4.nchc.org.tw:22
```

- ssh-proxy 先幫你完成**一次**認證，並保持連線
- 之後所有連線都走這條已認證的通道
- 額外好處：所有連線固定在**同一台登入節點**

🔗 https://github.com/gemini960114/ssh-proxy

---

## ssh-proxy 設定 1：下載

到 [Releases 頁面](https://github.com/gemini960114/ssh-proxy/releases/latest) 下載（免安裝 Python）：

| 你的電腦 | 下載檔案 |
| :--- | :--- |
| Windows 10 / 11 | `ssh-proxy-windows-x64.exe` |
| macOS Apple Silicon（M1–M4） | `ssh-proxy-macos-arm64` |
| Linux x64 | `ssh-proxy-linux-x64` |

Intel Mac 沒有預先編譯的檔案，需依 ssh-proxy README 用 `uv` 從原始碼執行。

---

## ssh-proxy 設定 2：加入 `nano4-proxy`

在**自己電腦**的 `~/.ssh/config` 再加一段（保留原本的 `Host nano4`）：

```ssh-config
Host nano4-proxy
    HostName 127.0.0.1
    Port 2222
    User your_account
    # 這兩行只能用在 127.0.0.1 這個別名，絕對不要加到 nano4
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel ERROR
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

⚠️ 記得把 `your_account` 改成**自己的帳號**。

---

## ssh-proxy 設定 3：啟動並認證一次

在**自己電腦**的終端機執行，並讓這個視窗**保持開著**：

```bash
# Windows (PowerShell)
.\ssh-proxy-windows-x64.exe nano4 --max-lifetime 10h

# macOS Apple Silicon（第一次需加執行權限並解除下載隔離）
chmod +x ssh-proxy-macos-arm64
xattr -d com.apple.quarantine ssh-proxy-macos-arm64
./ssh-proxy-macos-arm64 nano4 --max-lifetime 10h
```

- 第一次會顯示 Nano4 的主機金鑰指紋 → 輸入完整的 `yes`
- 依提示輸入密碼與 OTP
- `--max-lifetime 10h`：預設 8 小時會自動停止，加上這個撐過一整天

---

## 🧪 練習 2：確認只需認證一次（10 分鐘）

**另開一個本機終端機**，連續連線兩次：

```bash
ssh nano4-proxy hostname
ssh nano4-proxy 'echo $USER; hfsquota'
```

✅ 兩次都直接顯示結果，**不再要求密碼或 OTP**

接著在 Antigravity：

1. `Connect to Host...` → 選 **`nano4-proxy`**（不是 `nano4`）
2. Open Folder 開啟 `/work/<帳號>`
3. 再切換到 `/home/<帳號>/Nano4-Docs`

✅ 切換資料夾時不再出現 OTP

---

## ssh-proxy 使用注意

| 狀況 | 說明 |
| :--- | :--- |
| 自動停止 | 沒有任何連線 **60 分鐘**，或總執行 **8 小時**後會停止（可用 `--max-lifetime` 延長） |
| `Connection refused` | proxy 已停止 → 重新啟動（再認證一次）並重新連線 |
| `Address already in use` | 已經有另一個 proxy 在用 2222 埠，先關掉它 |
| `REMOTE HOST IDENTIFICATION HAS CHANGED` | proxy 會在送出密碼前停止；先向國網中心確認，**不要**直接刪除舊金鑰 |

🔒 **只在自己的電腦上使用**：proxy 執行期間，同一台電腦的其他程式也能透過它進入你的帳號。離開座位或使用共用電腦時，請在 proxy 視窗按 `Ctrl+C`。

---

## 三個 AI Agent，自由切換

| Agent | 怎麼取得 | 需要的帳號 |
| :--- | :--- | :--- |
| **Antigravity 內建 Agent** | 內建，不需安裝 | Google 帳號（已登入） |
| **Codex** | 擴充套件 `openai.chatgpt` | ChatGPT 帳號 |
| **Claude Code** | 擴充套件 `anthropic.claude-code` | Claude 帳號或 API key |

- 同一個問題，請三個 Agent 各回答一次，互相比對
- 你不必背指令：**說出想做的分析**，由 Agent 寫腳本、送作業、解讀結果

> 只有 Antigravity 內建 Agent 也能完成所有練習；有帳號的同學再加裝另外兩個來比較。

---

## 安裝擴充套件：裝在遠端

連上 `nano4-proxy` 後，按 ``Ctrl + ` `` 開啟終端機：

```bash
cd "$HOME/Nano4-Docs/02-vscode-and-ai-tools/scripts"
bash install_vscode_extensions.sh
```

- 腳本會安裝 Codex、Claude Code，以及 Python、Jupyter 套件
- 也可以在 Extensions 面板搜尋，點 **Install in SSH: nano4-proxy**

⚠️ Agent 要裝在**遠端（SSH）**，才能讀取 Nano4 上的檔案、在 Nano4 上執行指令。

---

## 登入各個 Agent

1. **Codex**：點左側活動列的 Codex 圖示 → **Sign in with ChatGPT**
2. **Claude Code**：點左側活動列的 Claude 圖示 → 登入 Claude 帳號（或填 API key）
3. **Antigravity 內建 Agent**：打開 Agent 面板即可使用

⚠️ 三個 Agent 都在**登入節點**執行指令：運算一定要讓 Agent 用 `sbatch` 送到計算節點。

---

## Agent 要執行指令時，會先問你

Codex、Claude Code 在執行指令或寫入檔案前，會跳出確認視窗：

1. **先看它要跑什麼**，不要直接按「允許」
2. 看到 `sbatch` → 檢查帳號、佇列與 `-c 8 --mem=62G`
3. 看到在登入節點直接執行 `fastqc`、`multiqc` 等運算 → **拒絕**，請它改用 `sbatch`
4. 看不懂的指令 → 先問 Agent：「這個指令是做什麼的？」

👉 你負責確認，AI 負責執行。

---

## Agent 從哪裡讀到 Nano4 的規則？

| Agent | 讀取的規則檔 |
| :--- | :--- |
| Antigravity 內建 Agent | `.agents/rules/`（教材的 `nano4.md` 會引用 `AGENTS.md`） |
| Codex | `AGENTS.md` |
| Claude Code | `CLAUDE.md`（教材的 `CLAUDE.md` 匯入 `AGENTS.md`） |

- 用 Open Folder 開啟 **`$HOME/Nano4-Docs`**，三個 Agent 都會讀到規則
- 開啟其他資料夾時讀不到 → 在對話開頭說「請先閱讀 AGENTS.md」

---

## AI 不知道超算的規矩

AI 助手預設**不知道**超級電腦是多人共用的，可能會建議：

- ❌ `sudo apt install ...`
- ❌ 把 50 GB 模型下載到 `$HOME`
- ❌ 在登入節點直接跑大型運算
- ❌ 為了「省資源」把 `--mem` 調小

👉 解法：在 repo 根目錄放一份 **`AGENTS.md`**，告訴 AI 這台機器的規則。

---

## `AGENTS.md`：給 AI 的 Nano4 守則

1. **禁止 `sudo`**：軟體改用 `module`、`uv` 或 Apptainer 容器
2. **大資料放 `/work/$USER`**：不塞爆 `$HOME`，不寫 `/tmp`
3. **登入節點不跑重度運算**：一律封裝成 Slurm 作業
4. **Slurm 標準**：`module purge` 放第一行、日誌用 `%x-%j.out`、不反覆查詢 `squeue`
5. **本課程設定**：`GOV115088` 只能用 `ngs62g`，固定 `-c 8 --mem=62G`
6. **替使用者操作**：先用白話說明計畫、等你同意再送出，跑完用白話解讀結果

---

## 🧪 練習 3：裝上三個 Agent 並打招呼（10 分鐘）

1. Open Folder 開啟 `/home/<帳號>/Nano4-Docs`
2. 執行 `install_vscode_extensions.sh`，登入你有帳號的 Agent
3. 對每個 Agent 輸入同一句話：

```text
請先閱讀 AGENTS.md。用三句話告訴我：我現在在哪一台電腦上？這門課我能用哪個計畫和佇列？每個作業要申請多少核心和記憶體？
```

✅ 三個 Agent 都能說出 `25a-lgn0X`、`GOV115088`、`ngs62g` 與 `-c 8 --mem=62G`

---

## 🧪 練習 4：三個 Agent 解釋同一支範本（10 分鐘）

對每個 Agent 輸入相同的 prompt：

```text
請先閱讀 AGENTS.md，再解釋 03-slurm-syntax-and-job-management/templates/standard_cpu_job.slurm 每一個 #SBATCH 參數的用途，但先不要修改檔案。
```

比較它們的回答：

- 是否都說出 **`GOV115088` 只能使用 `ngs62g`**？
- 有沒有 Agent 建議**把 `--mem` 調小**？
  → 這是**錯誤建議**：國網規定 `ngs62g` 必須固定 `-c 8 --mem=62G`
- 哪個 Agent 的說明最容易懂？哪個最精確？

<!-- 講者備註：請一兩位學員分享 Agent 給出的錯誤建議，這是本段最重要的學習點 -->

---

## 🧪 練習 5：人工驗證 AI 的建議（5 分鐘）

AI 的回答只是建議，**最後要由你自己驗證**：

```bash
cd "$HOME/Nano4-Docs"
sinfo -p ngs62g
bash -n 03-slurm-syntax-and-job-management/templates/standard_cpu_job.slurm
sbatch --test-only --account=GOV115088 \
    03-slurm-syntax-and-job-management/templates/standard_cpu_job.slurm
```

預期結果：

```text
（bash -n 沒有任何輸出 = 語法正確）
sbatch: Job 426753 to start at 2026-09-23T20:19:09 using 8 processors on nodes 25a-cpn01 in partition ngs62g
```

⚠️ `--test-only` 只檢查**帳號與分區**，**不檢查**官方規格（`-c 8 --mem=62G`），這部分要自己對照。

---

## 🧪 練習 6 A：手動送出質控作業

4 個定序樣本（FASTQ，各 1000 reads）→ FastQC 逐一檢查 → MultiQC 彙整成一份報告

```bash
cd /work/$USER
sbatch "$HOME/Nano4-Docs/02-vscode-and-ai-tools/templates/day1_fastqc_multiqc.slurm"
sacct -X -o JobID,JobName,State,Elapsed      # 跑完後 State 為 COMPLETED
tail -3 day1_qc-*.out
```

日誌最後一行：

```text
✅ 完成！MultiQC 報告：/work/<帳號>/day1_qc/multiqc_out/multiqc_report.html
```

💡 作業約 10 秒就跑完。腳本每一行的意思，第二堂會學到。

<!-- 講者備註：先投影 day1_fastqc_multiqc.slurm 的內容，讓學員看到手動版需要寫哪些東西，再送出 -->

---

## 🧪 練習 6 B：一句自然語言，請 Agent 做同一件事

在工作資料夾為 `Nano4-Docs` 的 Antigravity，對任一個 Agent 輸入：

```text
我有 4 個定序樣本（FASTQ），放在 04-ai-assisted-bio-pipeline/demo_data/fastq_raw/。
請幫我檢查這些樣本的定序品質：用 FastQC 逐一檢查，再用 MultiQC 彙整成一份報告，結果放在 /work/$USER/day1_qc_ai/。
請依照 AGENTS.md 把工作送到計算節點執行。送出前先用三到五句話告訴我你的計畫，等我同意再送出；跑完後用白話告訴我這 4 個樣本的品質如何。
```

👉 你沒有打任何指令，只說了**想完成的分析**

<!-- 講者備註：講師示範時選一個 Agent，先讀出它的計畫再按同意；時間夠可換另一個 Agent 再做一次。備案：課前先用講師帳號跑一次，把 Agent 的計畫、腳本與結果截圖存好；課堂上超過 5 分鐘還沒跑完，就改用截圖講解，不要讓全班乾等 -->

---

## 打開 MultiQC 報告，看一眼成果

報告在遠端 Nano4 上，兩種打開方式：

**方式 A：下載到筆電**

檔案總管找到 `/work/<帳號>/day1_qc/multiqc_out/multiqc_report.html` → 按右鍵 → **Download...** → 在筆電瀏覽器開啟

**方式 B：連接埠轉送**

```bash
cd "$HOME/Nano4-Docs/04-ai-assisted-bio-pipeline/scripts"
bash view_multiqc_report.sh /work/$USER/day1_qc/multiqc_out
```

- 依畫面提示在瀏覽器打開 `http://localhost:<埠號>/multiqc_report.html`
- 看完執行 `tmux kill-session -t svc-multiqc-report` 關閉預覽

📌 先看一眼：4 個樣本的品質分數都在綠色區。怎麼讀懂整份報告，第二堂第 04 章會教。

---

## 練習 6：比較兩種送法

| 檢查項目 | 手動腳本 | AI 產生的腳本 |
| :--- | :---: | :---: |
| `--account=GOV115088`、`--partition=ngs62g` | ✅ | ? |
| `--cpus-per-task=8`、`--mem=62G` | ✅ | ? |
| `module purge` 後載入 `biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC` | ✅ | ? |
| 用 `sbatch` 送到計算節點，不在登入節點直接跑 | ✅ | ? |
| 送出後沒有反覆查詢 `squeue` | ✅ | ? |
| 用白話解讀品質結果 | — | ? |

⚠️ Agent 做錯時，**用說的**告訴它違反了 `AGENTS.md` 哪一條，讓它修正後重來。

---

## 今天最重要的一件事

**AI Agent 替你寫指令、送作業、解讀結果。**
**你負責確認它的計畫與結果是否正確。**

- 確認計畫：帳號、佇列、`-c 8 --mem=62G`、資料放哪裡
- 確認結果：作業真的 `COMPLETED`、報告真的產生
- 發現錯誤：用說的糾正它

👉 第二堂：把這些「糾正 AI」的經驗，存成**你自己的 skill**

---

## 第 02 章常見問題

| 狀況 | 解法 |
| :--- | :--- |
| 卡在「Waiting for 2FA...」 | 看視窗頂部輸入框，或 Output → Remote - SSH 分頁 |
| 找不到 `/work` | File → Open Folder，手動輸入 `/work/你的帳號/` |
| 連 `nano4-proxy` 出現 `Connection refused` | proxy 視窗被關掉或已逾時，重新啟動 |
| 找不到 Codex 或 Claude Code | 確認左下角是 `SSH: nano4-proxy`，再裝到遠端 |
| Agent 不知道 `GOV115088`、`ngs62g` | 工作資料夾要開 `$HOME/Nano4-Docs`，開新對話再問 |

---

## 今天學到了什麼

| 主題 | 重點 |
| :--- | :--- |
| 連線 | `ssh nano4` ＋ 2FA；ssh-proxy 讓 Antigravity 只認證一次 |
| 儲存 | 程式碼放 `$HOME`、資料放 `/work`、不放 `/tmp`；用 `hfsquota` 查配額 |
| 軟體 | `module load`；FastQC 要搭配 `biology/JDK` |
| Slurm | `GOV115088` → `ngs62g` → 固定 `-c 8 --mem=62G` |
| AI Agent | 三個 Agent 裝在遠端；`AGENTS.md` 讓它們守規則；用自然語言派送作業，自己驗證結果 |

---

## 下課前檢核 ✅

1. 能透過 **`nano4-proxy`** 用 Antigravity 開啟 `/work/<帳號>`，而且不再輸入 OTP
2. 至少一個 Agent 能說出 `GOV115088`、`ngs62g` 與 `-c 8 --mem=62G`
3. 執行 `sacct` 查得到練習 6 的作業：

   ```bash
   sacct -X -o JobID,JobName,State,Elapsed
   ```

4. 🔒 **離開前在 proxy 視窗按 `Ctrl+C`**（尤其是共用電腦）

---

## 課後自學（選做）

| 章節 | 內容 |
| :--- | :--- |
| 第 01 章 練習 2 | 用 Port 2222 雙向傳檔（`scp -P 2222`） |
| 第 01 章 練習 4 | 用 `uv` 在 `/work` 建立 Python 環境 |
| 第 01 章 練習 6 | 用 `salloc` 進入互動式計算節點 |
| 第 01 章 §6 | 從台灣杉三號（T3）搬遷資料 |
| 第 02 章 練習 6 B | 換另一個 Agent 再做一次，比較兩個 Agent 的腳本 |

---

## 下一堂預告

**第二堂：Slurm 與我的 skill**

- 第 03 章：親手送出標準、陣列、相依作業，用 `seff` 檢查資源
- 用自然語言請 Agent 多輪完成同樣的工作，並糾正它的錯誤
- 把經驗存成**你自己的 skill**：`my-nano4-slurm`
- 第 04 章：用自己的 skill 做 FASTQ 質控，和 Agent 一起讀懂報告

📖 講義：https://gemini960114.github.io/Nano4-Docs/

# 謝謝大家！🙌
