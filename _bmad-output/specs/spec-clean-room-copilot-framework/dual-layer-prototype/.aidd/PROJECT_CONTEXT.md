# Project Context — Enterprise Identity Gateway

Passerelle d'authentification multi-tenant B2B gérant les sessions OIDC/SAML2 (`120k` utilisateurs actifs/jour).
Objectif du sprint courant (`SPRINT-14` / `EPIC-SEC-04`) : révocation instantanée des jetons compromis (< 250 ms P99) sans dégrader les routes publiques.
