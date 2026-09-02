# NotionGit template

A content-free Jekyll template for sites whose pages, navigation, and posts
are synchronized from Notion and built by GitHub Pages.

## What is included

- Reusable HTML layouts in `_layouts/` and includes in `_includes/`.
- The source stylesheet in `assets/css/main.css`.
- Empty `_data/`, `_pages/`, `_posts/`, and `assets/img/` directories kept in
  Git with `.gitkeep` placeholders for sync-managed output and media.
- Minimal `index.html`, `tags.html`, `Gemfile`, `.gitignore`, and a generic
  `_config.yml` using only GitHub Pages safe-mode plugins.

The browser output is HTML and CSS only. Dark mode follows the user's system
preference through `prefers-color-scheme`; there is no client-side JavaScript.

## Source and migration record

The presentation layer was imported from
`leandro-llosa/leandro-llosa.github.io` at master revision
`c0166c0367e8595d7ee6f60b79f7a549926e0cb7`.

Included from that revision:

- `_layouts/`, `_includes/`, and `assets/css/main.css` for reusable
  presentation.
- `index.html`, `tags.html`, and `Gemfile` for the Jekyll entry points and
  GitHub Pages dependencies.
- The structural `_config.yml` settings: Markdown, permalink, timezone,
  pages collection, defaults, safe-mode plugins, feed, and build exclusions.
- `.gitignore` and empty directory placeholders needed for local builds and
  future synchronization.

Excluded from that revision:

- `.github/workflows/sync-notion.yml` and `scripts/sync-notion.js`: workflow
  and sync implementation are separate issues.
- `_data/home.yml`, `_data/nav.yml`, `_pages/*`, and `_posts/*`: generated
  output and personal content; only empty placeholders are retained.
- `CNAME`, `about.md`, `birthday-lisi-25/`, `leandrollosa.com/`, and personal
  or custom-domain assets: these identify or belong to the source site.
- `assets/happy-birthday-lisi.png`, `assets/index-DNfK9NH7.js`, and
  `assets/index-k1yVDfyq.css`: unrelated generated application assets.
- `CLAUDE.md`, `LICENSE`, `package.json`, `package-lock.json`, `robots.txt`,
  and `sitemap.xml`: not required by this template bootstrap.
- The source `README.md`: replaced with this template-specific migration and
  verification record.
- Personal values in `_config.yml`: replaced with generic, empty defaults.
- The source theme-toggle script and its button: removed to keep generated
  pages free of client-side JavaScript; CSS system dark mode remains.

## Verify locally

```sh
bundle install
bundle exec jekyll build
git grep -n -i -E 'leandrollosa|leandro llosa|CNAME' -- . ':!README.md' || true
git diff --check
```
