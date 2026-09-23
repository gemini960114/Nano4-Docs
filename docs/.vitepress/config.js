import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'
import { githubSlugify } from '../../scripts/slugify.mjs'

export default withMermaid(defineConfig({
  title: "國網晶創26 (Nano4) GP1 生醫 HPC 教學手冊",
  description: "以 VS Code (Antigravity) 與 AI Agent 為核心工作台，從登入到 nf-core 生醫管線的 GP1 全流程實戰",
  head: [
    ['link', { rel: 'icon', type: 'image/x-icon', href: 'https://www.nchc.org.tw/img/favicon.ico' }],
    ['link', { rel: 'shortcut icon', type: 'image/x-icon', href: 'https://www.nchc.org.tw/img/favicon.ico' }],
    ['meta', { name: 'theme-color', content: '#0284c7' }]
  ],
  base: '/Nano4-Docs/',
  // Fail the build on broken internal links; localhost links are demo URLs.
  ignoreDeadLinks: ['localhostLinks'],
  // GitHub-style heading ids, so README anchors work on GitHub and on this site.
  markdown: {
    anchor: { slugify: githubSlugify }
  },
  themeConfig: {
    logo: 'https://www.nchc.org.tw/img/favicon.ico',
    nav: [
      { text: '首頁', link: '/' },
      { text: '課程大綱', link: '/guide/00_course_syllabus' },
      {
        text: '章節導覽',
        items: [
          { text: '第 01 章：登入、2FA 與環境管理', link: '/guide/01_nano4_ssh_and_2fa' },
          { text: '第 02 章：VS Code Remote-SSH 與 AI 工具鏈', link: '/guide/02_vscode_and_ai_tools' },
          { text: '第 03 章：Slurm 語法與作業調度', link: '/guide/03_slurm_syntax_and_job_management' },
          { text: '第 04 章：AI 輔助生醫質控管線', link: '/guide/04_ai_assisted_bio_pipeline' },
          { text: '第 05 章：AI Agent 自動化 Slurm 排程', link: '/guide/05_ai_agent_slurm_pipeline' },
          { text: '第 06 章：AI Agent 技能總匯庫 (Skills Hub)', link: '/guide/06_skills_hub' },
          { text: '第 07 章：nf-core/ampliseq 真實 16S 案例', link: '/guide/07_nfcore_ampliseq_case_study' }
        ]
      },
      { text: 'AI 規範 (AGENTS.md)', link: '/guide/agents_governance' },
      { text: 'Nano4 官方手冊', link: 'https://man.twcc.ai/@nano4-manual/documentation' },
      { text: 'GP1 生醫節點說明', link: 'https://man.twcc.ai/xOYzPATVS_aDlbuqMrwhyg' }
    ],
    sidebar: [
      {
        text: '🚀 第一階段：起跑與建置現代化遠端工作台',
        items: [
          { text: '📌 課程總綱與學習地圖', link: '/guide/00_course_syllabus' },
          { text: '🔑 第 01 章：登入、2FA 與環境管理', link: '/guide/01_nano4_ssh_and_2fa' },
          { text: '💻 第 02 章：VS Code Remote-SSH 與 AI 工具鏈', link: '/guide/02_vscode_and_ai_tools' }
        ]
      },
      {
        text: '⚡ 第二階段：掌握超算排程調度核心',
        items: [
          { text: '📊 第 03 章：Slurm 語法與作業調度', link: '/guide/03_slurm_syntax_and_job_management' }
        ]
      },
      {
        text: '🔬 第三階段：微型原型驗證與可視化',
        items: [
          { text: '🧬 第 04 章：AI 輔助生醫質控管線', link: '/guide/04_ai_assisted_bio_pipeline' }
        ]
      },
      {
        text: '🎯 第四階段：AI 自動重構與生產級排程',
        items: [
          { text: '🚀 第 05 章：AI Agent 自動化 Slurm 排程', link: '/guide/05_ai_agent_slurm_pipeline' },
          { text: '🧰 第 06 章：AI Agent 技能總匯庫 (Skills Hub)', link: '/guide/06_skills_hub' },
          { text: '🦠 第 07 章：nf-core/ampliseq 真實 16S 案例', link: '/guide/07_nfcore_ampliseq_case_study' }
        ]
      },
      {
        text: '📜 規範與參考',
        items: [
          { text: '🛡️ Nano4 專屬 AGENTS.md 治理守則', link: '/guide/agents_governance' }
        ]
      }
    ],
    search: {
      provider: 'local'
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/gemini960114/Nano4-Docs' },
      {
        // 右上角快速入口：國網中心 GP1 生醫核心設施完整說明
        icon: { svg: '<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.8\"><path d=\"M4 4.5A2.5 2.5 0 0 1 6.5 2H20v17H6.5A2.5 2.5 0 0 0 4 21.5z\"/><path d=\"M4 4.5v17M8 6h8M8 10h8\"/></svg>' },
        link: 'https://man.twcc.ai/xOYzPATVS_aDlbuqMrwhyg',
        ariaLabel: 'GP1 生醫核心設施官方說明'
      }
    ],
    footer: {
      message: '本教學手冊深度整合國網中心官方指南與實務踩坑經驗，實際配置請以各服務官方資訊為準。',
      copyright: 'Copyright © 2026 NCHC Nano4 Tutorial'
    }
  }
}))
