// Generate docs/guide/*.md from the chapter READMEs, so each chapter has a
// single source of truth. Run automatically by `npm run docs:dev|docs:build`.
//
// Link rewriting (README -> VitePress page):
//   ../NN-chapter/        -> ./NN_chapter_page   (other chapter pages)
//   ../AGENTS.md          -> ./agents_governance
//   ../README.md          -> ./00_course_syllabus
//   ./file-in-chapter     -> GitHub blob URL      (tree URL when it ends in /)
import { readFileSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..')
const REPO = 'https://github.com/gemini960114/Nano4-Docs'

const CHAPTERS = {
  '01-nano4-ssh-and-2fa': '01_nano4_ssh_and_2fa',
  '02-vscode-and-ai-tools': '02_vscode_and_ai_tools',
  '03-slurm-syntax-and-job-management': '03_slurm_syntax_and_job_management',
  '04-ai-assisted-bio-pipeline': '04_ai_assisted_bio_pipeline',
  '05-ai-agent-slurm-pipeline': '05_ai_agent_slurm_pipeline',
  '06-skills-hub': '06_skills_hub',
  '07-nfcore-ampliseq-case-study': '07_nfcore_ampliseq_case_study',
}

// Rewrite the target of every markdown link `](target)`.
function rewriteLinks(markdown, rewrite) {
  return markdown.replace(/\]\(([^)\s]+)\)/g, (match, target) => {
    const next = rewrite(target)
    return next === undefined ? match : `](${next})`
  })
}

function chapterPage(target, prefix) {
  const m = target.match(new RegExp(`^${prefix}(\\d\\d-[a-z0-9-]+)/?(#.*)?$`))
  if (m && CHAPTERS[m[1]]) return `./${CHAPTERS[m[1]]}${m[2] ?? ''}`
  return undefined
}

function fromChapter(dir, target) {
  if (/^(https?:|mailto:|#)/.test(target)) return undefined
  if (target === '../AGENTS.md') return './agents_governance'
  if (target === '../README.md') return './00_course_syllabus'
  const page = chapterPage(target, '\\.\\./')
  if (page) return page
  if (target.startsWith('./')) {
    const path = target.slice(2)
    const kind = path.endsWith('/') || path === '' ? 'tree' : 'blob'
    return `${REPO}/${kind}/main/${dir}/${path.replace(/\/$/, '')}`
  }
  return undefined
}

function fromRoot(target) {
  if (/^(https?:|mailto:|#)/.test(target)) return undefined
  if (target === './AGENTS.md') return './agents_governance'
  return chapterPage(target, '\\./')
}

const write = (page, content) => {
  writeFileSync(join(ROOT, 'docs', 'guide', `${page}.md`), content)
  console.log(`synced docs/guide/${page}.md`)
}

for (const [dir, page] of Object.entries(CHAPTERS)) {
  const source = readFileSync(join(ROOT, dir, 'README.md'), 'utf8')
  write(page, rewriteLinks(source, (t) => fromChapter(dir, t)))
}

write('00_course_syllabus', rewriteLinks(readFileSync(join(ROOT, 'README.md'), 'utf8'), fromRoot))
write('agents_governance', readFileSync(join(ROOT, 'AGENTS.md'), 'utf8'))
