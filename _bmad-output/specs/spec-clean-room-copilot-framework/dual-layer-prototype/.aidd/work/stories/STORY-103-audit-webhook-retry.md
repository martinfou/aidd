---
id: STORY-103
epic: EPIC-SEC-04
sprint: SPRINT-14
lane: standard
title: "Journal d'Audit Immuable SOC2 & Webhook SIEM"
status: BLOCKED
owner: developer
reviewer: qa-reviewer
upstream: SPEC-01
next_step: analyst:clarify-Q1
---

## Context Slice
Écrire les événements de révocation dans `audit_events` avec politique de rétention légale. Bloqué par la question ouverte **Q1** de `BRIEF-01` (`90j` vs `365j`).

## Allowed Paths
- `src/audit/revocation-audit.ts`
- `tests/audit/revocation-audit.spec.ts`

## Acceptance Criteria
- [ ] **AC-04 :** Journalise chaque révocation et livre le webhook signé HMAC avec retry exponentiel.

## Execution Evidence
PENDING_EVIDENCE

## Review Verdict
- **Verdict:** PENDING
