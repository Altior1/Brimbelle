# Backlog

## Vision

Brimbelle est un **journal familial privé**. Les utilisateurs sont authentifiés, rattachés à une ou plusieurs familles, et ne voient que le contenu de leur famille. Chaque membre peut écrire des articles composés de blocs (titre, paragraphe, citation, image — max 3 images par article) avec un éditeur drag & drop, organiser ses articles avec des tags, et rechercher par titre ou par tag. Un brouillon n'est visible que par son auteur ; un article publié est visible par tous les membres de sa famille.

Rôles :
- **Super-admin** (global) : gère users et familles via un backoffice
- **Admin famille** : peut inviter, retirer des membres, promouvoir d'autres admins
- **Membre** : peut écrire/publier, voir les articles publiés de sa famille

## Organisation en sprints

Les 11 tickets sont numérotés globalement (T01..T11) et regroupés en 4 sprints :

| Sprint | Thème | Tickets |
|---|---|---|
| **S1 — Foundation** | auth + familles | T01, T02 |
| **S2 — Content** | modèle, lecture, éditeur, image | T03, T04, T05, T06 |
| **S3 — Polish MVP** | home, tags, recherche | T07, T08, T09 |
| **S4 — Admin** | admin famille, super-admin | T10, T11 |

Chaque ticket correspond à une branche `S<sprint>-T<ticket>-<slug>` et tous ses commits sont préfixés par `S<sprint>-T<ticket>:` (voir `CONTRIBUTING.md`).

## In progress

_(aucun)_

## Ready

### [S1-T01] Authentification via `mix phx.gen.auth`
**As a** développeur **I want** un système d'auth Phoenix standard **so that** les stories suivantes aient un `current_scope` user et un cadre d'auth sur lequel s'appuyer.

### Acceptance criteria
- [ ] `mix phx.gen.auth Accounts User users` exécuté, fichiers gardés tels quels
- [ ] Migrations appliquées, routes `/users/*` fonctionnelles
- [ ] `current_scope` exposé dans les LiveViews
- [ ] Layout montre lien "Se connecter" / "Se déconnecter"
- [ ] Tests générés passent

### Out of scope
- Familles, invitations (→ S1-T02)
- Rôles (→ S1-T02)
- Restriction d'accès aux pages métier (→ S2-T04)

### Notes
- Commit propre juste après le générateur, avant tout le reste.
- `phx.gen.auth` génère déjà le pattern `current_scope` de Phoenix 1.8 — on l'étendra en S1-T02 plutôt que de le remplacer.

---

### [S1-T02] Familles, adhésions, invitations, super-admin
**As a** user **I want** appartenir à une famille (soit en créant la mienne à l'inscription, soit via un lien d'invitation) **so that** mon contenu soit scopé à cette famille et que je ne voie que le contenu de ma famille.

### Acceptance criteria

**Schémas :**
- [ ] `Brimbelle.Accounts.Family` (`id`, `name`, `inserted_at`, `updated_at`)
- [ ] `Brimbelle.Accounts.FamilyMembership` (`user_id`, `family_id`, `role :string` ∈ `~w(admin member)`, `joined_at`) — index unique sur (`user_id`, `family_id`)
- [ ] `Brimbelle.Accounts.FamilyInvitation` (`family_id`, `token :string` unique, `invited_by_id`, `used_by_id` nullable, `used_at` nullable, `expires_at :utc_datetime`)
- [ ] `User` étendu avec `is_super_admin :boolean, default: false`

**Context `Brimbelle.Accounts` étendu :**
- [ ] `create_family/2(user, attrs)` — crée la famille et une membership `admin` pour le user
- [ ] `create_invitation/2(scope, attrs)` — admin seulement, retourne `%FamilyInvitation{}` avec URL utilisable
- [ ] `accept_invitation/2(user, token)` — ajoute une membership `member`, marque l'invitation usée ; erreurs si expirée, déjà utilisée, token inconnu
- [ ] `list_memberships/1(user)`, `promote_to_admin/2(scope, membership)`, `revoke_invitation/2(scope, invitation)` (utilisées en S4-T10, définies ici)

**Flux d'inscription :**
- [ ] `/users/register?invite=TOKEN` → inscription + acceptation automatique de l'invitation
- [ ] `/users/register` sans token → inscription + création d'une nouvelle famille (formulaire demande aussi un nom de famille) ; le user devient `admin` de cette famille
- [ ] Invariant : après inscription, un user a **toujours** au moins une membership

