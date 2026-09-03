# Contributing to NotionGit template

Thanks for helping maintain the reusable NotionGit Jekyll template. Keep
changes focused on the template itself: a fresh repository generated from it
must build with no personal content, custom domain, secrets, or required
Notion data.

## Development setup

Use Ruby and Bundler locally. The CI build currently uses Ruby 3.1.

```sh
bundle install
./scripts/test-hygiene.sh
./scripts/check-hygiene.sh
./scripts/check-neutral-config.sh
bundle exec jekyll build
git diff --check
git status --short
```

The build writes `_site/`, which is ignored and must not be committed. Review
the final `git status --short` output and ensure no generated or unexpected
files were added. The cold-clone procedure in
[`docs/cold-clone-acceptance-test.md`](docs/cold-clone-acceptance-test.md)
covers template generation and GitHub Pages behavior; it requires an
authenticated `gh` installation and should only use disposable repositories.

## Template boundaries

The following directories are sync-managed output. Do not add hand-written
content or fixtures to them:

- `_pages/`
- `_posts/`
- `_data/home.yml`
- `_data/nav.yml`

Keep only the existing `.gitkeep` placeholders in an otherwise clean
checkout. Do not add `CNAME`, personal posts or pages, populated generated
data, private workspace content, expiring Notion-hosted image URLs, tokens,
private keys, or private assistant configuration.

The browser runtime is deliberately pure HTML and CSS. Do not add client-side
JavaScript. Jekyll extensions must be available in GitHub Pages safe mode and
must be declared through the `github-pages`-compatible dependency set in the
`Gemfile`; do not add custom Ruby plugins.

## Licensing and generated sites

The reusable template code is released under the [MIT License](LICENSE).
That includes the layouts, includes, stylesheet, and generic template
configuration contributed here. The presentation layer was copied from the
MIT-licensed source revision documented in [`README.md`](README.md), so the
copyright and license notice must remain with substantial copies.

When this template generates a repository, the site owner retains ownership
of content they provide or sync from Notion, including posts, pages, metadata,
and media. The MIT license does not automatically relicense that content.
Owners may customize their generated repository and may reuse or redistribute
the template code under the MIT License, subject to preserving its required
notice and respecting any separate third-party terms.

The Gemfile dependencies and GitHub Actions used by this repository are
separate components. Their own licenses and notices continue to apply; this
repository's MIT license does not grant rights to third-party code beyond
those terms.

## Issues and pull requests

Open an issue for a reproducible bug, security-neutral improvement, or clearly
scoped template change. Include the expected behavior, the smallest useful
reproduction, and relevant command output. For pull requests, explain the
decision, list affected files, and record the checks you ran. Keep generated
content and unrelated refactors out of the change, and confirm that the diff
contains no secrets or personal data.

## Security reports

Please report suspected vulnerabilities privately through the repository's
[GitHub Security Advisories page](https://github.com/inkdrafts/notiongit-template/security/advisories/new).
Do not open a public issue for an unpatched vulnerability. If a secret is
accidentally committed, revoke or rotate it immediately and include only the
minimum necessary details in the private report.
