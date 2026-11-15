---
id: SPEC-01
stage: spec
title: "Révocation Temps-Réel JTI & Console Force-Logout"
status: IN_REVIEW
owner: pm
upstream: BRIEF-01
next_step: architect:design
---

## Functional Overview
Permettre aux administrateurs de sécurité d'invalider immédiatement un jeton individuel (`jti`) ou l'ensemble des sessions actives d'un utilisateur (`sub` + `tenantId`), avec propagation sous 250 ms et retour visuel clair dans la console d'administration.

## Scope & Boundaries
### In Scope
- **SCOPE-1 :** Endpoint `POST /api/v1/security/revoke` acceptant `userId`, `jti` optionnel et `reason`.
- **SCOPE-2 :** Middleware `session-guard.ts` vérifiant le cache L1 (TTL 5s) + Redis `SETEX` aligné sur `exp`.
- **SCOPE-3 :** Bouton d'urgence "Révoquer toutes les sessions" sur la fiche utilisateur Admin.
- **SCOPE-4 :** Notification email automatique envoyée à l'utilisateur final après révocation SOC.

### Out of Scope
- Déconnexion fédérée SAML Single-Logout (SLO) vers les IdP externes tiers (Okta/Entra).
- Blocage d'adresse IP au niveau WAF Cloudflare.

## Acceptance Criteria
- [ ] **AC-01 :** Un jeton dont le `jti` est révoqué reçoit `401 Unauthorized` (`code: TOKEN_REVOKED`) en moins de `250 ms` sur toute route protégée.
- [ ] **AC-02 :** L'action `POST /api/v1/security/revoke` rejette avec `403 Forbidden` tout opérateur n'ayant pas le rôle `SECURITY_ADMIN` du même `tenantId` (isolation multi-tenant stricte).
- [ ] **AC-03 :** En cas de panne Redis (`> 50 ms` timeout), les routes `/api/v1/admin/*` et `/api/v1/billing/*` appliquent une politique **Fail-Closed** (`503 AUTH_GUARD_UNAVAILABLE`).
- [ ] **AC-04 :** Toute révocation écrit un événement signé dans `audit_events` et déclenche le webhook SIEM du tenant avec retry exponentiel.

## UX States & Accessibility (WCAG AA)
| Écran / Composant | Empty | Loading | Success | Error | WCAG AA |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Fiche Sessions Actives | "Aucune session active sur les 24 dernières heures" | Skeleton 3 lignes + `aria-busy="true"` | Liste triée par IP/Geo + badge session courante | Bandeau `role="alert"` + bouton Réessayer | Focus trap modal + contraste 7.1:1 |
| Modale Confirmation Force-Logout | Liste des appareils impactés | Bouton désactivé + spinner "Révocation Redis..." | Toast vert + compteur sessions coupées | MISSING | Navigation clavier `Esc` / `Enter` |

## Security & Risk Notes
- **[SECURITY]** Vérifier systématiquement `claims.tenantId === admin.tenantId` avant toute écriture Redis pour empêcher une révocation inter-tenant.
- **[RISK]** Un cache L1 local de 5s implique une fenêtre résiduelle maximale de 5s si le pub/sub Redis d'invalidation tombe.

## Open Questions
- [ ] **Q2 :** Doit-on inclure `SCOPE-4` (email à l'utilisateur final) dans ce sprint ou le sortir en Hors-Périmètre pour éviter d'alerter un attaquant interne lors d'une enquête SOC silencieuse ?
