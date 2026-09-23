---
layout: home

hero:
  name: "國網晶創26 (Nano4) GP1 生醫 HPC 教學手冊"
  text: "以 VS Code (Antigravity) 與 AI Agent 為核心工作台"
  tagline: "從 SSH/2FA 登入、Antigravity 遠端連線與三個 AI Agent，到用自然語言在 GP1 生醫節點完成 FASTQ 質控、做出自己的 Slurm skill，以及 nf-core/ampliseq 16S 真實案例"
  actions:
    - theme: brand
      text: 進入課程總綱
      link: /guide/00_course_syllabus
    - theme: alt
      text: GP1 官方使用說明
      link: https://man.twcc.ai/xOYzPATVS_aDlbuqMrwhyg

features:
  - icon: 🔑
    title: 第 01 章｜登入、2FA 與環境管理
    details: Nano4 登入節點連線 (Port 22)、IDExpert 2FA、WekaFS 高速儲存 (/work)、以 module 載入 FastQC / MultiQC 等生醫工具，並送出第一個 Slurm 作業。
    link: /guide/01_nano4_ssh_and_2fa
    linkText: 探索連線與儲存
  - icon: 💻
    title: 第 02 章｜Antigravity Remote-SSH 與三個 AI Agent
    details: 以 Antigravity Remote-SSH 連上 Nano4（搭配 ssh-proxy 只需一次 2FA 認證），裝上 Antigravity 內建 Agent、Codex、Claude Code 三個 AI Agent 並導入 AGENTS.md 治理規範，最後用一句自然語言把 FastQC / MultiQC 作業派送到計算節點。
    link: /guide/02_vscode_and_ai_tools
    linkText: 配置現代化 AI 開發環境
  - icon: 📊
    title: 第 03 章｜Slurm 語法與作業調度
    details: 本課程使用 GOV115088 → ngs62g，每個作業固定 -c 8 --mem=62G；先親手學會 sbatch、陣列與相依作業、seff 效能分析，再用自然語言請 AI Agent 完成同樣的工作，並把經驗存成自己的 skill。
    link: /guide/03_slurm_syntax_and_job_management
    linkText: 規模化調度超級算力
  - icon: 🧬
    title: 第 04 章｜AI 輔助生醫質控管線
    details: 用自己的 skill 請 AI Agent 完成 FASTQ 質控，透過連接埠轉送預覽互動報表，並和 Agent 一起讀懂品質指標；另附登入節點手動執行的對照組。
    link: /guide/04_ai_assisted_bio_pipeline
    linkText: 快速原型與數據探索
  - icon: 🚀
    title: 第 05 章｜AI Agent 自動化 Slurm 排程
    details: 引導 AI Agent 將第 04 章的質控流程重構為 Slurm 批次作業，實作事前下載離線運算 (Case A) 與計算節點直接下載 (Case B) 兩種架構。
    link: /guide/05_ai_agent_slurm_pipeline
    linkText: 實現全流程自主調度
  - icon: 🧰
    title: 第 06 章｜AI Agent 技能總匯庫 (Skills Hub)
    details: 沉澱 Nano4 領域知識為專家技能 (nano4-slurm-operations, slurm-job-advisor, ai-agent-slurm-pipeline, nfcore-ampliseq-nano4)，內建預檢與規格檢查，能抓出 sbatch --test-only 漏掉的錯誤。
    link: /guide/06_skills_hub
    linkText: 探索 AI 專家技能庫
  - icon: 🦠
    title: 第 07 章｜nf-core/ampliseq 真實 16S 案例
    details: 使用國網離線 nf-core 環境，先手動完成官方 test 與公開 paired-end 16S 分析，再讓 AI Agent 重做、比較並封裝成可重用 Skill；附講師完整示範結果供下載觀看。
    link: /guide/07_nfcore_ampliseq_case_study
    linkText: 進入完整案例
  - icon: 📜
    title: 附錄｜Nano4 專屬 AGENTS.md 守則
    details: 專為超級電腦量身定制的 AI Agent 治理規範：嚴禁 sudo、WekaFS /work 儲存分層、module purge、ngs62g 記憶體限制。
    link: /guide/agents_governance
    linkText: 查看 AI 治理守則
---
