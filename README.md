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

## Provisioning ownership

`_config.yml` contains neutral metadata so the template can build before it is
provisioned. The backend owns the site URL configuration and patches `url` and
`baseurl` for the generated repository, including project-site paths. The
Notion sync owns only the published site metadata fields `title` and
`author.name`; it must not overwrite `url`, `baseurl`, or `author.email`.

The neutral metadata contract is checked by
`scripts/check-neutral-config.sh` and enforced in
`.github/workflows/template-check.yml`. That check only runs when
`github.repository == 'inkdrafts/notiongit-template'` — it asserts an
invariant of this repository, not of sites generated from it, which
legitimately have non-empty `url`/`baseurl`/`title`/`author.name` once
provisioned and synced.

## Template hygiene

CI rejects personal content and unsafe template artifacts before they can be
merged: a `CNAME` file, anything other than the documented `.gitkeep`
placeholder in `_pages/`, `_posts/`, or `_data/` (all sync-managed output),
source-site domain or identity strings, private AI-assistant files (for
example `CLAUDE.md`, `.claude/`, `AGENTS.md`, `.cursor/`), and obvious secret
patterns (API tokens, private key blocks). The scanner only inspects
tracked/staged files, reports the offending path and rule instead of any
matched secret value, and allowlists reusable docs by exact path rather than
excluding whole directories.

This is enforced by `scripts/check-hygiene.sh` (the scanner) and
`scripts/test-hygiene.sh` (fixture tests proving each forbidden artifact is
rejected), both run in `.github/workflows/template-check.yml`. Like the
neutral-config check, `check-hygiene.sh` only runs against
`inkdrafts/notiongit-template` itself — a synced site's `_pages/_posts/_data`
content is exactly what rule 2 above would otherwise reject.
`test-hygiene.sh`'s fixtures don't depend on repo state, so it still runs
everywhere.

## Branch and template contract

This repository is configured as a GitHub template and uses `main` as its
default branch. Repositories generated from it must also start on `main`.
Provisioning and workflow configuration should treat `main` as the target
branch for repository setup, synchronized content, and future GitHub Actions
references.

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
./scripts/test-hygiene.sh
./scripts/check-hygiene.sh
./scripts/check-neutral-config.sh
bundle exec jekyll build
git diff --check
```

## Cold-clone acceptance test

Local checks can't verify template generation, default branch, Actions
behavior with no secrets, or the real GitHub Pages deployment. See
[`docs/cold-clone-acceptance-test.md`](docs/cold-clone-acceptance-test.md)
and `scripts/cold-clone-acceptance-test.sh` for the repeatable procedure and
recorded evidence.