**Scope étendu :**
- [ ] `%Scope{user: user, membership: active_membership}` — pour MVP, `active_membership` = la seule membership du user
- [ ] Plug `:assign_current_scope` charge la membership et l'attache au scope
- [ ] Helper `Scope.family/1` renvoie `membership.family` pour usage en template et en query

**UI minimale (admin famille uniquement) :**
- [ ] Page `/family/invitations/new` : bouton "Générer un lien d'invitation" → affiche l'URL avec token
- [ ] L'URL est copiable mais n'est pas envoyée par email (partage hors app au MVP)

**Tests :**
- [ ] Création de famille à l'inscription sans token
- [ ] Acceptation d'invitation valide
- [ ] Refus si token invalide / expiré / déjà utilisé
- [ ] Un user non-admin ne peut pas générer d'invitation

### Out of scope
- Sélecteur de famille dans l'UI (1 seule famille visible = pas de choix à faire au MVP)
- Invitation par email via Swoosh (→ Icebox)
- Gestion des membres (liste, retrait) (→ S4-T10)
- Backoffice super-admin (→ S4-T11)

### Notes
- Schéma multi-famille (table `family_memberships`) dès maintenant pour ne pas bloquer le futur, même si l'UI ne gère qu'une famille par user.
- `expires_at` : 7 jours par défaut. À rendre configurable plus tard si besoin.
- Pas de "magic link" email, pas d'OAuth — juste email+password via `phx.gen.auth`.

---

### [S2-T03] Modèle article avec blocs et scoping famille
**As a** développeur **I want** que les articles appartiennent à une famille (et un auteur), soient composés de blocs ordonnés, et soient filtrables par état de publication **so that** les stories d'éditeur et de lecture aient un modèle de données propre.

### Acceptance criteria

**Migrations :**
- [ ] Drop de la colonne `articles.article`
- [ ] Ajout `articles.family_id` (references, not null, index)
- [ ] Ajout `articles.author_id` (references users, not null)
- [ ] Ajout `articles.published_at :utc_datetime` (nullable)
- [ ] Ajout `articles.slug :string` + index unique sur (`family_id`, `slug`)
- [ ] Création table `blocks` (`id`, `article_id` references, `type :string`, `position :integer`, `data :map`, timestamps)

**Schémas :**
- [ ] `Article` : `belongs_to :family`, `belongs_to :author, User`, `has_many :blocks, preload_order: [asc: :position]`
- [ ] `Block` : `belongs_to :article`, changeset valide `type ∈ ~w(heading paragraph quote)`, valide `data` selon type (pattern match ou validation custom)
- [ ] Changeset Article : `family_id` et `author_id` **jamais** dans `cast`, toujours passés via struct init (règle `AGENTS.md`)

**Context `Brimbelle.Journal` : toutes les fonctions prennent un `Scope` en 1er argument.**
- [ ] `list_articles(scope)` — articles de la famille du scope, publiés ou brouillons de l'auteur courant
- [ ] `list_published_articles(scope, limit \\ nil)` — publiés uniquement, `published_at DESC`
- [ ] `list_drafts(scope)` — brouillons du user courant dans sa famille
- [ ] `get_article!(scope, slug)` — 404 si pas dans la famille du scope ou brouillon d'un autre user
- [ ] `create_article(scope, attrs)` — `family_id` et `author_id` imposés par le scope
- [ ] `update_article(scope, article, attrs)` — autorise si auteur OU admin famille (voir notes)
- [ ] `delete_article(scope, article)` — même règle
- [ ] `add_block/3`, `update_block/3`, `delete_block/2`, `reorder_blocks/3(scope, article, ids)` — scope obligatoire

**Tests :**
- [ ] Scoping : un user d'une famille A ne voit pas les articles de la famille B
- [ ] Brouillons : un user ne voit pas les brouillons d'un autre membre
- [ ] Règle d'édition : auteur OK, admin famille OK, autre membre KO
- [ ] Reorder met à jour `position` correctement

### Out of scope
- Type `image` (→ S2-T06)
- UI (→ S2-T04, S2-T05)

### Notes
- **Décision règle d'édition** : auteur + admin famille peuvent éditer/supprimer un article publié. Brouillons = auteur seul. À reconfirmer si trop permissif.
- `data` JSON par type : `heading` → `%{level: 2, text: "..."}`, `paragraph` → `%{text: "..."}`, `quote` → `%{text: "...", cite: "..."}`.
- Slug auto-généré du titre, unique dans la famille (pas globalement — deux familles peuvent avoir un article `/hello-world` chacune).

