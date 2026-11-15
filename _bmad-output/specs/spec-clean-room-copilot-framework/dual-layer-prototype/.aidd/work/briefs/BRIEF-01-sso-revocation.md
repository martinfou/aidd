---
id: BRIEF-01
stage: brief
title: "Révocation Instantanée des Sessions SSO Compromises"
status: APPROVED
owner: analyst
upstream: NONE
next_step: pm:spec
---

## Problem Statement
Les jetons JWT d'accès actuels ont une durée de vie de `15 minutes` sans vérification de révocation intermédiaire. Lorsqu'un compte employé ou client est signalé compromis par le SOC, l'attaquant conserve jusqu'à 15 minutes d'accès actif aux APIs critiques.

## Target Users & Success Metrics
- **Analystes SOC & Admins Tenant :** Révocation effective en `< 250 ms` P99 sur toutes les passerelles régionales.
- **Impact Latence API :** Surcoût maximal autorisé `< 1.5 ms` P99 sur la validation des requêtes authentifiées.

## Scope
### In Scope
- Liste de révocation distribuée indexée par `jti` et `user_revoked_before` dans Redis.
- Action "Forcer la déconnexion globale" dans la console Admin Tenant.
- Journalisation d'audit immuable conforme SOC2.

### Out of Scope
- Rotation automatique des clés privées KMS JWKS.
- Révocation rétroactive des exports CSV déjà téléchargés.

## Open Questions & Risks
- [x] **Q0 :** Faut-il bloquer ou laisser passer si le cluster Redis est injoignable > 50 ms ? *(Décidé : Fail-Closed pour `/admin/*` et `/billing/*`, Fail-Open alerte P1 pour lecture catalogue).*
- [ ] **Q1 :** Quel délai de rétention légal conserver pour le motif de révocation SOC dans l'audit log (`90j` vs `365j`) ?
