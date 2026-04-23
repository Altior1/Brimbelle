# Brimbelle

Un projet de blog familial. Chaque utilisateur appartient à une ou plusieurs familles et ne voit que le contenu de sa famille.

**Stack** : Phoenix 1.8 · LiveView 1.1 · SQLite (`ecto_sqlite3`) · Bandit · Tailwind v4 · esbuild.

## Ce que va contenir le projet

### Paramètres MVP

- Identification des membres de la famille
- Les membres authentifiés peuvent rédiger un article
- Possibilité de joindre une, deux ou trois photos à un article
- Système de tags
- Chaque membre voit les posts des autres membres de sa famille
- Recherche d'un post par titre ou par tag

### Idées à soumettre

- Une section recettes
- Un planning pour les sorties de la famille

## Démarrage

Prérequis : Elixir ~> 1.15 et Erlang/OTP compatible. Sous Windows, le script `install.bat` installe les deux dans `%USERPROFILE%\.elixir-install` :

```bat
install.bat elixir@latest otp@latest
```

Ensuite :

```bash
mix setup          # deps.get + ecto.setup + assets.setup + assets.build
mix phx.server     # http://localhost:4000
```

En développement :

- `http://localhost:4000/dev/dashboard` — LiveDashboard
- `http://localhost:4000/dev/mailbox` — prévisualisation des emails Swoosh

## Commandes utiles

```bash
mix test                              # crée + migre la DB de test puis lance la suite
mix test test/path/to_test.exs        # un seul fichier
mix test test/path/to_test.exs:42     # un test précis
mix test --failed                     # rejoue les derniers échecs

mix precommit                         # compile --warning-as-errors + format + test
mix format

mix ecto.reset                        # drop + create + migrate + seed
mix ecto.migrate
```

Pipeline assets : `mix assets.build` en dev, `mix assets.deploy` en prod (avec `phx.digest`).

## Documentation du projet

- [`BACKLOG.md`](BACKLOG.md) — vision produit détaillée, stories priorisées, Icebox
- [`AGENTS.md`](AGENTS.md) — conventions **obligatoires** Phoenix 1.8 / LiveView / HEEx / Ecto (à lire avant toute contribution templates ou LiveViews)
- [`CLAUDE.md`](CLAUDE.md) — guide pour les sessions assistées par Claude Code
