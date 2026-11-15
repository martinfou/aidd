---
id: STORY-104
epic: QUICK-FIX
sprint: HOTFIX
lane: quick-fix
title: "Tolérance Clock-Skew 5s sur Calcul TTL Redis"
status: DONE
owner: developer
reviewer: qa-reviewer
upstream: QUICK-FIX
next_step: DONE
---

## Context Slice
Éviter `ERR invalid expire time in setex` lorsqu'un jeton expire dans moins d'une seconde au moment de la révocation.

## Allowed Paths
- `src/auth/ttl-math.ts`
- `tests/auth/ttl-math.spec.ts`

## Acceptance Criteria
- [x] **AC-QF1 :** `computeRemainingTtlSeconds()` retourne au minimum `1` seconde ou ignore l'écriture si déjà expiré.

## Execution Evidence
```text
$ pnpm test --run tests/auth/ttl-math.spec.ts
✓ tests/auth/ttl-math.spec.ts (3 tests) 11ms
```

## Review Verdict
- **Verdict:** APPROVED
- **Reviewer:** qa-reviewer
- **Notes:** Correctif chirurgical (2 fichiers), test aux limites vérifié.
