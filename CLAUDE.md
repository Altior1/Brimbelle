# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Brimbelle is a Phoenix 1.8 / LiveView 1.1 web application backed by SQLite (`ecto_sqlite3`). It runs on Bandit, uses Swoosh for mail, and ships Tailwind v4 + esbuild via `mix assets.*` tasks (no `tailwind.config.js`, no daisyUI). Entry supervisor tree is in `lib/brimbelle/application.ex`.

The single domain context so far is `Brimbelle.Journal` (articles: `title`, `article`). LiveViews for it live in `lib/brimbelle_web/live/article_live/` but are not yet wired into `router.ex` — only `PageController :home` is routed.

## Commands

```bash
mix setup          # deps.get + ecto.setup + assets.setup + assets.build
mix phx.server     # run app at http://localhost:4000 (dev routes: /dev/dashboard, /dev/mailbox)
iex -S mix phx.server

mix test                     # creates+migrates test DB then runs tests
mix test test/path/to_test.exs
mix test test/path/to_test.exs:42   # single test by line
mix test --failed            # re-run last failures

mix precommit      # compile --warning-as-errors + deps.unlock --unused + format + test (run before finishing)
mix format

mix ecto.reset     # drop, create, migrate, seed
mix ecto.migrate
```

Asset pipeline: `mix assets.build` (dev) / `mix assets.deploy` (prod with `phx.digest`). Tailwind entry config key is `:brimbelle` (see `mix.exs` aliases).

## Conventions specific to this repo

- **`AGENTS.md` is authoritative** for Phoenix 1.8 / LiveView / HEEx / Ecto / form conventions — read it before writing template or LiveView code. Key points it enforces: wrap templates in `<Layouts.app flash={@flash} ...>`; use `<.icon name="hero-...">` (never `Heroicons` modules); use `<.input>` from `core_components.ex`; drive forms from `to_form/2` + `@form[:field]` (never the raw changeset); use LiveView streams for collections; `{...}` for attr/body interpolation, `<%= %>` only for block constructs in body.
- HTTP client: use `Req` (already a dep). Do not add `httpoison`, `tesla`, or `httpc`.
- Migrations auto-run at boot in releases (`RELEASE_NAME` set) via `Ecto.Migrator` in the supervision tree — don't add a separate release migration task.
- Windows dev: `install.bat` bootstraps Erlang/OTP + Elixir into `%USERPROFILE%\.elixir-install`.

## Git workflow

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the full version. Quick reference:

- **No direct commits on `master`.** Always work on a branch named `S<sprint>-T<ticket>-<slug>` (e.g. `S1-T01-phx-gen-auth`). The `.githooks/pre-commit` hook blocks direct commits on master.
- **Commit message format:** `S<sprint>-T<ticket>: <subject>` (subject ≤ 72 chars). Enforced by `.githooks/commit-msg`. The `prepare-commit-msg` hook auto-fills the ref from the branch name, so you just type the subject.
- **Hook activation (once per clone):** `git config core.hooksPath .githooks` + `chmod +x .githooks/*` on non-Windows. Without this, hooks are inert.
- **CI** (`.github/workflows/ci.yml`) runs on PRs to `master` and on pushes to `master`: `mix deps.unlock --check-unused`, `mix compile --warning-as-errors`, `mix format --check-formatted`, `mix test`. If a change passes `mix precommit` locally, CI will almost always pass.
- **Ticket IDs** in `BACKLOG.md` (`S1-T01`, `S2-T03`, etc.) are the single source of truth — same ref used in branch names, commit messages, and backlog headings.
- Merge commits, reverts, and fixup/squash commits are exempt from the commit-msg check.
