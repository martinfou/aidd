---
id: ARCH-01
stage: architecture
title: "Liste Noire JTI Redis + Invalidation Pub/Sub L1"
status: APPROVED
owner: architect
upstream: SPEC-01
next_step: pm:stories
---

## Architectural Decision (ADR)
Utiliser des clés Redis éphémères `revoked:jti:<jti>` et `revoked:user:<tenantId>:<userId>` avec `EXAT <jwt.exp>` doublées d'un canal Redis Pub/Sub `aidd:auth:invalidate` vidant instantanément le LRU local (5000 entrées, TTL max 5s) de chaque pod Fastify.

## Allowed Paths
- `src/auth/session-guard.ts`
- `src/auth/revocation-store.ts`
- `src/routes/security-revoke.ts`
- `src/ui/admin/UserSessionsPanel.tsx`
- `tests/auth/revocation.spec.ts`

## Forbidden Paths
- `src/crypto/jwks-rotation.ts`
- `prisma/migrations/*`
- `.aidd/guards/*`
