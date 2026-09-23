// GitHub-compatible heading slugs, shared by VitePress and the anchor tooling
// so README table-of-contents links work both on GitHub and on the docs site.
export function githubSlugify(text) {
  return text
    .trim()
    .toLowerCase()
    .replace(/[^\p{L}\p{M}\p{N}\p{Pc}\- ]/gu, '')
    .replace(/ /g, '-')
}
