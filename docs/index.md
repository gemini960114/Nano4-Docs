---
layout: home

hero:
  name: "國網晶創26 (Nano4) HPC 教學手冊"
  text: "以 VS Code Remote-SSH 與 AI Agent 為雙核心工作台"
  tagline: "從 SSH/2FA 免密碼起跑、VS Code 遠端開發、國網 Medusa 地端大模型、FASTQ 生醫質控到 Slurm 排程自動化與外網直連管線"
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
    details: Nano4 登入節點連線 (Port 22)、IDExpert 2FA、專用 DTN 傳檔 (Port 2222)、WekaFS 高速儲存 (/work) 與極速 uv 套件管理。
    link: /guide/01_nano4_ssh_and_2fa
    linkText: 探索連線與儲存
  - icon: 💻
    title: 第 02 章｜VS Code Remote-SSH 與 AI 工具鏈
    details: 本地 VS Code 免密碼遠端開發、OpenCode CLI 串接國網 Medusa 地端大模型、Antigravity CLI 與 AGENTS.md 治理規範。
    link: /guide/02_vscode_and_ai_tools
    linkText: 配置現代化 AI 開發環境
  - icon: 📊
    title: 第 03 章｜Slurm 語法精講與作業調度
    details: 官方雙架構規格詳解 (H200/GB200/NGS分區)、資源配置、wallet 計費、ngs62g 記憶體防呆、seff 效能分析與容器排程。
    link: /guide/03_slurm_syntax_and_job_management
    linkText: 規模化調度超級算力
  - icon: 🧬
    title: 第 04 章｜AI 輔助生醫質控管線
    details: 以 FASTQ 質控為跨領域通用範例，引導 AI 編寫分析流程，於登入節點微型測試並透過 VS Code 轉送即時預覽互動 HTML 報表。
    link: /guide/04_ai_assisted_bio_pipeline
    linkText: 快速原型與數據探索
  - icon: 🚀
    title: 第 05 章｜AI Agent 自動化排程管線
    details: 【全系列集大成】引導 AI Agent 自動將分析管線重構為 Slurm 批次作業，實作純離線 (Case A) 與外網直連 (Case B) 雙架構！
    link: /guide/05_ai_agent_slurm_pipeline
    linkText: 實現全流程自主調度
  - icon: 🧰
    title: 第 06 章｜Nano4 AI Agent 技能總匯庫
    details: 沉澱 Nano4 領域知識為專家技能 (nano4-slurm-operations, slurm-job-advisor, ai-agent-slurm-pipeline)，內建預檢與防呆。
    link: /guide/06_skills_hub
    linkText: 探索 AI 專家技能庫
  - icon: 🧬
    title: 第 07 章｜nf-core/ampliseq 真實 16S 案例
    details: 先手動完成官方 test 與公開 paired-end 16S 分析，再讓 AI Agent 重做、比較並封裝成可重用 Skill。
    link: /guide/07_nfcore_ampliseq_case_study
    linkText: 進入完整案例
  - icon: 📜
    title: 附錄｜Nano4 專屬 AGENTS.md 守則
    details: 專為超級電腦量身定制的 AI Agent 治理規範：嚴禁 sudo、WekaFS /work 儲存分層、module purge、ngs62g 記憶體限制。
    link: /guide/agents_governance
    linkText: 查看 AI 治理守則
---
