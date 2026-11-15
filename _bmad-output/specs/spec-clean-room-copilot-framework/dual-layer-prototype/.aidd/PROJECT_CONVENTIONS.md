# Project Conventions

## Tech Stack
- **Language:** TypeScript 5.6 (Node.js 22 LTS)
- **Framework:** Fastify 5 + Redis 7 + React 19 Admin Console
- **Package Manager:** pnpm

## Quality Commands (Machine-Parsed by .aidd/guards/pre-commit)
- **Build Command:** `pnpm build`
- **Lint Command:** `pnpm lint`
- **Typecheck Command:** `pnpm typecheck`
- **Test Command:** `pnpm test --run`

## Architecture & Coding Guardrails
- Zero session state in memory; all revocation JTI keys must expire with JWT TTL in Redis.
- Every security-sensitive endpoint must emit structured audit events (`actorId`, `tenantId`, `jti`, `reason`).
