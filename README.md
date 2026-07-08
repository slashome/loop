# Loop

Gestionnaire de tâches perso, **local-first**. v1 = tâches uniquement (une app
de capture d'idées séparée, avec passerelle idée → tâche, viendra plus tard).

## Stack

- **Flutter (Dart)** — un seul codebase mobile + desktop, ordre d'affichage
  identique partout.
- **Drift** (SQLite typé) — store local-first. Pas de sync en v1, mais schéma
  *sync-ready* (UUIDv7, `updated_at`, soft-delete, `owner_id`).
- **Riverpod** — state management.
- **flutter_local_notifications** — rappels locaux (pas de serveur).

## Architecture

Guide d'architecture officiel Flutter : **MVVM en couches, feature-first** par
concept métier (pas par écran).

```
lib/src/features/<feature>/
  domain/         modèles purs + logique métier (aucune dépendance Flutter/Drift)
  data/           repository (mappe Drift ↔ domain)
  presentation/   view + view_model
```

Features : `tasks` (onglets Prochaines actions + Calendrier), `recurrences`
(Repeats), `settings`.

## Tri — deux couches jamais mélangées

1. **Score** (ordre par défaut permanent) :
   `score = priorité + k·(1 − e^(−âge/τ))`, `k`/`τ` réglables globalement.
   Anti-famine **borné** par défaut (`k=2, τ=14j`) : les tâches négligées
   remontent, mais la priorité reste dominante.
2. **Filtres** orthogonaux au score. Composition imposée :
   `sorted(filtered(items))`.

**Caps par palier de priorité** (`{5:3, 4:5}`) appliqués à l'écriture pour
forcer l'arbitrage.

## Développement

```sh
flutter pub get
flutter test      # couche domaine : scoring, caps, composition filtre→tri
flutter run
```
