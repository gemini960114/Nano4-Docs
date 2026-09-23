# 第 01 章：晶創26 (Nano4) 遠端連線、雙因子認證與環境配置 (SSH, 2FA & Environment)

歡迎來到高效能運算（HPC）的第一課！在開始使用超級電腦強大的 GPU/CPU 算力、搭建開發環境或提交 Slurm 排程前，第一道關卡就是：**如何安全連線進入國家高速網路與計算中心（NCHC）新一代 AI 超級電腦——晶創26（Nano4 / `nano4.nchc.org.tw`）**。

本教學專門為初次使用國網中心晶創26（Nano4）GP1 生醫節點的研究員與學生設計，詳細解析叢集架構、雙因子認證（2FA）、高速檔案傳輸（SFTP Port 2222）、WekaFS 儲存空間規劃、Lmod 模組、Apptainer 容器與極速 Python 套件管理技巧。

> [!TIP]
> **🎯 本章在全系列中的定位：雲端超算工作台的核心地基 (Core Foundation)**  
> 在晶創26（Nano4）環境中，系統不提供網頁版 Code-Server，主要透過 **終端機 SSH** 或本機 **VS Code Remote-SSH** 連線進行開發與排程調度。  
> 學習本章有兩大核心關鍵：  
> 1. **帳號家目錄初始化**：國網中心官方規定，首次啟用主機帳號時，**必須先經由 SSH 登入登入節點（`nano4.nchc.org.tw`）一次**，系統才會自動建立您的 `$HOME` 家目錄；若未執行此步驟，後續所有批次作業皆無法正常派送。  
> 2. **建立正確的運算環境觀念**：大型資料一律放在 `/work` 高速儲存區（WekaFS，注意：Nano4 高速區為 `/work`，非舊機器的 `/work1`！），並用 `module` 載入 FastQC、MultiQC 等生醫工具（計算節點沒有系統 Java，需一併載入 `biology/JDK`）。需要 Python 環境時，可再用 `uv` 在 `/work` 建立（選做）。  
> 
> 🚀 **Nano4 獨家升級優勢**：不同於舊型 HPC 叢集計算節點完全隔離無網，**晶創26（Nano4）的計算節點已具備原生外網連線能力（Direct Internet Access）**！您的批次作業在計算節點上可直接進行 `git clone`、`pip install`、從 NCBI/ENA 下載定序資料或拉取容器映像，大幅簡化生醫分析工作流！

> [!IMPORTANT]
> **本次課程採 CPU-only 配置，課程計畫為 `GOV115088`（國網生技醫藥高效能運算推廣與應用計畫）。**
> `GOV115088` 在 NGS CPU 佇列中**只允許使用 `ngs62g`**（官方規格：每個作業固定申請 **`-c 8 --mem=62G`**，不可自行增減；最長 4 天）；
> 除 `ngs62g` 以外的所有 `ngs*` 佇列（例如 `ngstest`、`ngs8g`～`ngs32g`、`ngs125g`～`ngs1000g`、`ngs248c`/`ngs496c`、`ngscourse*`、大記憶體 `ngs1500g`～`ngs6t` 與 `ngs1gpu`～`ngs8gpu`）僅開放 `MST109178` 等生醫計畫。
> 本章提到的 H200 / GB200 內容僅供認識叢集架構，本次課程不申請 GPU。

---

