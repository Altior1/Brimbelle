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
