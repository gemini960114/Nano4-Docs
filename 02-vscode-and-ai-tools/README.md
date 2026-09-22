# HPC 實戰指南：VS Code Remote-SSH、AI 開發工具鏈與國網地端大模型配置

歡迎來到第 02 章！在第 01 章中，您已經掌握了登入節點 SSH 連線、雙因子認證（2FA）、WekaFS 高速儲存架構（`/home` vs `/work`）與極速 `uv` Python 環境。

但如果每次寫程式都得使用黑底白字的文字終端機（如 vim 或 nano），對於初學者來說開發門檻較高。在晶創26（Nano4）環境中，**最主流、最流暢且最推薦的現代化開發方式，就是使用您個人電腦上的 Visual Studio Code 透過「Remote - SSH」擴充套件直連 Nano4**！

本章將帶您在個人電腦打造直通超級電腦的圖形化開發工作台，並在遠端環境中配置 **AI 開發工具鏈（OpenCode CLI、Antigravity CLI、國網 Medusa 地端大模型 API）**，以及導入超算專屬的 **`AGENTS.md`** 治理守則，讓 AI 成為您探索超算的隨身神隊友！

---

## 📌 目錄 (Table of Contents)
- [1. 為什麼推薦 VS Code Remote-SSH？(終結黑底終端機)](#_1-為什麼推薦-vs-code-remote-ssh-終結黑底終端機)
- [2. 本地電腦 VS Code Remote-SSH 連線實戰 (3 分鐘速成)](#_2-本地電腦-vs-code-remote-ssh-連線實戰-3-分鐘速成)
- [3. 遠端工作區必備擴充套件安裝 (Python, Jupyter, AI)](#_3-遠端工作區必備擴充套件安裝-python-jupyter-ai)
- [4. 終端 AI 命令行工具配置：OpenCode CLI 與 Antigravity CLI](#_4-終端-ai-命令行工具配置-opencode-cli-與-antigravity-cli)
- [5. 國網中心地端大模型 (Medusa / GenAI API) 設定實務](#_5-國網中心地端大模型-medusa-genai-api-設定實務)
- [6. 國網中心支援模型清單與場景推薦](#_6-國網中心支援模型清單與場景推薦)
- [7. 超算專屬 AI Agent 治理守則：AGENTS.md 實務](#_7-超算專屬-ai-agent-治理守則-agents-md-實務)
- [8. 初學者動手實戰練習 (Hands-on Labs 1 ~ 3)](#_8-初學者動手實戰練習-hands-on-labs-1-3)
- [9. 常見踩坑與連線排錯 (FAQ)](#_9-常見踩坑與連線排錯-faq)

---

## 1. 為什麼推薦 VS Code Remote-SSH？(終結黑底終端機)

在傳統超算教學中，許多人習慣在登入節點打 `vim script.py`，但對於不熟悉 Linux 快捷鍵的學員而言極易受挫。而網頁版 Code-Server 又常因瀏覽器快捷鍵衝突、記憶體佔用或網路斷線而體驗不佳。

### 🌟 VS Code Remote-SSH 的五大殺手級優勢：
1. **本地流暢度，超算核心算力**：VS Code 的介面渲染在您個人本機執行，毫無網頁版延遲；所有檔案讀寫、語法檢查與終端命令則 100% 運行在 Nano4 遠端。
2. **完整滑鼠與視窗操作**：左側是遠端檔案總管，支援拖曳上傳、點擊開啟；右側是強大的代碼編輯器與 Markdown 即時預覽。
3. **無縫整合終端機**：按下 **``Ctrl + ` ``** 即可在下方開啟遠端 Bash 終端分頁，直接提交 Slurm 作業。
4. **Jupyter Notebook 原生互動支援**：直接在 VS Code 裡點開 `.ipynb`，選擇第 01 章在 `/work` 建立好的 Python Kernel，立即享受互動式資料分析與繪圖！
5. **AI 插件完全解放**：可無縫掛載 GitHub Copilot、Cline、Roo Code 或國網地端大模型，直接在編輯器內請 AI 寫代碼與 Slurm 批次腳本。

```text
[ 學員個人電腦 (Windows / macOS / Linux) ]
   └─ 執行原生 VS Code (本地 UI, 擴充套件, 本地快捷鍵)
            │
            ▼ (加密 SSH 隧道，使用第 01 章設定之 Host nano4)
[ 晶創26 (Nano4) 登入節點 (25a-lgn01~05) ]
   ├─ VS Code Server (背景常駐運行)
   ├─ WekaFS 高速工作區 (/work/$USER)
   ├─ Python 虛擬環境 (~/.venv 或 /work/$USER/...)
   └─ Slurm 調度命令列 (sbatch, salloc, squeue)
```

---

## 2. 本地電腦 VS Code Remote-SSH 連線實戰 (3 分鐘速成)

### 步驟 A：在個人電腦安裝 VS Code 與 Remote-SSH 套件
1. 前往 [VS Code 官網](https://code.visualstudio.com/) 下載並安裝適合您作業系統的版本。
2. 開啟 VS Code，按下快捷鍵 `Ctrl + Shift + X`（macOS 為 `Cmd + Shift + X`）開啟擴充套件市場。
3. 搜尋 **`Remote - SSH`**（由 Microsoft 官方發行），點擊 **Install (安裝)**。

### 步驟 B：確認本機 SSH Config 已配置
在第 01 章中，我們已經在您本機的 `~/.ssh/config` 中加入了 `nano4` 設定：
```sshconfig
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
3. 按下確定，您就能在 VS Code 左側清單中看到所有遠端檔案與目錄！

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
| **Roo Code / Cline** | `rooveterinaryinc.roo-cline` | 支援自訂 API (可接國網 Medusa) 的 AI Agent |

### B. 一鍵安裝腳本 (在 VS Code 整合終端執行)

按下 **``Ctrl + ` ``** 開啟整合式終端機，執行本章隨附的安裝腳本：

```bash
cd 02-vscode-and-ai-tools/scripts
bash install_vscode_extensions.sh
```

*(您也可以在 VS Code 左側 Extensions 面板中搜尋套件名稱，並點選 **Install in SSH: nano4** 安裝)*

---

## 4. 終端 AI 命令行工具配置：OpenCode CLI 與 Antigravity CLI

除了編輯器外掛，在 HPC 終端環境中常駐 AI CLI 工具，能讓您隨時透過指令請 AI 生成代碼、修改腳本或診斷 Slurm 排程錯誤。

### A. OpenCode CLI
[OpenCode](https://opencode.ai) 是一個輕量、模組化且支援 OpenAI 相容協議（相容國網中心 Medusa API）的終端 AI 工具。

* **安裝指令**：
  ```bash
  curl -fsSL https://opencode.ai/install.sh | bash
  ```
* **預設安裝路徑**：`~/.opencode/bin/opencode`

### B. Antigravity CLI (`agy`)
Google DeepMind 出品的 Antigravity CLI 專精於複雜專案推理與多代理人排程除錯：
* **路徑**：`~/.local/bin/agy`
* **驗證**：`agy --version`

### C. 一鍵配置 PATH
執行本章隨附的設定腳本，自動將 `~/.opencode/bin` 與 `~/.local/bin` 加入 `~/.bashrc`：
```bash
cd 02-vscode-and-ai-tools/scripts
bash install_ai_cli.sh
source ~/.bashrc
```

---

## 5. 國網中心地端大模型 (Medusa / GenAI API) 設定實務

國網中心提供專屬的地端大模型推論服務（**Medusa / GenAI Portal**），讓研究人員可以直接調用高效能開源大模型，無需自行租用昂貴的商業 API！

### A. 設定檔位置：`~/.config/opencode/opencode.json`

OpenCode 原生支援多個 Provider 配置。請將本章隨附的範本複製至您的家目錄：

```bash
mkdir -p ~/.config/opencode
cp 02-vscode-and-ai-tools/templates/opencode.json ~/.config/opencode/opencode.json
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
> 請使用 `nano ~/.config/opencode/opencode.json`，將 `YOUR_MEDUSA_PORTAL_KEY` 或 `YOUR_MEDUSA_INNER_KEY` 替換為您在國網 GenAI Portal 取得的個人 API Token！

---

## 6. 國網中心支援模型清單與場景推薦

| 模型識別名稱 | 參數量 | 特點與專長領域 | 推薦應用場景 |
| :--- | :---: | :--- | :--- |
| **`Devstral-2-123B-Instruct`** | 123B | 針對程式碼生成、架構重構與 Bash 排程深度優化 | **HPC 首選**！編寫 Slurm 腳本與 Python 管線 |
| **`gemma-4-26B-A4B-it`** | 26B | Google 輕量高智商模型，回應極速 | 日常問答、終端除錯與參數速查 |
| **`Thanos3.5-397B-A17B`** | 397B | MoE 專家混合超大模型，繁體中文與邏輯推理極強 | 複雜科研邏輯分析、論文撰寫與全案架構 |
| **`TAIDE/Llama3-TAIDE-LX-8B`** | 8B | 臺灣文化與本土用語適配模型 | 繁體中文公文、行政報告與中文資料處理 |

---

## 7. 超算專屬 AI Agent 治理守則：AGENTS.md 實務

當您在 VS Code 中使用 AI 助手（如 OpenCode、Cline、Roo Code、Cursor 等）時，**AI 預設並不知道超級電腦的多人共用規範**，可能會給出危險的建議（例如建議您執行 `sudo apt install` 或在 `$HOME` 下載 50GB 模型導致 Inode 爆量）。

為了解決這個痛點，本專案在根目錄建立了 **[`AGENTS.md`](../AGENTS.md)** 系統守則！

### 🛡️ AGENTS.md 在 Nano4 的核心防護原則：
1. **嚴禁 `sudo`**：明確告知 AI 當前為無 root 權限之多用戶環境，任何軟體需求改以 Lmod 模組或 `uv` 虛擬環境解決。
2. **高速目錄強制導向**：所有大資料集、模型與虛擬環境一律強制寫入 `/work/$USER`，禁止塞爆 `$HOME` 或寫入無備份之 `/tmp`。
3. **登入節點行為限制**：嚴禁在登入節點執行超過 5 分鐘之重度或 GPU 運算（系統將自動清除進程），凡運算任務必須封裝為 Slurm 批次作業。
4. **Slurm 作業標準**：指示 AI 寫出的 `.slurm` 腳本執行內容第一行必須加入 `module purge`，日誌格式一律使用 `%x-%j.out`。
5. **直通外網認知**：告知 AI 晶創26計算節點原生具備外網，不要再產生舊系統過時的 HTTP Proxy 穿透指令。

---

## 8. 初學者動手實戰練習 (Hands-on Labs 1 ~ 3)

### 🧪 練習 1：在本地 VS Code 開啟遠端工作區
1. 依照第 2 節步驟，在您個人筆電打開 VS Code。
2. 透過 Remote-SSH 連線至 `nano4`。
3. 開啟 `/work/$USER` 目錄，在檔案清單中點擊右鍵新增一個檔案 `my_test.py`。
4. 寫入一行 `print("Hello from VS Code Remote on Nano4!")` 並存檔（`Ctrl + S`）。
5. 按下 **``Ctrl + ` ``** 打開整合終端，執行 `python my_test.py`，驗證程式碼確實在 Nano4 登入節點上執行！

---

### 🧪 練習 2：測試 OpenCode CLI 與模型連線
1. 在 VS Code 整合終端中執行：
   ```bash
   opencode models
   ```
   確認您設定的 Provider 與模型清單正常列出。
2. 測試向國網地端大模型提問：
   ```bash
   opencode run "請用一句話說明為什麼在 HPC 上不能使用 sudo 指令？"
   ```
3. 觀察終端機中 AI 的即時回答，確認 API 串接無誤！

---

### 🧪 練習 3：召喚 AI 助手為您解讀超算狀態
在終端機中執行：
```bash
# 讓 AI 幫忙分析當前節點負載
sinfo | opencode run "這是我在 Nano4 查詢到的 sinfo 資訊，請用繁體中文幫我重點整理目前有哪些可用分區？"
```
觀察 AI 如何自動化解析超算資源，成為您的即時分析秘書！

---

## 9. 常見踩坑與連線排錯 (FAQ)

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
  2. 點擊 Notebook 右上角的「Select Kernel ➔ Python Environments」，選擇您在第 01 章建立的 `/work/$USER/lab_env` 或自訂環境路徑。

---

恭喜您！現在您已經擁有了全功能、具備語法高亮、直通遠端工作區且自帶 AI 助理的現代化超算開發環境！  
👉 **下一步**：進入 **[第 03 章：晶創26 Slurm 語法精講與超級電腦作業調度實務](../03-slurm-syntax-and-job-management/)**，學習如何精準調度數百張 H200 與 GB200 算力！