---

### [S2-T04] Feed famille et lecture d'article (auth-only)
**As a** membre d'une famille authentifié **I want** voir la liste des articles publiés de ma famille et lire un article **so that** je consomme le contenu de ma famille.

### Acceptance criteria
- [ ] Toutes les routes de lecture sont dans un `live_session :require_authenticated` (redirect login si anonyme)
- [ ] `GET /articles` → `ArticleLive.Index`, liste des publiés de la famille du scope + section "Mes brouillons" pour l'auteur courant
- [ ] `GET /articles/:slug` → `ArticleLive.Show`, rend titre + blocs (heading, paragraph, quote) — composants dédiés dans `core_components.ex`
- [ ] 404 si slug inconnu, brouillon d'un autre user, ou article d'une autre famille
- [ ] Typographie lisible (~65ch, hiérarchie claire), pas de texte "developer-flavored"
- [ ] Tests : isolation inter-familles, 404 sur brouillon d'autrui, rendu des 3 types de blocs

### Out of scope
- Bloc image (→ S2-T06)
- Édition (→ S2-T05)
- Home page (→ S3-T07)

### Notes
- Dépend de S1-T01, S1-T02, S2-T03.
- Les composants de rendu de bloc seront réutilisés par l'éditeur (preview).

---

### [S2-T05] Éditeur d'articles avec blocs et drag & drop
**As a** membre authentifié **I want** créer/éditer un article en composant des blocs (heading, paragraph, quote) que je peux réordonner par glisser-déposer **so that** je compose visuellement un contenu structuré.

### Acceptance criteria
- [ ] `GET /articles/new` et `GET /articles/:slug/edit` protégées par auth
- [ ] `ArticleLive.Form` refondu : champ titre + liste de blocs éditables + bouton "Ajouter un bloc" (menu avec les 3 types)
- [ ] Chaque bloc éditable en place (inputs conditionnels selon type), bouton supprimer
- [ ] Drag & drop via Sortable.js + hook LiveView ; `onEnd` émet `pushEvent("reorder", ...)` qui appelle `Journal.reorder_blocks/3`
- [ ] Conteneur géré par le hook : `phx-update="ignore"` obligatoire (règle `AGENTS.md`)
- [ ] Slug auto-généré du titre à la création, modifiable à l'édition avec vérif unicité dans la famille
- [ ] Règle d'autorisation : auteur ou admin famille
- [ ] Tests LiveView : ajout, édition, suppression, reorder (événement simulé), erreur d'autorisation

### Out of scope
- Bloc image (→ S2-T06)
- Publication / brouillon (→ S3-T07)
- Preview fidèle (→ Icebox)

### Notes
- Dépend de S2-T03 et S2-T04 (composants de rendu réutilisés).
- Sortable.js importé via `assets/js/app.js` (pas de `<script>` inline — règle `AGENTS.md`).
- Pas de LiveComponent par bloc : switch sur type dans la LiveView parente.

---

### [S2-T06] Bloc image avec upload (max 3 par article)
**As a** membre authentifié **I want** insérer jusqu'à 3 blocs image avec upload de fichier, légende et alt text **so that** mes articles puissent contenir des visuels sans devenir une galerie lourde.

### Acceptance criteria
- [ ] Type `image` ajouté au changeset Block ; `data` contient `path`, `alt`, `caption`
- [ ] Upload via `Phoenix.LiveView.allow_upload/3`, stockage `priv/uploads/family_<id>/article_<id>/`
- [ ] Limite 5 Mo par fichier, types `image/jpeg`, `image/png`, `image/webp`
- [ ] **Max 3 blocs `image` par article** : côté éditeur, bouton "Ajouter bloc image" grisé/caché quand le 3e est présent ; côté context, `add_block/3` refuse le 4e avec une erreur claire
- [ ] Fichiers servis via route dédiée qui vérifie que l'user courant appartient à la famille propriétaire
- [ ] Composant de rendu image dans `core_components.ex`
- [ ] Suppression de bloc image supprime le fichier
- [ ] Tests : upload valide, rejet trop gros, rejet du 4e bloc image, accès interdit depuis une autre famille, nettoyage disque

### Out of scope
- Stockage prod (S3 / R2 / disque attaché) — décision différée, documentée dans CHANGELOG
- Redimensionnement, optimisation (→ Icebox)
- Galerie multi-images / carrousel (→ Icebox)

