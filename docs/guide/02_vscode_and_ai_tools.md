# 第 02 章：VS Code Remote-SSH、AI 開發工具鏈與國網地端大模型配置

歡迎來到第 02 章！在第 01 章中，您已經掌握了登入節點 SSH 連線、雙因子認證（2FA）、WekaFS 高速儲存架構（`/home` vs `/work`）與極速 `uv` Python 環境。

但如果每次寫程式都得使用黑底白字的文字終端機（如 vim 或 nano），對於初學者來說開發門檻較高。在晶創26（Nano4）環境中，**最主流、最流暢且最推薦的現代化開發方式，就是使用您個人電腦上的 Visual Studio Code（或以 VS Code 為基礎、內建 AI Agent 的 Google Antigravity）透過「Remote - SSH」直連 Nano4**！

本章將帶您在個人電腦打造直通超級電腦的圖形化開發工作台，並在遠端環境中配置 **AI 開發工具鏈（Antigravity、ChatGPT、Gemini、Codex CLI、OpenCode CLI 與國網 Taiwan AI RAP 地端大模型 API）**，以及導入超算專屬的 **`AGENTS.md`** 治理守則，讓 AI 成為您探索超算的隨身神隊友！

---


> [!NOTE]
> 本章指令預設已完成第 01 章的 repository clone。若重新開啟終端機，先回到教材根目錄：
>
> ```bash
> cd "$HOME/Nano4-Docs"
> ```