## 📌 目錄 (Table of Contents)
- [1. 叢集前門：晶創26 前端與資料傳輸架構 (SSH:22 vs SFTP:2222)](#1-叢集前門晶創26-前端與資料傳輸架構-ssh22-vs-sftp2222)
- [2. 前置準備：iService 申請晶創26計畫與 IDExpert 2FA 綁定](#2-前置準備iservice-申請晶創26計畫與-idexpert-2fa-綁定)
- [3. SSH 登入實戰與三種雙因子驗證方式](#3-ssh-登入實戰與三種雙因子驗證方式)
- [3-C. 取得課程教材 repository](#c-取得課程教材-repository)
- [4. 極速登入技巧：設定本地端 SSH Config](#4-極速登入技巧設定本地端-ssh-config)
- [5. 大檔案傳輸必備：資料傳輸節點 (DTN Port 2222) 實作](#5-大檔案傳輸必備資料傳輸節點-dtn-port-2222-實作)
- [6. 從台灣杉三號（T3）搬遷資料到 Nano4](#6-從台灣杉三號t3搬遷資料到-nano4)
- [7. 登入後第一步：環境健檢與三大儲存空間架構 (/home vs /work vs /project)](#7-登入後第一步環境健檢與三大儲存空間架構-home-vs-work-vs-project)
- [8. HPC 軟體環境管理：Environment Modules / Lmod (ml/module)](#8-hpc-軟體環境管理environment-modules--lmod-mlmodule)
- [9. HPC 容器化運算：Singularity / Apptainer 實務](#9-hpc-容器化運算singularity--apptainer-實務)
- [10. 現代極速 Python 套件管理：uv 實務 (解決 Inode 爆量痛點)](#10-現代極速-python-套件管理uv-實務-解決-inode-爆量痛點)
- [11. 晶創26 Slurm 資源管理與完整佇列速查 (H200, GB200 與 NGS 生醫運算)](#11-晶創26-slurm-資源管理與完整佇列速查-h200-gb200-與-ngs-生醫運算)
- [12. 初學者實戰演練：從零開始的 6 個 HPC 入門練習 (Beginner Hands-on Labs)](#12-初學者實戰演練從零開始的-6-個-hpc-入門練習-beginner-hands-on-labs)
- [13. 連線與環境常見踩坑與排錯 (FAQ)](#13-連線與環境常見踩坑與排錯-faq)

---

## 1. 叢集前門：晶創26 前端與資料傳輸架構 (SSH:22 vs SFTP:2222)

> 參考官方技術手冊：[晶創26系統架構及規格](https://man.twcc.ai/@nano4-manual/SJuKzVlwbx)、[登入與傳輸節點](https://man.twcc.ai/@nano4-manual/BydP-_lvZg)

**晶創26（Nano4）** 坐落於國網中心台南分部雲端算力機房，採用國際頂級 AI 運算架構，整合了 **220 部 NVIDIA H200 節點（共 1,760 張 GPU）** 與 **2 座 NVIDIA GB200 NVL72 運算機櫃（共 144 張 Blackwell GPU）**。

為了維護系統安全、防範網路攻擊並隔離外部存取，晶創26劃分了**專用前端節點**：

```text
[ 使用者個人電腦 (Local PC / Laptop) ]
        │
        ├── 1. 登入節點 (nano4.nchc.org.tw : Port 22 SSH) ──► 終端命令列、環境設定、微型除錯與 Slurm 排程
        └── 2. 資料傳輸節點 (nano4.nchc.org.tw : Port 2222) ─► 專用大檔案傳輸 (SFTP / SCP / rsync)，直通 WekaFS 高速儲存
                                │
        ┌───────────────────────┴───────────────────────┐
        ▼                                               ▼
[ H200 運算節點 (x86_64) ]                      [ GB200 NVL72 運算機櫃 (Arm aarch64) ]
220 節點 / 1,760 張 H200 GPU                    2 座機櫃 / 144 張 Blackwell GPU
雙路 Intel Xeon 8480+ (112核), 2TB RAM          36 顆 Grace CPU (2,592 核), NVLink 全櫃互聯
Slurm: dev, 8gpus, 16gpus, 32gpus, 64gpus       Slurm: gb200-dev, gb200-r1, gb200-r2
```

### 官方前端連線資訊表 (Front-End Endpoints)

| 節點分類 | 外部主機名稱 (FQDN) | IP 位址 | 服務 Port | 底層架構 / 掛載目錄 | 連線工具與用途 |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **登入節點**<br>(Login Node) | `nano4.nchc.org.tw` | `140.110.109.166`<br>*(內部: 25a-lgn01~05)* | **22 (SSH)** | **x86_64 架構**<br>`/home`, `/work` (WekaFS) | PuTTY, Terminal, VS Code Remote<br>(**作業排程與輕量除錯**) |
| **資料傳輸節點**<br>(DTN 專用) | `nano4.nchc.org.tw` | `140.110.109.166` | **2222 (SFTP)** | **檔案傳輸通道**<br>`/home`, `/work` (WekaFS) | WinSCP, FileZilla, Cyberduck, scp, rsync<br>(**⚠️ 僅供傳檔，不開放 Shell 指令！**) |

> [!IMPORTANT]
> **晶創26 (Nano4) 新手必知三大鐵律：**
> 1. **資料傳輸請指定 Port `2222`**：Nano4 的傳輸節點共用主機名稱 `nano4.nchc.org.tw`，但傳輸通道專用 **`Port 2222`**（非預設 22）。下達 SFTP、SCP 或 rsync 時務必指定 `-P 2222` 或 `-p 2222`。DTN 節點不開放互動式 Shell，下達 ssh 會被拒絕。
> 2. **登入節點為 x86_64，無 Arm 登入節點**：**切勿在登入節點上編譯 GB200 程式或建立 GB200 的 Python 虛擬環境**！所有 GB200（Arm aarch64）的環境建置與編譯，必須透過 Slurm 申請 `gb200-dev` 佇列取得互動式節點後執行。
> 3. **連線 IP 限制**：預設僅限**台灣境內 IP** 可透過 SSH/SFTP 連線至晶創26；若因出差或海外合作需由**境外 IP 連線**，請事先向 iService 提出特殊服務申請。

---

## 2. 前置準備：iService 申請晶創26計畫與 IDExpert 2FA 綁定

在連線前，請確認已完成以下 3 個步驟：

1. **註冊 iService 會員並加入計畫**：
   - 前往 [國網中心 iService 會員系統](https://iservice.nchc.org.tw/nchc_service/index.php) 註冊帳號。
   - 申請或加入具備晶創26計算額度的計畫（取得計畫代號；本課程使用 **`GOV115088`**，其他計畫代號形式如 `GOV113021`、`MST109178`）。
2. **啟用主機帳號與設定密碼**：
   - 在 iService 系統中建立 Linux 主機帳號（例如 `<YOUR_USERNAME>`），並設定強固密碼（英文大小寫、數字、特殊符號）。
3. **下載並綁定雙因子（2FA）App —— IDExpert**：
   - 晶創26強制要求雙因子認證以確保超算資安。
   - 請在手機 App Store / Google Play 下載安裝 **IDExpert**。
   - 依據 [iService 雙因子認證設定手冊](https://iservice.nchc.org.tw/nchc_service/nchc_service_qa_single.php?qa_code=774)，掃描 QR Code 完成與個人帳號綁定。

---

## 3. SSH 登入實戰與三種雙因子驗證方式

### A. 使用 macOS / Linux / Windows Terminal 命令列登入

在本地電腦打開終端機，執行連線指令（請將 `your_account` 替換為您的主機帳號）：

```bash
ssh your_account@nano4.nchc.org.tw
```

首次連線時，終端機會詢問是否信任主機金鑰，請輸入 `yes`。

### B. 雙因子驗證交互流程（3 種方式）

連線建立後，系統會提示選擇 2FA 登入方式：

```text
Login method (1: Mobile APP OTP, 2: Mobile APP PUSH, 3: Email OTP): 
```

| 選項 | 方式名稱 | 操作步驟與注意事項 | 推薦度 |
| :---: | :--- | :--- | :---: |
| **`1`** | **Mobile APP OTP** | 輸入 `1` 後按下 Enter。打開手機 **IDExpert App**，點選左下角「**OTP**」，輸入畫面顯示的 6 位動態密碼。 | ⭐️⭐️⭐️⭐️ |
| **`2`** | **Mobile APP PUSH** | 輸入 `2` 後按下 Enter。手機 IDExpert App 會立刻收到「**授權請求**」推播，解鎖手機點擊「同意/打勾」即可自動通過！ | ⭐️⭐️⭐️⭐️⭐️<br>**(最推薦！)** |
| **`3`** | **Email OTP** | 輸入 `3` 後按下 Enter。至註冊信箱收取「登入驗證碼通知信」，輸入信中驗證碼。 | ⭐️⭐️⭐️<br>(備援方案) |

通過 2FA 認證後，終端機會提示輸入密碼：
```text
Password: 
```
輸入您在 iService 設定的主機密碼（輸入時螢幕不會顯示任何字元，此為 Linux 正常安全設計），按下 Enter 即可成功登入！

---

### C. 取得課程教材 repository

登入成功後，先在登入節點的 `$HOME` 下載課程原始碼。程式碼與教學範本放在 `$HOME` 即可；FASTQ、模型、Nextflow work 與 container cache 則放到 `/work/${USER}`。

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

後續章節的命令大多使用絕對路徑（如 `cd "$HOME/Nano4-Docs/03-..."`）；少數相對路徑命令需先位於 `$HOME/Nano4-Docs`。重新開啟終端機時，請先執行：

```bash
cd "$HOME/Nano4-Docs"
```

## 4. 極速登入技巧：設定本地端 SSH Config

每次都要輸入完整主機名稱非常繁瑣。您可以設定本地電腦的 SSH Config，將指令縮短為 `ssh nano4`！

### 設定步驟（在您個人電腦執行）：

1. 在本地終端機編輯 `~/.ssh/config`（若檔案不存在會自動建立）：
   ```bash
   nano ~/.ssh/config
   ```
2. 貼上下列設定（本教學隨附完整範本：[`config/ssh_config_example`](https://github.com/gemini960114/Nano4-Docs/blob/main/01-nano4-ssh-and-2fa/config/ssh_config_example)）：
   ```ssh-config
   # 晶創26 (Nano4) 登入節點 (x86_64 架構)
   Host nano4
       HostName nano4.nchc.org.tw
       User your_account
       Port 22
       ServerAliveInterval 60
       ServerAliveCountMax 3

   # 晶創26 (Nano4) 資料傳輸節點 (DTN 專用，Port 2222)
   Host nano4-dtn
       HostName nano4.nchc.org.tw
       User your_account
       Port 2222
       ServerAliveInterval 60
       ServerAliveCountMax 3
   ```
3. 儲存退出（在 nano 按 `Ctrl+O` 儲存，`Ctrl+X` 退出）。
4. **一秒極速連線**：
   ```bash
   ssh nano4
   ```
   只需輸入一個指令，即刻進入 2FA 驗證流程！

> [!TIP]
> 每一條新的 SSH 連線都要重新輸入密碼與 OTP。若使用 VS Code / Antigravity Remote-SSH（連線、選目錄、切換資料夾都會重新認證），請搭配[第 02 章步驟 E 的 `ssh-proxy`](./02_vscode_and_ai_tools#步驟-e強烈建議用-ssh-proxy-只做一次-2fa-認證)，只需認證一次。

---

## 5. 大檔案傳輸必備：資料傳輸節點 (DTN Port 2222) 實作

> [!CAUTION]
> **切勿在登入節點 (Port 22) 上傳/下載數十 GB 的大型資料集！**  
> 登入節點主要負責命令列交互，頻寬受限且多人共用。傳輸大型檔案請一律連線至專屬的高速資料傳輸通道（**Data Transfer Node, Port 2222**），直通底層高速 WekaFS 檔案系統。

### 傳輸節點連線資訊：
* **主機名稱**：`nano4.nchc.org.tw` (IP: `140.110.109.166`)
* **通訊協定**：SFTP / SCP (專屬 **Port 2222**)
* **支援指令**：`sftp`、`scp`、`rsync+ssh`
* **注意**：DTN 節點不提供 Shell 互動命令列（下達 ssh 會直接斷線），專供資料檔案傳輸。

### A. 使用圖形化工具 (WinSCP / FileZilla / Cyberduck)
* **檔案協定 (Protocol)**：SFTP - SSH File Transfer Protocol
* **主機名稱 (Host)**：`nano4.nchc.org.tw`
* **連接埠 (Port)**：**`2222`** *(⚠️ 務必手動改為 2222，預設 22 會連入登入節點)*
* **使用者名稱 / 密碼**：您的 iService 主機帳號與密碼。
* 點選登入後，完成手機 IDExpert 2FA 授權，即可像操作本地資料夾般拖曳傳輸檔案。

### B. 使用命令列快速傳輸 (sftp / scp / rsync)

#### 1. 互動式 SFTP 連線
```bash
sftp -P 2222 your_account@nano4.nchc.org.tw
```
常用 SFTP 指令速查：
* `put <local_file>`：上傳檔案至遠端當前目錄（可加 `-r` 遞迴上傳資料夾）。
* `get <remote_file>`：下載檔案至本地當前目錄。
* `ls` / `cd` / `pwd`：操作遠端目錄。
* `lpwd` / `lcd`：操作本地電腦目錄。
* `quit`：退出 SFTP。

#### 2. 單一檔案或目錄 SCP 傳輸
```bash
# 上傳檔案至 /work 高速暫存工作區
scp -P 2222 dataset.tar.gz your_account@nano4.nchc.org.tw:/work/your_account/

# 下載分析結果到本地端
scp -P 2222 -r your_account@nano4.nchc.org.tw:/work/your_account/output/ ./local_results/
```

#### 3. 使用 rsync (支援斷點續傳與進度顯示，最推薦)
```bash
# 上傳本地目錄至 /work
rsync -avzP -e "ssh -p 2222" ./my_dataset/ your_account@nano4.nchc.org.tw:/work/your_account/my_dataset/

# 從 /work 下載成果至本地
rsync -avzP -e "ssh -p 2222" your_account@nano4.nchc.org.tw:/work/your_account/checkpoints/ ./local_checkpoints/
```

---


## 6. 從台灣杉三號（T3）搬遷資料到 Nano4

如果原本使用 `t3-c4.nchc.org.tw`，建議先登入 Nano4，再由 Nano4 主動連回 T3；資料先放在 `/work/$USER` 的暫存搬遷目錄，不要直接覆寫 Nano4 的 `$HOME`。以下指令中的 `<T3帳號>`（連同 `< >` 一起）請換成 **T3 的帳號**（例如 `alice@t3-c4.nchc.org.tw:/home/alice/`）；`$USER` 則是 Nano4 帳號，不用改。

> [!WARNING]
> 本節指令在 Nano4 **登入節點**執行。資料量大（數 GB 以上）或預估超過 5 分鐘時，請在 `tmux` 內執行並先向管理者確認可用的傳輸方式，避免被登入節點的程序清理機制中斷。

> [!IMPORTANT]
> 本節假設 T3 帳號可以由 Nano4 以 SSH 連線。若連線被網路政策、2FA 或主機維護阻擋，請改用國網核准的資料傳輸節點或向管理者確認，不要反覆重試造成帳號鎖定。大型搬遷前先用 `hfsquota` 確認 Nano4 `/work` 剩餘容量。

<details>
<summary><b>展開：T3 → Nano4 搬遷步驟 A–D（僅原本使用台灣杉三號的學員需要）</b></summary>

### A. 先做小範圍 dry-run

```bash
hfsquota
mkdir -p /work/$USER/t3-home-backup

# 只預覽，不會寫入資料；替換成實際 T3 帳號
rsync -avHSn --info=progress2 \
  <T3帳號>@t3-c4.nchc.org.tw:/home/<T3帳號>/ \
  /work/$USER/t3-home-backup/
```

來源路徑最後的 `/` 代表同步「目錄內容」。不要改成 `/home/<T3帳號>/*`，因為 shell 的 `*` 會漏掉 `.bashrc`、`.ssh`、`.config` 等隱藏檔案。

### B. 搬遷 T3 的 `$HOME`

確認 dry-run 清單正確後，再執行可續傳版本：

```bash
rsync -avHS --partial --info=progress2 \
  <T3帳號>@t3-c4.nchc.org.tw:/home/<T3帳號>/ \
  /work/$USER/t3-home-backup/
```

### C. 搬遷 T3 的 `/work`

```bash
mkdir -p /work/$USER/t3-work-backup
rsync -avHSn --info=progress2 \
  <T3帳號>@t3-c4.nchc.org.tw:/work/<T3帳號>/ \
  /work/$USER/t3-work-backup/

# 預覽確認後再移除 -n 執行正式同步
rsync -avHS --partial --info=progress2 \
  <T3帳號>@t3-c4.nchc.org.tw:/work/<T3帳號>/ \
  /work/$USER/t3-work-backup/
```

### D. 搬遷後驗證與安全注意事項

```bash
# 查看兩個搬遷目錄的大小
du -sh /work/$USER/t3-home-backup /work/$USER/t3-work-backup

# 需要完整 checksum 驗證時使用；大型資料集會花較久時間
# -n 代表只比對不寫入：輸出清單為空即表示兩邊內容一致。切勿移除 -n，否則 --delete 會刪除檔案
rsync -nrc --delete \
  <T3帳號>@t3-c4.nchc.org.tw:/work/<T3帳號>/ \
  /work/$USER/t3-work-backup/
```

- `rsync` 只複製資料，不會刪除 T3 原始檔；確認 Nano4 結果前不要清理 T3。
- `.ssh`、token、設定檔可能包含敏感憑證；搬到 `/work` 後不要分享，也不要把舊 `.ssh` 直接覆蓋 Nano4 的 `$HOME/.ssh`。
- `/work` 沒有備份且可能是短期工作區；完成搬遷後，將長期保存資料移到國網 GP1-4 大容量儲存服務（見第 7 節「官方 GP1 儲存政策」）。

</details>

## 7. 登入後第一步：環境健檢與三大儲存空間架構 (/home vs /work vs /project)

登入成功後，請執行本章隨附的一鍵健康檢查腳本：

```bash
cd "$HOME/Nano4-Docs/01-nano4-ssh-and-2fa/scripts"
./quick_healthcheck.sh
```

**Nano4 實機執行輸出範例：**
```text
==========================================================
 🚀 晶創26 (Nano4) 登入節點環境健檢報告 (Login Node Healthcheck)
==========================================================

[1] 節點與系統資訊：
• 當前主機名稱 (Hostname) : 25a-lgn01
• 登入使用者 (User)        : <YOUR_USERNAME>
• 作業系統版本 (OS)        : Red Hat Enterprise Linux 9.6 (Plow)
• CPU 核心數 (Cores)       : 216 核心 (Intel(R) Xeon(R) Platinum 8480+)
• 系統總記憶體 (Memory)    : 503Gi
• 登入端 GPU 配備 (GPU)    : NVIDIA H100 NVL, 95830 MiB (供前處理與除錯)

[2] 計畫與 SU 錢包餘額 (wallet)：
PROJECT_ID: GOV113021, PROJECT_NAME: LLM Taskforce Foundation 測試計畫, SU_BALANCE: 39235545.7902
PROJECT_ID: MST109178, PROJECT_NAME: 國家生醫數位資料與分析運算雲端服務平台, SU_BALANCE: 3090359.398

[3] WekaFS 高速儲存空間確認 (/home vs /work)：
• 家目錄 ($HOME)           : /home/<YOUR_USERNAME> (容量: 100G, 剩餘: 68G)
  ↳ 適用: 個人原始碼、Git 倉庫、設定檔 (請留意 Inode 額度)
• 高速暫存工作目錄 (/work)  : /work/<YOUR_USERNAME> (容量: 1.5T, 剩餘: 290G)
  ↳ 適用: 模型權重、大資料集、uv 虛擬環境 (MST 預設 1.5TB / GOV預設 100GB，無備份)
• 計畫共用目錄 (/project)   : 已掛載 (依計畫合約申請配置)

[4] 核心軟體環境與容器支援：
✅ Lmod 環境模組系統正常 (支援 ml avail / ml load)
✅ Apptainer 容器引擎已就緒: apptainer version 1.4.3-1.el9
✅ Python uv 極速套件管理器已就緒: uv 0.12.17 (x86_64-unknown-linux-gnu)

[5] Slurm 資源調度系統 (佇列概況)：
• GP1 NGS CPU 佇列: ngs62g (本課程 GOV115088，固定 -c 8 --mem=62G，96h)
                    其他 ngs* 佇列僅開放 MST109178 等生醫平台計畫
• GPU 佇列 (參考) : H200 dev/8gpus…、GB200 gb200-dev/r1/r2

[6] 登入節點外網連通性測試：
✅ 外網連線正常 (NCBI 連通)
✅ 外網連線正常 (GitHub 連通)
==========================================================
```

### 晶創26 WekaFS 高速儲存架構與配額規則

> 參考官方技術手冊：[儲存資源與目錄位置](https://man.twcc.ai/@nano4-manual/ry1hWDlPbl)

晶創26採用頂級 **WekaFS (wekafs)** 高速平行檔案系統，具備 PB 等級超大容量與極高吞吐量 I/O。

| 儲存目錄路徑 | 叢集總容量 | 計畫預設配額 | 最大可調整上限 | 主要用途與注意事項 |
| :--- | :---: | :---: | :---: | :--- |
| **`/home/$USER`**<br>(`$HOME`) | 1.6 PB | **MST/GOV/ENT/ACD: 100 GB**<br>TRI: 50 GB | 1 TB | **個人原始碼、Git 倉庫、設定檔、小型腳本**<br>⚠️ **注意 Inode 額度**：嚴禁在此存放零碎快取或 Conda 環境。<br>📌 計畫到期後資料不會自動清除，需主動申請刪除。 |
| **`/work/$USER`**<br>(⚠️ **是 `/work` 不是 `/work1`**) | 5.5 PB | **MST: 1.5 TB** 🚀<br>GOV/ENT/ACD: 100 GB<br>TRI: 50 GB | **200 TB** | **高速運算主戰場**！模型權重、大資料集、Python 虛擬環境 (`uv venv`)、運算暫存與產出。<br>⚠️ **不提供備份服務**，重要研究資料需定期下載備份！ |
| **`/project`** | 專案制 | 預設 0 TB | 300 TB | **跨成員計畫共享資料庫**（需由計畫主持人向國網額外簽約申請）。 |

#### 🔍 官方專用儲存配額查詢指令：`hfsquota`
在超級電腦上執行 `df -h` 只能看到全叢集數 PB 的檔案系統總容量，無法精準得知個人帳號的使用量與上限。  
國網中心為高速檔案系統（HFS）提供了官方查詢指令 **`hfsquota`**：

```bash
# 查詢個人 /home 與 /work 的容量使用量與 Hard Limit 硬限制
hfsquota
```

**輸出範例：**
```text
PATH                 USED      HARD LIMIT  USAGE %  STATUS
/home/<YOUR_USERNAME>    499,712 B 107,374,182,400 B       0  ACTIVE
/work/<YOUR_USERNAME>  2,240,512 B 107,374,182,400 B       0  ACTIVE
```

> [!TIP]
> **🌐 iService 網頁端 HFS 空間管理門戶 (Nano4 / Nano5 共用)**  
> 國網中心的晶創系列（Nano4 與 Nano5）底層採用共用之高速檔案系統 HFS 架構。  
> 您可隨時登入 [iService 計算資源服務網](https://iservice.nchc.org.tw/nchc_service/index.php) ➔ 點選 **會員中心** ➔ **「設定高速檔案系統 HFS (Nano5/Nano4共用)」**，進入 **HFS User Portal** 網頁查看即時空間配額、使用紀錄與申請擴充！

> [!CAUTION]
> **官方系統守則與安全警示：**
> 1. **切勿將資料存入 `/tmp`**：官方明文規定，登入節點、傳輸節點與計算節點之 `/tmp` 均屬系統暫存，隨時可能被自動清理，且可能危及節點穩定性。
> 2. **嚴禁使用 `sudo`**：HPC 為多人共享系統，一般使用者無 root 權限，請勿嘗試執行 `sudo apt` 等指令。軟體需求請使用 Lmod 模組、`uv` 或 Apptainer 容器解決。

---


### 官方 GP1 儲存政策：把「暫存」與「保存」分開

本課程依國網中心 [GP1 生醫核心設施官方說明](https://man.twcc.ai/xOYzPATVS_aDlbuqMrwhyg#%E9%AB%98%E9%80%9F%E8%A8%88%E7%AE%97%E5%84%B2%E5%AD%98%E7%A9%BA%E9%96%93) 的原則配置資料：

| 用途 | 路徑／服務 | 課程規則 |
| :--- | :--- | :--- |
| 程式碼與小型設定 | `$HOME`（`/home/$USER`） | 放 Git repository、腳本與設定；不要放 FASTQ、模型或大量快取。 |
| 運算暫存 | `/work/$USER` | 放 FASTQ、Nextflow work、container/uv cache 與暫存結果；**沒有備份**，預設權限通常是 `700`。 |
| 長期保存與共享 | GP1-4 大容量儲存服務 | 分析完成後移出 `/work`；依官方服務使用 S3/SSL 或 Aspera 傳輸，並依研究資料規範管理。 |

官方頁面列出的 `/work` 數值是計畫與申請條件的說明，不代表每個帳號都固定擁有相同容量；實際上限以 `hfsquota` 為準。新帳號可能先取得 100 GB，擴充至 1500 GB 以上可能產生費用，請先確認計畫與配額，不要把官方頁面上的 1.5 TB 或其他數值當成保證值。

```bash
# 登入後確認實際配額（不要用 df -h 代替）
hfsquota

# 確認 /work 的權限與目前使用量
stat -c '%A %n' /work/$USER
du -sh /work/$USER/* 2>/dev/null | sort -h | tail
```

> [!WARNING]
> `/work` 是短期高速工作區，不是備份區。正式資料流程應在 `provenance/` 保存 manifest、metadata、primer、參數、版本與 Slurm Job ID；分析完成後，將必要的結果與 provenance 複製到 GP1-4 大容量儲存或研究團隊核准的備份位置。不要使用 `chmod -R 777`，也不要把個資或未授權資料放到共享路徑。

## 8. HPC 軟體環境管理：Environment Modules / Lmod (ml/module)

> 參考官方技術手冊：[Modules 基本說明](https://man.twcc.ai/@nano4-manual/BJyI6dgw-g)

超級電腦由上百位研究人員共享，每個人所需的編譯器、CUDA 版本、Python 或 MPI 各不相同。為了實現「多版本共存」且「互不衝突」，晶創26採用現代化 **Lmod (Environment Modules)** 系統。

> [!NOTE]
> 指令簡寫秘訣：系統提供 **`ml`** 作為 `module` 指令的簡寫（例如 `ml avail` 等同於 `module avail`）！

### A. 常用 Modules 核心指令速查表

| 完整指令 | 極速簡寫 (`ml`) | 功能說明 | 實戰範例 |
| :--- | :--- | :--- | :--- |
| `module avail` | `ml avail` | 列出目前環境所有可用的模組清單 | `ml avail` |
| `module list` | `ml` | 列出目前已載入的模組清單 | `ml` |
| `module spider <name>` | `ml spider <name>` | 全域深度搜尋指定工具或相依套件 | `ml spider cuda` |
| `module load <name>` | `ml <name>` | 載入指定的模組環境 | `ml gcc/11.5` |
| `module unload <name>` | `ml -<name>` | 卸載指定的模組 | `ml -gcc/11.5` |
| `module purge` | `ml purge` | **清空所有已載入模組 (徹底重設環境)** | `ml purge` |
| `module show <name>` | `ml show <name>` | 查看該模組會修改哪些系統環境變數 | `ml show cuda/12.6` |

### B. 晶創26 原生主要模組資源

在晶創26上，官方已編譯好最新主流運算工具鏈：
* **編譯器 (Compilers)**：`gcc/11.5`, `gcc/12.2`, `gcc/13.2`, `oneapi/2025.1`, `x86-nvhpc/25.9`, `x86-nvhpc/26.3`
* **GPU 運算核心 (CUDA)**：`cuda/12.6`, `cuda/13.0`
* **平行運算通訊 (MPI)**：`openmpi/5.0.10-cuda12.6`, `openmpi/5.0.10-cuda13.0`
* **容器與建置工具**：`cmake/4.0.0`, `singularity/4.3.7`, `miniconda3/26.1.1`
* **領域專屬分析**：包含 GROMACS、STAR-CCM+、MATLAB R2026a，以及豐富的次世代定序生醫分析模組（`biology/Nextflow`, `biology/SAMtools`, `biology/STAR`, `biology/qiime2` 等）。

### C. 國網中心提交作業第一黃金法則

> ⚠️ **官方技術規範**：
> 撰寫 Slurm 排程腳本（`.slurm` / `.sh`）時，**執行內容第一行必須加入 `module purge`，再依該 Job 需求依序載入對應模組！**
> 
> ```bash
> #!/bin/bash
> #SBATCH -A GOV115088
> #SBATCH -p ngs62g
> #SBATCH --cpus-per-task=8
> #SBATCH --mem=62G
> 
> # 🌟 第一黃金法則：徹底清空登入端雜亂環境
> module purge
> 
> # 依 Job 需求載入模組 (本課程生醫工具位於 biology/ 階層)
> module load gcc/11.5
> module load biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC
> ```
>
> GPU 作業（本次課程不使用）則是在 H200 分區加上 `--gres=gpu:1`，並載入 `cuda/12.6`、`openmpi/5.0.10-cuda12.6` 等模組。

執行示範腳本親自體驗模組切換：
```bash
cd "$HOME/Nano4-Docs/01-nano4-ssh-and-2fa/scripts"
./demo_modules.sh
```

---

## 9. HPC 容器化運算：Singularity / Apptainer 實務

在沒有 `sudo` 權限的超級電腦上，若需要複雜的系統函式庫、特殊 Ubuntu 套件或想直接執行 NVIDIA NGC、PyTorch 官方 Docker 映像檔，最佳方案就是 **Apptainer (前身為 Singularity)**！

### A. 為什麼在 HPC 使用 Apptainer？
* 🛡️ **無權限提升漏洞**：使用者在容器內部依舊保持一般身分，不會破壞主機安全。
* ⚡ **原生支援 GPU 與 InfiniBand**：加入 `--nv` 參數即可無痛調用主機端的 NVIDIA 驅動與 GPU。
* 📦 **單一檔案 (SIF 格式)**：將整個執行環境打包為 `.sif` 檔，極易歸檔與跨節點複製。

晶創26系統已原生預載 **Apptainer 1.4.3**（`/usr/bin/apptainer` 與 `/usr/bin/singularity` 均可呼叫）。

### B. 快取目錄設定（避免塞爆 `$HOME`）
使用 Apptainer 拉取 Docker 映像檔時會產生快取，**務必將快取目錄指派至 `/work`**：
```bash
export APPTAINER_CACHEDIR="/work/${USER}/.apptainer_cache"
export SINGULARITY_CACHEDIR="/work/${USER}/.singularity_cache"
```

### C. 常用 Apptainer 指令速查

```bash
# 1. 執行 Docker Hub 映像檔（自動快取轉換為 SIF）
apptainer exec docker://alpine cat /etc/os-release

# 2.（GPU 參考，本次課程不操作）啟用 GPU 支援執行 PyTorch 容器
apptainer exec --nv docker://pytorch/pytorch:latest python -c "import torch; print('CUDA 可用:', torch.cuda.is_available())"

# 3.（參考，本次課程不操作；數 GB 映像請在 Slurm 作業中建置，勿在登入節點執行）預先建置獨立 SIF 映像檔至 /work
apptainer build /work/${USER}/my_pytorch.sif docker://pytorch/pytorch:latest

# 4.（GPU 參考，本次課程不操作）掛載高速工作區目錄執行訓練腳本
apptainer exec --nv --bind /work/${USER}:/workspace /work/${USER}/my_pytorch.sif python /workspace/train.py
```

執行本章隨附的容器示範腳本：
```bash
cd "$HOME/Nano4-Docs/01-nano4-ssh-and-2fa/scripts"
./demo_singularity.sh
```

---

## 10. 現代極速 Python 套件管理：uv 實務 (解決 Inode 爆量痛點)

在超級電腦上安裝 Python 套件最忌諱使用傳統 `conda`。因為一個 Conda 環境往往產生 5 ~ 10 萬個零碎小檔案，極易用盡 HPC 系統的 **Inode 檔案數量配額**，導致無法再建立任何新檔案。

### A. 為什麼在 HPC 強烈推薦 `uv`？
* 🚀 **超快速度**：Rust 語言開發，下載與依賴解析速度比 `pip` / `conda` 快 **10 到 100 倍**。
* 💾 **保護 Inode**：全域智慧硬連結機制，杜絕重複小檔案。
* 📦 **免管理者權限**：單一獨立執行檔，開箱即用。

### B. 晶創26 `/work` 最佳實踐

如果登入後找不到 `uv`，先在登入節點以使用者權限安裝。官方安裝程式會把執行檔放在 `~/.local/bin`；不需要、也不應該使用 `sudo`：

```bash
# 1. 讓本次 shell 可以找到 ~/.local/bin 裡的程式
export PATH="${HOME}/.local/bin:${PATH}"

# 2. 若系統尚未提供 uv，安裝至 ~/.local/bin
if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="${HOME}/.local/bin:${PATH}"
fi

uv --version
```

若希望每次登入都自動套用 PATH，可將下列設定加入 `~/.bashrc`，再重新載入：

```bash
printf '\nexport PATH="${HOME}/.local/bin:${PATH}"\n' >> ~/.bashrc
source ~/.bashrc
```

接著在晶創26上使用 `uv` 時，務必將快取與虛擬環境建置於高速工作區（`/work/$USER`）：

```bash
# 3. 將快取導向 /work (建議加入 ~/.bashrc)
export UV_CACHE_DIR="/work/${USER}/.uv_cache"

# 4. 在 /work 建立專屬虛擬環境 (通常幾秒內完成)
uv venv /work/${USER}/my_ai_env

# 5. 安裝常用資料處理套件
uv pip install --python /work/${USER}/my_ai_env/bin/python numpy pandas rich
# (PyTorch 等 GPU 套件動輒數 GB，僅供參考，本次 CPU-only 課程不安裝)

# 6. 啟動環境
source /work/${USER}/my_ai_env/bin/activate
```

> [!WARNING]
> **⚠️ 晶創26 雙架構核心注意：登入節點 (x86_64) vs GB200 (Arm aarch64)**  
> 登入節點建立的 Python 虛擬環境為 **x86_64 架構**，只能在登入節點、NGS CPU 節點（本課程的 `ngs62g`，`25a-cpn*`）與 H200 節點（`dev`, `8gpus` 等）運行！  
> **若您的作業要在 GB200 節點運行，請勿共用此環境！** 您必須先透過 `salloc` 或 `srun` 進入 `gb200-dev` 節點後，再為 Arm 建立獨立的虛擬環境（如 `/work/${USER}/venv-aarch64`）。

執行示範腳本，體驗快速建立環境：
```bash
cd "$HOME/Nano4-Docs/01-nano4-ssh-and-2fa/scripts"
./demo_uv.sh
```

---

## 11. 晶創26 Slurm 資源管理與完整佇列速查 (H200, GB200 與 NGS 生醫運算)

> 參考官方技術手冊：[Slurm 佇列](https://man.twcc.ai/@nano4-manual/SJM_FuxDWe)、[Job 提交與管理範例](https://man.twcc.ai/@nano4-manual/BkRXxZ_JMg)、[GB200 使用說明](https://man.twcc.ai/@nano4-manual/Syl9p2jPMl)

晶創26（Nano4）為了兼顧「通用 AI 訓練」、「機櫃級 Blackwell 大模型推理」以及「生物資訊 / 基因組（NGS）高通量分析」，在 Slurm 中規劃了三大類型的運算佇列（Partition）：

---

### A. 晶創26 完整 Slurm 佇列清單

<details>
<summary><b>參考：H200 與 GB200 GPU 佇列（本次 CPU-only 課程不使用，點此展開）</b></summary>

#### 1. NVIDIA H200 佇列 (通用 AI / 深度學習 / x86_64 架構)
*硬體：220 部節點 (`25a-hgpn*`)，雙路 Intel Xeon 8480+ (112核), 2TB 記憶體, 8x H200 (141GB HBM3e)*  
*⚠️ 系統限制：每張 GPU 最多可配額 12 CPU cores、200 GB 記憶體*

| 佇列名稱 (Partition) | 單一計畫可用 GPU 總數 | 最少須使用 GPU 數 | 最長執行時間 (TimeLimit) | 用戶可執行工作數 | 用戶可等候工作數 | 主要用途 |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **`dev`** | 32 | 1 | **4 小時** | 10 | 10 | **快速除錯、小規模測試與功能驗證** |
| **`8gpus`** | 32 | 1 | **48 小時 (2天)** | 8 | 10 | 單節點 1~8 卡中長模型訓練 |
| **`16gpus`** | 32 | 8 | **48 小時 (2天)** | 6 | 8 | 跨 2 節點多卡分散式訓練 |
| **`32gpus`** | 32 | 16 | **24 小時 (1天)** | 4 | 6 | 跨 4 節點中大型模型訓練 |
| **`64gpus`** | 64 | 32 | **24 小時 (1天)** | 2 | 4 | 跨 8 節點超大規模模型訓練 |
| **`256gpus`** | 256 | 64 | **12 小時** | 1 | 2 | 旗艦級千億參數大模型平行訓練 |

---

#### 2. NVIDIA GB200 NVL72 佇列 (次世代 Arm aarch64 全機櫃 NVLink 架構)
*硬體：2 座機櫃 (`25a-ggpn*`)，36 顆 Grace CPU (2,592 核), 72 顆 Blackwell GPU/櫃，整機櫃 72 卡走第五代 NVLink (900GB/s 雙向頻寬)*

| 佇列名稱 (Partition) | 單一計畫可用 GPU 總數 | 最少須使用 GPU 數 | 最長執行時間 | 主要用途與特性 |
| :--- | :---: | :---: | :---: | :--- |
| **`gb200-dev`** | 2 | 1 | **2 小時** | **Arm 開發、編譯、套件安裝與功能驗證 (必用！)** |
| **`gb200-r1`** | 32 | 16 | **24 小時 (1天)** | 機櫃內 16~32 卡超高速 NVLink 訓練 |
| **`gb200-r2`** | 72 | 32 | **12 小時** | 機櫃內 32~72 卡滿櫃 NVLink 極致訓練 |

</details>

---

#### 3. NGS 次世代定序與 CPU 計算佇列 (生醫專用節點群 `25a-cpn[01-10,16-18]`)
*硬體：13 部高密度節點，每節點 128 CPU 核心（Slurm 可排程 124 核心），1,031 GB (~1TB) 記憶體，專門提供給生醫管線與純 CPU 分析*

> [!IMPORTANT]
> **國網官方規定：每個佇列必須依表中的「CPU × 記憶體」固定搭配申請**（例如 `ngs62g` 一律 `-c 8 --mem=62G`），
> 「為確保記憶體與核心數能有效且充分利用，參數設定必須符合排程與記憶體核心數搭配與限制」。計費以核心小時計算。
> 參考：[GP1 生醫專用節點使用說明 — Partition(Queue) 資源設定](https://man.twcc.ai/xOYzPATVS_aDlbuqMrwhyg)
> 下表「計畫」欄：✅ 表示本課程計畫 `GOV115088` 可用；其餘佇列僅開放 `MST109178`、`ENT109430`。
> 以 `scontrol show partition <名稱>` 與 `sacctmgr show qos p_<名稱>` 可隨時查核最新設定。

| 佇列名稱 (Partition) | 核心數搭配 (`-c`) | 記憶體配置 (`--mem`) | 最長執行時間 | 計畫 | 適用任務與說明 |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **`ngstest`** | 1 核心 | 8 GB | **10 分鐘** | MST | **極速測試**！專供檢查生醫腳本語法、路徑與小規模測試 |
| **`ngsconsole`** | 1 核心 | 8 GB | **無限制 (infinite)** | MST | **互動式 Shell 控制台**，適合長時間互動分析 |
| **`ngs8g`** | 1 核心 | 8 GB | **48 小時 (2天)** | MST | 輕量比對、SAM/BAM 格式轉換、單執行緒質控 |
| **`ngs16g`** | 2 核心 | 16 GB | **48 小時 (2天)** | MST | 中型轉錄組比對 (STAR / HISAT2) |
| **`ngs32g`** | 4 核心 | 32 GB | **96 小時 (4天)** | MST | 外顯子定序 (WES) 變異偵測 (GATK Variant Calling) |
| **`ngs62g`** | **8 核心** | **62 GB** | **96 小時 (4天)** | ✅ **GOV115088** | **本課程主力佇列**：FASTQ 質控、擴增子分析、nf-core 子工作 |
| **`ngs125g`** | 16 核心 | 125 GB | **無限制 (infinite)** | MST | 大型單細胞 RNA-seq (Seurat/Scanpy) 矩陣運算 |
| **`ngs250g`** | 32 核心 | 250 GB | **無限制 (infinite)** | MST | 總體基因體學 (Metagenomics) 大型分類比對 (Kraken2) |
| **`ngs500g`** | 64 核心 | 500 GB | **無限制 (infinite)** | MST | 超大型癌症基因體與結構變異 (SV) 分析 |
| **`ngs1000g`** | 124 核心 | 1,000 GB (1TB) | **無限制 (infinite)** | MST | 滿節點 1TB 記憶體大型生醫資料庫建置 |
| **`ngs248c`** | 248 核心 | 節點全量 | **無限制 (infinite)** | MST | 獨佔 2 台節點 (124×2) 的高通量多核運算 |
| **`ngs496c`** | 496 核心 | 節點全量 | **無限制 (infinite)** | MST | 獨佔 4 台節點 (124×4) 的跨節點 MPI 大規模平行分析 |
| **`ngscourse8g`** | 1 核心 | 8 GB | **2 小時** | MST | 🎓 國網官方教育訓練專用 (8G 快速實習) |
| **`ngscourse32g`** | 4 核心 | 32 GB | **4 小時** | MST | 🎓 國網官方教育訓練專用 (32G 實務演練) |
| **`ngscourse125g`** | 16 核心 | 125 GB | **24 小時 (1天)** | MST | 🎓 國網官方教育訓練專用 (125G 綜合大作業) |

---

<details>
<summary><b>參考：NGS 巨型大記憶體與生醫 GPU 佇列（僅 MST109178 等生醫平台計畫，點此展開）</b></summary>

#### 4. NGS 巨型超大記憶體節點 (Fat Memory 節點群 `25a-mpn[01-02]`)
*硬體：2 部巨型節點，每節點 128 CPU 核心，**高達 6,224 GB (~6.2 TB) 實體記憶體**！（僅開放 `MST109178` 等生醫計畫）*

| 佇列名稱 (Partition) | 核心數搭配 (`-c`) | 記憶體配置 (`--mem`) | 最長執行時間 | 核心用途與適用領域 |
| :--- | :---: | :---: | :---: | :--- |
| **`ngs1500g`** | 32 核心 | 1.5 TB | **無限制 (infinite)** | 大型真菌/植物基因組從頭組裝 (De Novo Genome Assembly) |
| **`ngs2t`** | 42 核心 | 2.0 TB | **無限制 (infinite)** | 哺乳類動物超高深度定序資料重組 |
| **`ngs3t`** | 64 核心 | 3.0 TB | **無限制 (infinite)** | 人類泛基因組 (Pan-genome) 索引建置與複雜圖結構分析 |
| **`ngs6t`** | 124 核心 | **6.0 TB** 🚀 | **無限制 (infinite)** | **全國頂級 6TB 極致大記憶體**！大型多倍體物種 (小麥/甘蔗) 全基因體重組 |

---

#### 5. NGS 生醫專屬 GPU 加速佇列 (節點群 `25a-hgpn[175-177]`)
*硬體：3 部節點，配備 8 張 NVIDIA H200 GPU 與高速 InfiniBand（僅開放 `MST109178` 等生醫計畫；本次課程不使用）*

| 佇列名稱 (Partition) | 申請 GPU 數 | 最長執行時間 | 核心用途與軟體支援 |
| :--- | :---: | :---: | :--- |
| **`ngs1gpu`** | 1 GPU | **14 天 (336 小時)** 🚀 | AlphaFold 蛋白質結構預測、Cryo-EM 單顆粒三維重構 (RELION) |
| **`ngs2gpu`** | 2 GPU | **14 天 (336 小時)** | 中型生醫圖形神經網路 (GNN) 分子動力學模擬 |
| **`ngs4gpu`** | 4 GPU | **14 天 (336 小時)** | GROMACS、Amber 分子動力學多卡加速 |
| **`ngs8gpu`** | 8 GPU | **14 天 (336 小時)** | **NVIDIA Clara Parabricks**（全基因組二代定序流程由 30 小時壓縮至 30 分鐘！） |

</details>

---

## 12. 初學者實戰演練：從零開始的 6 個 HPC 入門練習 (Beginner Hands-on Labs)

如果您從未接觸過 Linux 超級電腦或 Slurm 排程系統，請完全不用擔心！本節專門為**零基礎初學者**設計，透過 6 個漸進式動手練習，帶您循序漸進解鎖超算操作。

```text
  [個人電腦思維]                                    [超級電腦 (HPC) 思維]
  滑鼠雙擊程式 ➔ 本地立即執行 ➔ 終端關閉程式中斷     登入節點寫腳本 ➔ Slurm 調度 ➔ 計算節點在背景跑 ➔ 離線安心睡覺
```

> [!NOTE]
> **💡 超算新手必備心智模型 (Mental Model)：**
> 1. **登入節點 (Login Node)** = **大樓警衛接待大廳**。您在這裡連線、查看檔案、編輯腳本、做微型測試。**嚴禁在此炒菜或跑大運算**，否則會被警衛（系統監控）強制終止！
> 2. **計算節點 (Compute Node)** = **高科技無塵工廠**。裡面有 GP1 生醫 CPU 節點（本課程使用）與 H200 / GB200 GPU 節點。一般人不能直接走進去，必須透過提交「工單（Job Script）」委派任務。
> 3. **Slurm 排程器** = **總工廠廠長**。負責審查工單、查看目前哪台機器空閒、把任務派去執行，跑完將日誌輸出到檔案通知您。

| 練習 | 內容 | 本課程 |
| :---: | :--- | :--- |
| 1 | 登入後的環境健檢 | **必做** |
| 2 | 用 Port 2222 雙向傳檔 | 選做（需要在自己電腦操作） |
| 3 | 載入生醫模組、體驗 `module purge` | **必做** |
| 4 | 用 `uv` 建立 Python 環境 | 選做（會寫 Python 的學員） |
| 5 | 第一次提交 Slurm 批次作業 | **必做** |
| 6 | `salloc` 互動式計算節點 | 建議 |

---

### 🧪 練習 1：登入後的環境探索與系統健檢

**目標**：熟悉 Linux 基礎指令，確認當前節點狀態與個人目錄。

1. 在終端機輸入下列指令，認識當前環境：
   ```bash
   # 1. 查詢我是誰
   whoami
   
   # 2. 查詢當前所在的登入節點名稱 (通常為 25a-lgn01~05)
   hostname
   
   # 3. 查詢當前所在的工作目錄路徑
   pwd
   
   # 4. 查詢個人 /home 與 /work 的配額與使用量 (不要用 df -h，它只顯示整個叢集的容量)
   hfsquota
   ```
2. 執行本章一鍵健檢腳本：
   ```bash
   cd "$HOME/Nano4-Docs/01-nano4-ssh-and-2fa/scripts"
   ./quick_healthcheck.sh
   ```
   **觀察重點**：確認 `wallet` 列出本課程計畫 `GOV115088`（上方範例輸出的 GOV113021 / MST109178 僅為示意），`/work` 的實際配額以 `hfsquota` 為準（GOV 計畫常見為 100 GB）。

---

### 🧪 練習 2：檔案雙向傳輸實戰 (利用 Port 2222)

**目標**：學會如何把本地電腦的檔案上傳到超級電腦，以及把運算成果下載回本地。

> ⚠️ **請在您的「個人本機電腦」打開終端機（不是超級電腦的連線終端）**：

1. **在本地建立一個測試檔案**：
   ```bash
   echo "Hello Nano4! This is my first file." > hello_nano4.txt
   ```
2. **上傳檔案至 Nano4 高速工作區 `/work` (記得加上 `-P 2222`)**：
   ```bash
   scp -P 2222 hello_nano4.txt your_account@nano4.nchc.org.tw:/work/your_account/
   ```
3. **切換回 Nano4 連線終端機，檢查檔案是否存在**：
   ```bash
   cat /work/$USER/hello_nano4.txt
   ```
4. **練習從 Nano4 下載產出回本地電腦**：
   ```bash
   # 在個人本機電腦執行：
   scp -P 2222 your_account@nano4.nchc.org.tw:/work/your_account/hello_nano4.txt ./downloaded_test.txt
   ```

---

### 🧪 練習 3：載入生醫模組並體驗 `module purge` (Lmod)

**目標**：學會用模組載入本課程會用到的生醫工具（FastQC、MultiQC 與它們需要的 Java），並理解為什麼 Slurm 腳本第一行要 `module purge`。

1. **清空環境，確認工具還不存在**：
   ```bash
   module purge
   command -v fastqc || echo "fastqc: 尚未載入"
   ```
2. **查詢並載入生醫模組**：
   ```bash
   module avail biology/FastQC
   module load biology/JDK/26.0.1 biology/FastQC/0.11.9 biology/MultiQC
   ```
3. **確認工具與版本**：
   ```bash
   fastqc --version      # FastQC v0.11.9
   multiqc --version     # multiqc, version 1.35
   java -version         # java version "26.0.1"
   module list           # 列出目前載入的模組
   ```
4. **再次清空，工具又不見了**：
   ```bash
   module purge
   command -v fastqc || echo "fastqc: 已隨 module purge 移除"
   ```

> [!NOTE]
> 計算節點**沒有系統 Java**。只載入 `biology/FastQC` 而沒有載入 `biology/JDK` 時，FastQC 會找不到 Java、不產生任何報告，但指令仍可能回傳成功。第 04、05 章的腳本都會一起載入這三個模組。

<details>
<summary><b>延伸（選做）：載入 GCC 編譯並執行 C 程式</b></summary>

```bash
module purge
module load gcc/11.5
cd /work/$USER
cat << 'EOF' > hello.c
#include <stdio.h>
int main() {
    printf("Hello, Nano4 HPC! GCC Version: %d.%d\n", __GNUC__, __GNUC_MINOR__);
    return 0;
}
EOF
gcc hello.c -o hello
./hello
```

</details>

---

### 🧪 練習 4：快速建立現代 Python 運算環境 (`uv`)

**目標**：不再苦等 Conda 安裝，使用 `uv` 在 `/work` 高速區秒建獨立虛擬環境。

1. **設定快取目錄至 `/work` (避免塞爆 `$HOME`)**：
   ```bash
   export UV_CACHE_DIR="/work/${USER}/.uv_cache"
   ```
2. **在 `/work` 建立專屬虛擬環境**：
   ```bash
   uv venv /work/${USER}/lab_env
   ```
3. **快速安裝常用套件**：
   ```bash
   uv pip install --python /work/${USER}/lab_env/bin/python rich requests
   ```
4. **撰寫測試腳本並啟動環境驗證**：
   ```bash
   # 啟動環境
   source /work/${USER}/lab_env/bin/activate
   
   # 測試 Python 程式
   python -c "from rich import print; print('[bold green]🎉 Python 虛擬環境啟動成功！[/bold green]')"
   
   # 離開虛擬環境
   deactivate
   ```

---

### 🧪 練習 5：生平第一次 Slurm 批次作業提交 (Batch Job)

**目標**：學會如何撰寫標準 `.slurm` 腳本、提交作業 (`sbatch`)、追蹤排程 (`squeue`)、查看日誌輸出與分析運算效率 (`seff`)。

本章節已隨附兩套現成的初學者作業範本：
* **純 CPU 生醫主力佇列**：[`01-nano4-ssh-and-2fa/scripts/sample_first_cpu_job.slurm`](https://github.com/gemini960114/Nano4-Docs/blob/main/01-nano4-ssh-and-2fa/scripts/sample_first_cpu_job.slurm)（**專門針對生醫 CPU 分區 `ngs62g`，本課程使用**）
* **NVIDIA H200 GPU 佇列**：[`01-nano4-ssh-and-2fa/scripts/sample_first_job.slurm`](https://github.com/gemini960114/Nano4-Docs/blob/main/01-nano4-ssh-and-2fa/scripts/sample_first_job.slurm)（針對 GPU 測試分區 `dev`，僅供參考）

#### 🚀 步驟 A：提交至生醫專屬 CPU 佇列 (`ngs62g`)【本課程使用】
生醫資訊工具（如 FastQC、BWA、SAMtools、QIIME 2 等）通常依賴多核心 CPU 與適量記憶體：

1. **複製 CPU 範本至您的工作區**：
   ```bash
   cp "$HOME/Nano4-Docs/01-nano4-ssh-and-2fa/scripts/sample_first_cpu_job.slurm" /work/$USER/my_first_cpu_job.slurm
   cd /work/$USER
   ```
2. **檢視腳本內容與關鍵參數**：
   ```bash
   cat my_first_cpu_job.slurm
   ```
   * 關鍵參數解析：
     - `#SBATCH --account=GOV115088`：本課程計畫代號（國網生技醫藥高效能運算推廣與應用計畫）。
     - `#SBATCH --partition=ngs62g`：**Nano4 生醫專屬 CPU 佇列**。
     - `#SBATCH --cpus-per-task=8`：分配 8 顆 CPU 核心。
     - `#SBATCH --mem=62G`：⚠️ **`ngs62g` 關鍵必填！** 國網官方規定 `ngs62g` 必須以 **`-c 8 --mem=62G`** 搭配申請。
     - *(純 CPU 佇列嚴禁加上 `--gres=gpu:1`)*
3. **提交作業**：
   ```bash
   sbatch my_first_cpu_job.slurm
   ```
   **終端機回應**：
   ```text
   Submitted batch job 422203
   ```

<details>
<summary><b>參考：H200 GPU 佇列 (dev) 提交方式【本次課程不操作】</b></summary>

#### 📎 參考：H200 GPU 佇列 (`dev`)【本次課程不操作】
一般 AI 計畫（如 `GOV113021`）日後可用 GPU 範本，提交方式如下：
```bash
cp "$HOME/Nano4-Docs/01-nano4-ssh-and-2fa/scripts/sample_first_job.slurm" /work/$USER/my_first_gpu_job.slurm
sbatch --account=<YOUR_GPU_PROJECT_ID> /work/$USER/my_first_gpu_job.slurm
```

</details>

#### 🔎 步驟 B：追蹤作業與分析效能
4. **追蹤作業即時狀態**：
   ```bash
   squeue --me
   ```
   * `ST` 為 `PD` (Pending) 表示排隊中；為 `R` (Running) 表示正在計算節點狂飆運算！
5. **作業完成後，查看輸出日誌**：
   ```bash
   cat first_cpu_job-*.out
   ```
6. **透過 `seff` 分析作業資源效益 (國網推薦優化技巧)**：
   ```bash
   seff <JOB_ID>
   ```
   * 系統會印出 CPU 利用率 (CPU Utilized) 與記憶體利用率 (Memory Efficiency)，讓您精準掌握資源！

---

### 🧪 練習 6：互動式除錯工作體驗 (`salloc` / `srun`)

**目標**：初學者在開發測試時，往往不想每改一行程式就提交一次 `sbatch`。透過互動式申請，可以直接「登入進計算節點」即時除錯！

#### 模式 1：申請純 CPU 生醫計算節點 (`ngs62g`)
適合生醫管線腳本微型除錯、Python 程式驗證：
```bash
salloc --account=GOV115088 --partition=ngs62g --nodes=1 --cpus-per-task=8 --mem=62G -t 00:30:00 srun --pty /bin/bash
```

<details>
<summary><b>參考：模式 2 — 申請 H200 GPU 測試節點 (dev)【本次課程不操作】</b></summary>

#### 模式 2（參考，本次課程不操作）：申請 NVIDIA H200 GPU 測試節點 (`dev`)
適合深度學習模型推論、CUDA 程式除錯，需使用一般 AI 計畫：
```bash
salloc --account=GOV113021 --partition=dev --nodes=1 --gres=gpu:1 --cpus-per-task=12 --mem=64G -t 00:30:00
```

</details>

#### 進入節點與退出操作：
1. **申請成功後，會直接進入計算節點的 Shell**（指令最後的 `srun --pty /bin/bash` 負責這一步）：
   ```text
   salloc: Granted job allocation 421820
   salloc: Nodes 25a-cpn01 are ready for job
   [user@25a-cpn01 ~]$
   ```
   * 若排隊中，畫面會停在 `salloc: Pending job allocation ...`，屬正常現象，等待即可。
2. **確認自己真的在計算節點上**：
   ```bash
   hostname    # 應顯示 25a-cpn*；若顯示 25a-lgn* 表示仍在登入節點
   nproc       # 應顯示 8 (申請的核心數)
   ```
3. **完成測試後，務必退出釋放資源（停止計費）**：
   ```bash
   exit
   ```
   *(提示符號回到 `25a-lgn*` 後，執行一次 `squeue --me`：清單中沒有這個作業，才代表資源已釋放)*

---

## 13. 連線與環境常見踩坑與排錯 (FAQ)

### Q1：輸入 `ssh nano4` 後一直卡住，顯示 Connection timed out？
* **原因 1**：您目前連線的網路位於**台灣境外（國外 IP）**。晶創26預設僅放行台灣境內 IP。若在國外，請透過 VPN 回台灣學術網路，或請計畫主持人至 iService 提出特殊服務申請。
* **原因 2**：貴單位防火牆阻擋了連外 Port 22，請嘗試切換手機熱點連線測試。

### Q2：使用 SFTP / WinSCP 傳輸檔案時顯示 Connection refused？
* **原因**：您誤連到 Port 22！晶創26的資料傳輸節點（DTN）**專用 Port 2222**。
* **解法**：請在 WinSCP / FileZilla 的連接埠欄位填入 **`2222`**；終端機指令請加入 `-P 2222` 或 `-e "ssh -p 2222"`。

### Q3：選擇 2. Mobile APP PUSH 後，手機一直沒收到推播？
* **解法**：手動打開手機 **IDExpert App**，進入畫面後授權請求通常會立刻彈出。若依然未收到，可按 `Ctrl+C` 中斷，重新執行 `ssh nano4` 並改選 **1. Mobile APP OTP** 輸入 6 位動態碼。

### Q4：在 GB200 上執行程式時出現 `cannot execute binary file: Exec format error`？
> 本題為 GPU 參考情境，本次 CPU-only 課程不會遇到。

* **原因**：該程式是在登入節點（x86_64）上編譯或安裝的，無法直接在 GB200（Arm aarch64）上執行！
* **解法**：使用 `srun -A <PROJECT> -p gb200-dev -N1 --gres=gpu:1 -t 02:00:00 --pty bash` 進入 GB200 節點，重新執行編譯或建立 Arm 獨立 Python 虛擬環境。

### Q5：終端機提示 `Disk quota exceeded` 無法寫入檔案？
* **原因**：家目錄（`/home`）容量或 Inode 數量已達上限（預設 100GB）。
* **解法**：執行 `hfsquota` 檢查個人配額與使用量（`df -h` 只會顯示整個叢集的容量）。將大型套件、模型權重與暫存檔移至高速工作區 `/work/$USER`。

### Q6：為什麼在超算上執行 `sudo apt install` 會被拒絕？
* **原因**：超算是數百人共用的 Linux 叢集，一般使用者不具備 root 權限以確保系統穩定與資安。
* **解法**：軟體切換請使用 `ml load` (Lmod)；Python 套件請使用 `uv venv` 安裝於 `/work`；複雜系統依賴請使用 Apptainer / Singularity 容器。

### Q7：在登入節點上執行 Python 測試程式，跑一陣子後連線中斷或程序被殺死 (Killed)？
* **原因**：**登入節點硬性安全防護機制**！國網官方明訂：**「為避免登入節點過載卡死，用戶在登入節點運行超過 5 分鐘的 GPU process 或重度運算程序，系統將會自動清除該用戶的所有 process！」**
* **解法**：超過 5 分鐘或需使用 GPU 的任務，切勿直接在登入節點執行！請使用 `salloc` 申請互動式計算節點除錯，或撰寫批次腳本透過 `sbatch` 派送至 Slurm 佇列！

---

恭喜您！完成本章後，您已經熟練掌握了晶創26（Nano4）的登入連線、Port 2222 高速傳輸、WekaFS 儲存空間規劃、Lmod 模組、Apptainer 容器化、極速 `uv` Python 環境、NGS 生醫運算佇列與 Slurm 排程調度的完整技能！  
👉 **下一步**：進入 **[第 02 章：VS Code Remote-SSH 與 AI 工具鏈](./02_vscode_and_ai_tools)**，學習如何打造現代化遠端 AI 工作台！