### Notes
- `priv/uploads/` ajouté à `.gitignore` (sauf `.keep`).
- **Contrôle d'accès aux fichiers critique** : ne PAS servir via `Plug.Static` public — passer par un controller qui vérifie le scope famille.
- La contrainte "max 3" est imposée au niveau context (garantie d'invariant) ET dans l'UI (feedback utilisateur). Les deux sont testés.

---

### [S3-T07] Home feed famille + publier / dépublier
**As a** membre authentifié **I want** arriver sur une page d'accueil qui montre les 5 derniers articles publiés de ma famille **so that** je découvre le contenu récent sans chercher.

### Acceptance criteria
- [ ] `GET /` remplacé : si anonyme → redirect login ; si authentifié → `HomeLive`
- [ ] `HomeLive` liste les 5 derniers articles publiés dans la famille du scope, `published_at DESC`
- [ ] Chaque carte : titre, date de publication, extrait (premier bloc `paragraph` tronqué ~200 caractères)
- [ ] Lien "Voir tous les articles" vers `/articles`
- [ ] Bouton "Publier" / "Dépublier" dans `ArticleLive.Form` (auteur ou admin famille)
- [ ] Tests : seuls les publiés remontent, brouillon reste invisible, toggle publier fonctionne

### Out of scope
- Programmation de publication future (→ Icebox)
- Partage public d'un brouillon via lien secret (→ Icebox)

### Notes
- Dépend de S2-T04 et S2-T05.

---

### [S3-T08] Tags d'articles
**As a** membre authentifié **I want** associer un ou plusieurs tags à mes articles et voir les tags utilisés dans ma famille **so that** je puisse organiser et retrouver le contenu par thème.

### Acceptance criteria

**Schémas :**
- [ ] `Brimbelle.Journal.Tag` (`id`, `family_id`, `name :string`, `slug :string`, timestamps) — unique (`family_id`, `slug`)
- [ ] Table de jointure `article_tags` (`article_id`, `tag_id`) — unique (`article_id`, `tag_id`)
- [ ] Article : `many_to_many :tags, Tag, join_through: "article_tags", on_replace: :delete`
- [ ] Scoping famille : un tag appartient à UNE famille ; réutilisable entre articles de la même famille ; invisible des autres familles

**Context `Brimbelle.Journal` étendu :**
- [ ] `list_tags(scope)` — tags de la famille du scope, ordonnés par usage descendant puis alphabétique
- [ ] `set_article_tags(scope, article, names)` — prend une liste de noms (strings), crée les tags manquants dans la famille, assigne ; slug auto depuis le nom
- [ ] `list_articles_by_tag(scope, tag)` — publiés de la famille ayant ce tag, `published_at DESC`

**UI éditeur :**
- [ ] `ArticleLive.Form` : champ tags style chips/pills avec autocomplete sur les tags existants de la famille ; entrée libre crée un nouveau tag
- [ ] Max 10 tags par article (contrainte éditeur + context)

**UI lecture :**
- [ ] `ArticleLive.Show` : tags affichés sous le titre, cliquables
- [ ] Cliquer un tag → navigue vers `/articles?tag=<slug>` qui filtre le feed

**Tests :**
- [ ] Isolation inter-familles : un tag "voyage" de la famille A n'est pas visible pour la famille B
- [ ] Création auto de tag inexistant à la sauvegarde d'un article
- [ ] Filtre feed par tag ne retourne que les articles de la famille ET du tag
- [ ] Rejet du 11e tag

### Out of scope
- Auto-complétion serveur-side avancée (fuzzy matching, suggestions) — autocomplete simple par préfixe au MVP
- Renommage/fusion de tags par l'admin famille (→ Icebox)
- Couleurs de tags (→ Icebox)

### Notes
- Dépend de S2-T03 (modèle article), S2-T05 (éditeur pour la saisie).
- Un tag sans article rattaché reste en base (nettoyage manuel plus tard si besoin).

---

### [S3-T09] Recherche par titre et tag
**As a** membre authentifié **I want** rechercher des articles de ma famille par titre ou par tag **so that** je retrouve rapidement un contenu précis quand le feed ne suffit plus.

### Acceptance criteria
- [ ] Barre de recherche dans le header ou en haut du feed `/articles`
- [ ] Soumission ou `phx-change` avec debounce → `GET /articles?q=<terme>&tag=<slug>`
- [ ] Backend : `LIKE %terme%` insensible à la casse sur `articles.title` OU match exact sur slug de tag ; scopé à la famille du scope
- [ ] Résultats affichés dans le même layout que le feed (cartes articles)
- [ ] État vide : message explicite "Aucun article ne correspond à votre recherche"
- [ ] Combinaison `q` + `tag` : filtre cumulatif (AND)
- [ ] Tests : recherche retourne publiés de la famille uniquement, insensible à la casse, vide gère proprement, filtre tag + q cumulatif

### Out of scope
- Recherche plein texte dans le contenu des blocs (→ Icebox, nécessitera SQLite FTS5)
- Suggestions / auto-complétion sur la recherche (→ Icebox)
- Historique de recherche, tri par pertinence

### Notes
- Dépend de S3-T08 pour le filtre tag.
- `LIKE` suffit au MVP (petit volume, DB SQLite locale). Migration vers FTS5 si le volume explose.

---

### [S4-T10] Administration d'une famille
**As an** admin d'une famille **I want** voir la liste des membres, retirer des membres, révoquer des invitations non utilisées, promouvoir un membre en admin **so that** je puisse maintenir la composition de ma famille.

### Acceptance criteria
- [ ] `/family` : page admin listant les membres (nom, email, rôle, date d'adhésion) et les invitations actives (token tronqué, date expiration, état)
- [ ] Bouton "Retirer" sur un membre (sauf soi-même)
- [ ] Bouton "Promouvoir admin" sur un membre `member`
- [ ] Bouton "Révoquer" sur une invitation non utilisée
- [ ] Toutes ces actions vérifient `scope.membership.role == "admin"` — 403 sinon
- [ ] Retirer un membre ne supprime pas ses articles (historique préservé)
- [ ] Tests : non-admin bloqué, admin peut tout faire, on ne peut pas retirer le dernier admin

### Out of scope
- Transfert de propriété d'articles lors du retrait d'un membre (→ Icebox)

### Notes
- Un membre retiré ne voit plus rien, mais ses articles restent visibles par la famille avec son nom.

---

### [S4-T11] Backoffice super-admin
**As a** super-admin **I want** accéder à un backoffice listant toutes les familles et tous les users, avec possibilité de créer/supprimer, promouvoir/rétrograder **so that** je puisse administrer la plateforme sans toucher à la DB.

### Acceptance criteria
- [ ] Routes `/admin/*` protégées : accès refusé si `not user.is_super_admin`
- [ ] `/admin/families` : liste, nombre de membres par famille, date de création
- [ ] `/admin/users` : liste, famille(s), `is_super_admin`, date d'inscription
- [ ] Actions : supprimer un user, supprimer une famille (avec cascade), promouvoir un user super-admin
- [ ] Tests : accès refusé pour un user normal, actions fonctionnent pour super-admin
- [ ] Aucun moyen UI de créer le premier super-admin : documentation d'une commande `mix` ou `iex` pour le promouvoir en DB

### Out of scope
- Logs d'audit, historique des actions admin (→ Icebox)
- Statistiques / dashboard (→ Icebox)

### Notes
- Priorité basse : le super-admin a toujours un accès DB / `iex` de secours.

## Icebox

- **Sélecteur de famille** pour les users multi-famille (activer quand nécessaire)
- **Invitation par email** via Swoosh
- **Rendu Markdown inline** dans le bloc paragraph (gras / italique / lien)
- **Types de blocs additionnels** : `code`, `list`, `divider`, `embed`, `gallery`
- **Recherche plein texte** dans le contenu des blocs (SQLite FTS5)
- **Fusion / renommage de tags** par l'admin famille
- **Couleurs de tags** personnalisées
- **Auto-complétion / suggestions** avancées sur la recherche
- **Flux RSS / Atom** privé par famille (avec token)
- **Commentaires** entre membres d'une famille
- **Notifications** d'un nouvel article publié dans la famille
- **Stockage prod des images** (S3, Cloudflare R2, disque attaché)
- **Redimensionnement / optimisation** images
- **Preview fidèle** dans l'éditeur
- **Historique de versions** d'un article
- **Programmation de publication** future
- **Partage d'un brouillon** via lien secret
- **SEO meta tags** (pas prioritaire vu le côté privé)
- **Déploiement prod** (release Elixir, hébergeur, domaine)
- **Logs d'audit super-admin**
- **Transfert d'articles** lors du retrait d'un membre