## 📌 目錄 (Table of Contents)
- [1. 為什麼推薦 VS Code Remote-SSH？(終結黑底終端機)](#1-為什麼推薦-vs-code-remote-ssh終結黑底終端機)
- [2. 本地電腦 VS Code Remote-SSH 連線實戰 (3 分鐘速成)](#2-本地電腦-vs-code-remote-ssh-連線實戰-3-分鐘速成)
- [3. 遠端工作區必備擴充套件安裝 (Python, Jupyter, AI)](#3-遠端工作區必備擴充套件安裝-python-jupyter-ai)
- [4. AI 工具選擇與雙工具操作練習](#4-ai-工具選擇與雙工具操作練習)
- [5. 終端 AI 命令行工具配置：Codex、OpenCode 與 Antigravity](#5-終端-ai-命令行工具配置codexopencode-與-antigravity)
- [6. 國網中心地端大模型：Taiwan AI RAP 設定實務](#6-國網中心地端大模型taiwan-ai-rap-設定實務)
- [7. 國網中心支援模型清單與場景推薦](#7-國網中心支援模型清單與場景推薦)
- [8. 超算專屬 AI Agent 治理守則：AGENTS.md 實務](#8-超算專屬-ai-agent-治理守則agentsmd-實務)
- [9. 初學者動手實戰練習 (Hands-on Labs 1 ~ 4)](#9-初學者動手實戰練習-hands-on-labs-1--4)
- [10. 多登入節點與 Agent session 清理](#10-多登入節點與-agent-session-清理)
- [11. 常見踩坑與連線排錯 (FAQ)](#11-常見踩坑與連線排錯-faq)

---

## 1. 為什麼推薦 VS Code Remote-SSH？(終結黑底終端機)

在傳統超算教學中，許多人習慣在登入節點打 `vim script.py`，但對於不熟悉 Linux 快捷鍵的學員而言極易受挫。而網頁版 Code-Server 又常因瀏覽器快捷鍵衝突、記憶體佔用或網路斷線而體驗不佳。

### 🌟 VS Code Remote-SSH 的五大殺手級優勢：
1. **本地流暢度，超算核心算力**：VS Code 的介面渲染在您個人本機執行，毫無網頁版延遲；所有檔案讀寫、語法檢查與終端命令則 100% 運行在 Nano4 遠端。
2. **完整滑鼠與視窗操作**：左側是遠端檔案總管，支援拖曳上傳、點擊開啟；右側是強大的代碼編輯器與 Markdown 即時預覽。
3. **無縫整合終端機**：按下 **``Ctrl + ` ``** 即可在下方開啟遠端 Bash 終端分頁，直接提交 Slurm 作業。
4. **Jupyter Notebook 原生互動支援**：直接在 VS Code 裡點開 `.ipynb`，選擇第 01 章在 `/work` 建立好的 Python 環境作為 Kernel（需先安裝 `ipykernel`，見本章 FAQ Q3），即可進行互動式資料分析與繪圖。
5. **AI 插件完全解放**：可無縫掛載 GitHub Copilot、Cline、Roo Code 或國網地端大模型，直接在編輯器內請 AI 寫代碼與 Slurm 批次腳本。

```text
[ 學員個人電腦 (Windows / macOS / Linux) ]
   └─ 執行原生 VS Code (本地 UI, 擴充套件, 本地快捷鍵)
            │
            ▼ (加密 SSH 隧道，使用第 01 章設定之 Host nano4)
[ 晶創26 (Nano4) 登入節點 (25a-lgn01~05) ]
   ├─ VS Code Server (背景常駐運行)
   ├─ WekaFS 高速工作區 (/work/$USER)
   ├─ Python 虛擬環境 (/work/$USER/...，不放在 $HOME)
   └─ Slurm 調度命令列 (sbatch, salloc, squeue)
```

---

## 2. 本地電腦 VS Code Remote-SSH 連線實戰 (3 分鐘速成)

### 步驟 A：在個人電腦安裝 VS Code 與 Remote-SSH 套件
1. 前往 [VS Code 官網](https://code.visualstudio.com/) 下載並安裝適合您作業系統的版本。
2. 開啟 VS Code，按下快捷鍵 `Ctrl + Shift + X`（macOS 為 `Cmd + Shift + X`）開啟擴充套件市場。
3. 搜尋 **`Remote - SSH`**（由 Microsoft 官方發行），點擊 **Install (安裝)**。

> [!TIP]
> **使用 Google Antigravity（本課程推薦）**：Antigravity 以 VS Code 為基礎，介面、快捷鍵與 Remote-SSH 連線方式都與 VS Code 相同，並內建 AI Agent，可直接在連上 Nano4 的遠端工作區裡請 AI 讀程式、寫 Slurm 腳本。
> 1. 前往 [Antigravity 官網](https://antigravity.google/) 下載安裝，並以 Google 帳號登入。
> 2. 在擴充套件面板確認已有 Remote-SSH 套件（若已內建則略過安裝）。
> 3. 之後的步驟 B–D 與 VS Code 完全相同。首次連線時，Antigravity 會在 Nano4 的 `~/.antigravity-ide-server` 安裝伺服器端（VS Code 則是 `~/.vscode-server`）。

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
1. 點擊 VS Code 視窗左下角的綠色按鈕（或圖示 `><`），在上方彈出的選單中選擇：  
   👉 **`Connect to Host... (連線至主機...)`**
2. 清單中會自動列出 **`nano4`**，點擊選取它。
3. 系統會開啟新視窗並提示連線。在上方提示列選擇連線平台（選擇 **`Linux`**）。
4. 終端機或上方輸入框會彈出 2FA 選項：
   ```text
   Login method (1: Mobile APP OTP, 2: Mobile APP PUSH, 3: Email OTP): 
   ```
   輸入 **`2`** 按 Enter，解鎖手機在 **IDExpert App** 點擊「同意」；隨後輸入您的主機密碼。
5. 驗證通過後，左下角會顯示 **`SSH: nano4`**，表示您已成功穿透連線進入晶創26！

### 步驟 D：開啟遠端高速工作區
1. 點擊左側選單的「檔案總管 (Explorer)」➔ 點擊 **Open Folder (開啟資料夾)**。
2. 在上方輸入框填入您的 WekaFS 高速工作區路徑：
   ```text
   /work/your_account
   ```
   （教材 repository 位於 `/home/your_account/Nano4-Docs`；第 04 章要瀏覽教材檔案時，可用 File ➔ Open Folder 另外開啟這個資料夾。）
3. 按下確定，您就能在 VS Code 左側清單中看到所有遠端檔案與目錄！

### 步驟 E（強烈建議）：用 ssh-proxy 只做一次 2FA 認證

Nano4 的**每一條新 SSH 連線**都要輸入密碼與 OTP。VS Code / Antigravity 的 Remote-SSH 在「連線」、「Open Folder 選目錄」、「切換資料夾或重新載入視窗」時都會開新連線，所以同一堂課可能要認證好幾次。

[`ssh-proxy`](https://github.com/gemini960114/ssh-proxy) 是在**您個人電腦上**執行的小工具：它先用密碼 + OTP 連上 Nano4 並保持連線，再在本機 `127.0.0.1:2222` 開一個入口。之後 VS Code / Antigravity 改連 `nano4-proxy`，所有連線都走這條已認證的通道，不必再輸入 OTP。

```text
VS Code / Antigravity / 終端機
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
- VS Code / Antigravity：`Connect to Host...` 時選 **`nano4-proxy`**（不是 `nano4`），之後 Open Folder、切換資料夾都不必再認證。

**5. 使用注意**

- 預設**沒有任何連線 60 分鐘**或**總執行 8 小時**後，proxy 會自動停止；整天的課程可在啟動時加上 `--max-lifetime 10h`。proxy 停止後 VS Code 會斷線，重新啟動 proxy（再認證一次）並重新連線即可。
- 只在**自己的電腦**上使用：proxy 在執行期間，同一台電腦上的其他程式也能透過它連進您的帳號。使用共用電腦或離開座位前，請在 proxy 視窗按 `Ctrl+C` 停止。
- 若出現 `Address already in use`，表示已有另一個 proxy 在使用 2222 埠，請先關閉它。

---

## 3. 遠端工作區必備擴充套件安裝 (Python, Jupyter, AI)

當 VS Code 透過 Remote-SSH 連線後，擴充套件分為「本地執行」與「遠端執行（SSH: nano4）」。與程式碼執行、語法檢查相關的套件，**必須安裝在遠端主機上**。

### A. 必備遠端套件清單

| 套件類別 | 識別碼 (Extension ID) | 核心功能 |
| :--- | :--- | :--- |
| **Python 核心環境** | `ms-python.python` | Python 語法高亮、虛擬環境自動偵測 |
| **Python 除錯器** | `ms-python.debugpy` | 斷點除錯、單步執行與變數檢視 |
| **Jupyter 互動運算** | `ms-toolsai.jupyter` | 執行 `.ipynb` Notebook 的運算引擎 |
| **Jupyter 渲染器** | `ms-toolsai.jupyter-renderers` | 支援 Plotly 互動圖表與 DataFrame 表格檢視 |
| **Claude AI 助手** | `anthropic.claude-code` | Anthropic 官方 Claude 程式碼輔助工具 |
| **Roo Code / Cline** | `rooveterinaryinc.roo-cline` | 支援自訂 API (可接國網 Taiwan AI RAP) 的 AI Agent |

> ChatGPT 與 Gemini 主要在學員本機的 Web/Desktop 應用程式中使用，不需要安裝到 Nano4。Codex CLI、OpenCode CLI 才是可直接操作 repository 的終端工具。

### B. 一鍵安裝腳本 (在 VS Code 整合終端執行)

按下 **``Ctrl + ` ``** 開啟整合式終端機，執行本章隨附的安裝腳本：

```bash
cd "$HOME/Nano4-Docs/02-vscode-and-ai-tools/scripts"
bash install_vscode_extensions.sh
```

*(您也可以在 VS Code 左側 Extensions 面板中搜尋套件名稱，並點選 **Install in SSH: nano4** 安裝)*

---

## 4. AI 工具選擇與雙工具操作練習

本課程不限定只使用 OpenCode。每位學員至少選擇 **兩個 AI 工具**，對同一個 Nano4 任務進行對話、追問、修改與驗證，最後比較它們的差異。推薦組合是 **Gemini + Codex**；也可以選擇 ChatGPT + Codex、ChatGPT + OpenCode，或 Gemini + OpenCode。

| 工具 | 使用位置 | 本章練習角色 | 是否安裝到 Nano4？ |
| :--- | :--- | :--- | :---: |
| [ChatGPT](https://chatgpt.com/) | 本機 Web/Desktop | 解釋錯誤、審查腳本、提出改善方案 | 否 |
| [Gemini](https://gemini.google.com/) | 本機 Web | 第二意見、比較提示詞與分析結果 | 否 |
| [Codex CLI](https://developers.openai.com/codex/cli) | 本機或 Nano4 終端 | 讀取 repository、修改檔案、執行測試 | 可選 |
| [OpenCode](https://opencode.ai) | Nano4 終端 | 連接 Taiwan AI RAP、產生與診斷 HPC 腳本 | 是 |

### 雙工具練習流程

1. 兩個工具使用**同一份 prompt、同一份檔案與同一個問題**。
2. 先請工具說明計畫，不要立即執行破壞性指令。
3. 比較它們提出的路徑、Slurm 資源、`/work` 使用方式與錯誤處理。
4. 由學生手動選擇與合併建議，再執行 `bash -n`、`sbatch --test-only` 或小型測試。
5. 記錄工具名稱、prompt、修改內容與驗證結果，形成可重現的 AI 使用紀錄。

## 5. 終端 AI 命令行工具配置：Codex、OpenCode 與 Antigravity

除了編輯器外掛，在 HPC 終端環境中常駐 AI CLI 工具，能讓您隨時透過指令請 AI 生成代碼、修改腳本或診斷 Slurm 排程錯誤。

### A. Codex CLI
[Codex CLI](https://developers.openai.com/codex/cli) 可在終端中檢查、修改與執行 repository 內容。若在 Nano4 安裝，請使用使用者權限：

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
export PATH="${HOME}/.local/bin:${PATH}"
codex --version
```

首次執行 `codex` 會要求登入 ChatGPT / OpenAI 帳號，請依畫面指示在本機瀏覽器完成授權。因為 Codex 跑在遠端登入節點，瀏覽器授權完成後若無法回到終端機，請改用裝置碼（device code）登入，例如 `codex login --device-auth`，在本機瀏覽器輸入畫面上的代碼即可；沒有帳號的學員可改用 OpenCode + 國網 Taiwan AI RAP。

### B. OpenCode CLI
[OpenCode](https://opencode.ai) 是一個輕量、模組化且支援 OpenAI 相容協議（相容國網中心 Taiwan AI RAP API）的終端 AI 工具。

* **安裝指令**：
  ```bash
  curl -fsSL https://opencode.ai/install | bash
  ```
* **預設安裝路徑**：`~/.opencode/bin/opencode`

### C. Antigravity CLI (`agy`)
Google 出品的 Antigravity CLI 專精於複雜專案推理與多代理人排程除錯。本教材**不提供** `agy` 的安裝程式：
* **取得方式**：請依 Google Antigravity 官方說明下載，並以使用者權限放置於 `~/.local/bin/agy`（不需要 `sudo`）。
* **驗證**：`agy --version`
* 若尚未取得 `agy`，本章練習改用 Codex CLI 或 OpenCode CLI 即可，不影響後續章節。

### D. 一鍵配置 PATH
執行本章隨附的設定腳本：若尚未安裝 OpenCode 會自動安裝，並將 `~/.opencode/bin` 與 `~/.local/bin` 加入 `~/.bashrc`：
```bash
cd "$HOME/Nano4-Docs/02-vscode-and-ai-tools/scripts"
bash install_ai_cli.sh
source ~/.bashrc
```

---

## 6. 國網中心地端大模型：Taiwan AI RAP 設定實務

國網中心提供專屬的地端大模型推論服務 **[Taiwan AI RAP](https://rap.genai.nchc.org.tw/)**，讓研究人員可以直接調用高效能開源大模型，無需自行租用昂貴的商業 API！

> [!NOTE]
> Taiwan AI RAP 的前身為「Medusa / GenAI Portal」。下方設定檔中的 provider 名稱（`medusa-portal`、`medusa-inner`）與 API 網址沿用服務端的既有名稱，請照範本填寫，不需要改名。

### A. 設定檔位置：`~/.config/opencode/opencode.json`

OpenCode 原生支援多個 Provider 配置。請將本章隨附的範本複製至您的家目錄：

```bash
mkdir -p ~/.config/opencode
cp "$HOME/Nano4-Docs/02-vscode-and-ai-tools/templates/opencode.json" ~/.config/opencode/opencode.json
```

### B. 標準設定範本內容解析

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "medusa-portal": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "https://portal.genai.nchc.org.tw/api/v1/",
        "apiKey": "YOUR_MEDUSA_PORTAL_KEY"
      },
      "models": {
        "gpt-oss-120b": {
          "name": "gpt-oss-120b"
        },
        "Devstral-2-123B-Instruct-2512": {
          "name": "Devstral-2-123B-Instruct-2512"
        },
        "Ministral-3-14B-Instruct-2512": {
          "name": "Ministral-3-14B-Instruct-2512"
        }
      }
    },
    "medusa-inner": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "https://inner-medusa.genai.nchc.org.tw/v1/",
        "apiKey": "YOUR_MEDUSA_INNER_KEY"
      },
      "models": {
        "gpt-oss-120b": {
          "name": "gpt-oss-120b"
        },
        "gemma-4-26B-A4B-it": {
          "name": "gemma-4-26B-A4B-it"
        },
        "Thanos3.5-397B-A17B": {
          "name": "Thanos3.5-397B-A17B"
        }
      }
    }
  },
  "model": "medusa-inner/gemma-4-26B-A4B-it"
}
```

> [!TIP]
> 請使用 `nano ~/.config/opencode/opencode.json`，將 `YOUR_MEDUSA_PORTAL_KEY` 或 `YOUR_MEDUSA_INNER_KEY` 替換為您在 [Taiwan AI RAP](https://rap.genai.nchc.org.tw/) 取得的個人 API Token！
>
> 範本預設模型是 `medusa-inner/gemma-4-26B-A4B-it`。若您只取得 Portal Key，請把最後一行改成 `"model": "medusa-portal/gpt-oss-120b"`；`medusa-inner` 需另外取得 Inner Key。

---

## 7. 國網中心支援模型清單與場景推薦

下表與本章 `opencode.json` 範本列出的模型一致（`provider/模型` 為 OpenCode 中的選用名稱）。實際可用清單以 `opencode models` 與 Taiwan AI RAP 為準。

| OpenCode 模型名稱 | 參數量 | 特點與專長領域 | 推薦應用場景 |
| :--- | :---: | :--- | :--- |
| **`medusa-portal/Devstral-2-123B-Instruct-2512`** | 123B | 針對程式碼生成、架構重構與 Bash 排程優化 | **HPC 首選**！編寫 Slurm 腳本與 Python 管線 |
| **`medusa-portal/gpt-oss-120b`** / **`medusa-inner/gpt-oss-120b`** | 120B | OpenAI 開放權重推理模型 | 腳本審查、錯誤診斷與步驟規劃 |
| **`medusa-portal/Ministral-3-14B-Instruct-2512`** | 14B | Mistral 輕量模型，回應快 | 簡短問答與參數速查 |
| **`medusa-inner/gemma-4-26B-A4B-it`**（範本預設） | 26B | Google 輕量 MoE 模型，回應極速 | 日常問答、終端除錯與參數速查 |
| **`medusa-inner/Thanos3.5-397B-A17B`** | 397B | MoE 專家混合超大模型，繁體中文與邏輯推理強 | 複雜科研邏輯分析、論文撰寫與全案架構 |

---

## 8. 超算專屬 AI Agent 治理守則：AGENTS.md 實務

當您在 VS Code 中使用 AI 助手（如 OpenCode、Cline、Roo Code、Cursor 等）時，**AI 預設並不知道超級電腦的多人共用規範**，可能會給出危險的建議（例如建議您執行 `sudo apt install` 或在 `$HOME` 下載 50GB 模型導致 Inode 爆量）。

為了解決這個痛點，本專案在根目錄建立了 **[`AGENTS.md`](./agents_governance)** 系統守則！

### 🛡️ AGENTS.md 在 Nano4 的核心防護原則：
1. **嚴禁 `sudo`**：明確告知 AI 當前為無 root 權限之多用戶環境，任何軟體需求改以 Lmod 模組或 `uv` 虛擬環境解決。
2. **高速目錄強制導向**：所有大資料集、模型與虛擬環境一律強制寫入 `/work/$USER`，禁止塞爆 `$HOME` 或寫入無備份之 `/tmp`。
3. **登入節點行為限制**：嚴禁在登入節點執行超過 5 分鐘之重度或 GPU 運算（系統將自動清除進程），凡運算任務必須封裝為 Slurm 批次作業。
4. **Slurm 作業標準**：指示 AI 寫出的 `.slurm` 腳本執行內容第一行必須加入 `module purge`，日誌格式一律使用 `%x-%j.out`。
5. **直通外網認知**：告知 AI 晶創26計算節點原生具備外網，不要再產生舊系統過時的 HTTP Proxy 穿透指令。

---

## 9. 初學者動手實戰練習 (Hands-on Labs 1 ~ 4)

### 🧪 練習 1：在本地 VS Code 開啟遠端工作區
1. 依照第 2 節步驟，在您個人筆電打開 VS Code。
2. 透過 Remote-SSH 連線至 `nano4`。
3. 開啟 `/work/$USER` 目錄，在檔案清單中點擊右鍵新增一個檔案 `my_test.py`。
4. 寫入一行 `print("Hello from VS Code Remote on Nano4!")` 並存檔（`Ctrl + S`）。
5. 按下 **``Ctrl + ` ``** 打開整合終端，執行 `python my_test.py`，驗證程式碼確實在 Nano4 登入節點上執行！

---

### 🧪 練習 2：Gemini 與 Codex 雙工具對話比較
以同一個任務測試兩個工具：請它們解釋 `sbatch` 腳本中的 `--account`、`--partition`、`--mem`，並要求提出一個安全的修改方案。

兩個工具都使用同一支範本：`03-slurm-syntax-and-job-management/templates/standard_cpu_job.slurm`。

- Gemini：在本機開啟 [Gemini](https://gemini.google.com/)，貼上相同 prompt 與 `standard_cpu_job.slurm` 的內容（可先在 VS Code 開啟檔案後複製）。
- Codex：在登入節點的教材目錄執行：
  ```bash
  cd "$HOME/Nano4-Docs"
  codex "請先閱讀 AGENTS.md，說明 03-slurm-syntax-and-job-management/templates/standard_cpu_job.slurm 的風險，但先不要修改檔案。"
  ```

比較兩份回答的假設、資源建議與安全檢查，不直接複製任何一方的指令。

---

### 🧪 練習 3：測試 OpenCode CLI 與模型連線
1. 在 VS Code 整合終端中執行：
   ```bash
   opencode models
   ```
2. 測試向國網地端大模型提問：
   ```bash
   opencode run "請用一句話說明為什麼在 HPC 上不能使用 sudo 指令？"
   ```
3. 觀察終端機中 AI 的回答，並與練習 2 的 Gemini/Codex 結果比較。

---

### 🧪 練習 4：三方結果驗證與人工作業
先讓 Gemini、Codex 或 OpenCode 提出方案，再由學生手動執行：

```bash
cd "$HOME/Nano4-Docs"
sinfo -p ngs62g
bash -n 03-slurm-syntax-and-job-management/templates/standard_cpu_job.slurm
sbatch --test-only --account=GOV115088 03-slurm-syntax-and-job-management/templates/standard_cpu_job.slurm
```

**預期結果**：`bash -n` 沒有任何輸出，代表 shell 語法正確；`--test-only` 顯示 `Job ... to start at ...`，代表帳號與分區組合可被接受（不會真的送出作業）。

> `sbatch --test-only` **不會檢查 QoS 與官方規格**（例如 `ngs62g` 必須固定 `-c 8 --mem=62G`），這部分仍需自行對照第 01 章的佇列表。

記錄哪個工具的建議被採用、哪些建議被拒絕，以及實際驗證結果。

---

## 10. 多登入節點與 Agent session 清理

Nano4 登入節點可能把同一次 SSH/VS Code/Antigravity 連線分派到
`25a-lgn01`～`25a-lgn05` 的不同主機。若舊主機上的 VS Code Server、Codex、OpenCode、
Claude 或 Antigravity agent 沒有正常結束（本機網頁版的 ChatGPT / Gemini 不受影響），重新連線到另一台主機時可能
看起來像「session 卡住」或無法接續原本的對話。

> [!TIP]
> 使用本章步驟 E 的 `ssh-proxy` 時，所有 VS Code / Antigravity / 終端機連線都走同一條已認證的連線，會固定在同一台登入節點上，比較不會遇到這個問題。

本教材提供兩支清理腳本。它們只會處理**目前使用者自己的程序**，但會終止所有匹配的
AI/IDE agent；執行前請先儲存檔案、結束不需要保留的工作，並確認沒有正在執行的分析。

> [!WARNING]
> 請從**一般 SSH 終端機**（例如 `ssh nano4`）執行，不要在 VS Code 整合終端機內執行：腳本會連同您目前使用的 VS Code Server 一起終止，造成立即斷線。
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

清理完成後，重新啟動 VS Code Remote-SSH 或 Antigravity，讓它在目前取得的登入節點
建立新的 agent session。若某台主機無法連線，腳本會顯示警告並繼續處理其他主機。

> [!CAUTION]
> `kill_login.sh` 不是一般登出指令；它會在五台登入節點上使用 `pkill -9` 終止匹配
> 程序。不要在有重要互動工作或未保存修改時執行。

---

## 11. 常見踩坑與連線排錯 (FAQ)

### Q1：VS Code Remote-SSH 連線時卡在「Waiting for 2FA...」？
* **原因**：VS Code 在連線時，終端驗證提示有時會縮在視窗頂部或終端輸出分頁中。
* **解法**：請留意視窗頂部的文字輸入框，或點開「Output (輸出)」分頁切換至「Remote - SSH」，在提示時輸入 `2` (PUSH) 或 `1` (OTP)。

### Q2：開啟檔案總管時找不到 `/work` 目錄？
* **原因**：預設開啟的是家目錄 `$HOME`。
* **解法**：點擊選單「File ➔ Open Folder」，在路徑列手動輸入 `/work/您的帳號/` 即可。

### Q3：Jupyter Notebook 無法選擇 Python Kernel？
* **原因**：未安裝遠端 Python / Jupyter 擴充套件，或尚未啟動虛擬環境。
* **解法**：
  1. 確保已在遠端安裝 `ms-toolsai.jupyter` 與 `ms-python.python`。
  2. 確認虛擬環境已安裝 Jupyter kernel 套件（第 01 章的 `lab_env` 預設沒有）：
     ```bash
     uv pip install --python /work/${USER}/lab_env/bin/python ipykernel
     ```
  3. 點擊 Notebook 右上角的「Select Kernel ➔ Python Environments」，選擇 `/work/$USER/lab_env` 或自訂環境路徑。

---

恭喜您！現在您已經擁有了全功能、具備語法高亮、直通遠端工作區且自帶 AI 助理的現代化超算開發環境！  
👉 **下一步**：進入 **[第 03 章：Slurm 語法與作業調度](./03_slurm_syntax_and_job_management)**，學習如何撰寫 Slurm 批次腳本，把運算送到 `ngs62g` 生醫 CPU 節點！
