# Contribuer à Brimbelle

Ce document décrit le workflow git du projet. Tous les contributeurs (humains ou agents IA) doivent le respecter.

## Setup local (une fois par clone)

Activer les hooks versionnés du projet :

```bash
git config core.hooksPath .githooks
```

Sur macOS / Linux, s'assurer que les hooks sont exécutables :

```bash
chmod +x .githooks/*
```

Sans ces deux étapes, les vérifications de format de commit et l'interdiction de commit sur `master` ne s'activent pas.

## Workflow de branche

- **Pas de commit direct sur `master`.** Toute modification passe par une branche dédiée puis une pull request.
- Une branche = un ticket du `BACKLOG.md`.
- Nommage : `S<sprint>-T<ticket>-<slug-kebab-case>`.

Exemples :

```
S1-T01-phx-gen-auth
S2-T03-editeur-blocs
S2-T04-bloc-image-upload
```

Le slug est libre, mais recommandé pour la lisibilité dans `git branch`.

Créer une branche à partir de `master` à jour :

```bash
git checkout master
git pull
git checkout -b S1-T01-phx-gen-auth
```

## Workflow de commit

Chaque message de commit doit commencer par le ref ticket :

```
S1-T01: init phx.gen.auth skeleton
S1-T01: add Accounts context tests
S2-T03: reorder blocks via Sortable hook
```

**Règles :**

- Ref ticket obligatoire en première ligne : format `S<sprint>-T<ticket>: `
- Sujet en minuscules, pas de point final, ≤ 72 caractères
- Corps libre, séparé du sujet par une ligne vide si nécessaire
- Les commits `Merge `, `Revert `, `fixup! `, `squash! ` sont exemptés

Le hook `prepare-commit-msg` pré-remplit automatiquement le ref si le nom de branche le contient — tu tapes juste le sujet après les deux points.

## Workflow pull request

1. Pousser la branche :

   ```bash
   git push -u origin S1-T01-phx-gen-auth
   ```

2. Ouvrir une PR vers `master` sur GitHub.
3. La CI exécute :
   - `mix deps.unlock --check-unused`
   - `mix compile --warning-as-errors`
   - `mix format --check-formatted`
   - `mix test`
4. Fusionner une fois la CI verte (squash recommandé quand la branche contient beaucoup de commits WIP).

## Branch protection côté GitHub

La vraie garantie contre les poussées directes sur `master` vient de la configuration GitHub, pas des hooks locaux (qui se contournent avec `--no-verify`). À activer une fois par le mainteneur :

`Settings → Branches → Add branch protection rule` pour `master` :

- [x] Require a pull request before merging
- [x] Require status checks to pass before merging → sélectionner le job `Test` de la CI
- [x] Require branches to be up to date before merging
- [x] Do not allow bypassing the above settings

## Avant de pousser

Lancer `mix precommit` localement. La CI exécute des vérifications équivalentes — économise un aller-retour si tu les passes d'abord à la maison.

```bash
mix precommit
```

## Bypass

Cas réellement exceptionnel (correction bloquante README, urgence docs) :

```bash
git commit --no-verify
```

À proscrire en temps normal. La branch protection côté GitHub bloquera de toute façon la poussée directe sur `master`.
