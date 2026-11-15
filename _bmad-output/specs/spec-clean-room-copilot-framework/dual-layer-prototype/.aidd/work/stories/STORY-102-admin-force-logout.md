---
id: STORY-102
epic: EPIC-SEC-04
sprint: SPRINT-14
lane: standard
title: "UI Console Admin — Bouton Force-Logout & Sessions Actives"
status: IN_PROGRESS
owner: developer
reviewer: qa-reviewer
upstream: ARCH-01
next_step: developer:implement
---

## Context Slice
Construire le panneau React `UserSessionsPanel.tsx` et brancher l'indicateur de session courante depuis `session-guard.ts`.

## Allowed Paths
- `src/ui/admin/UserSessionsPanel.tsx`
- `src/auth/session-guard.ts`
- `tests/ui/UserSessionsPanel.test.tsx`

## Forbidden Paths
- `prisma/migrations/*`

## Acceptance Criteria
- [ ] **AC-01 :** Affiche les 4 états UX (Empty, Loading, Success, Error) avec conformité WCAG AA.
- [ ] **AC-02 :** Déclenche `POST /api/v1/security/revoke` après confirmation clavier/souris.

## Execution Evidence
PENDING_EVIDENCE

## Review Verdict
- **Verdict:** PENDING
