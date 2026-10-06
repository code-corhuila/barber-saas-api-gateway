# barber-saas-api-gateway

> Single entry point: authentication, routing and rate limiting

Part of the **Barber Saas** distributed system — team `barber-saas`, Grupo 2.
Governance and documentation live in [`barber-saas-docs`](https://github.com/code-corhuila/barber-saas-docs).

## Branching

Three permanent branches. **None of them accepts a direct commit** — you enter through a child
branch and leave through a Pull Request.

```
develop  <--PR--  feat/... fix/... chore/...
qa       <--PR--  qa/...
main     <--PR--  release/...  hotfix/...
```

Promotion happens **by re-application** (`git cherry-pick -x`), never by merging one permanent
branch into another: `merge develop -> qa` and `merge qa -> main` do not exist in this model.

`main` requires **1 approval from `ariel5253`**. On `develop` and `qa` the team sets its own review
rule.

Full policy: `00-governance/branching-policy.md` in `barber-saas-docs`.

---

## BarberSaaS — what this repository is

The single entry point of the platform (annex F, norm 5.6): NGINX configuration, not code. It
routes `/api/v1/<domain>/…` to each service, rejects a protected route that carries no
`Authorization` header, applies rate limits and CORS for the BarberSaaS app (Capacitor and
`ionic serve` origins, ADR-013), creates or keeps `X-Correlation-Id`, and answers its own errors
with the shared error envelope. It does **not** validate tokens: every service does (norm 5.3.7).

```
nginx/nginx.conf                 global settings and the JSON access log
nginx/conf.d/00-resolver.conf    per-request DNS: a service that is down does not take the gateway down
nginx/conf.d/10-security.conf    rate limits, CORS origins, correlation id, the credentials filter
nginx/conf.d/20-server.conf      the server block and the gateway's own errors
nginx/routes/<domain>.conf       ONE file per domain, owned by that domain's developer
tests/smoke.sh                   the checks the gateway must pass
```

### Adding a domain

Its owner adds `nginx/routes/<domain>.conf` (copy `identity-auth.conf`), in a small pull request
opened right after `git pull`. Nobody edits another domain's file.

### How to start it

As part of the platform, from `barber-saas-infra-postgres` (`./scripts/up.sh dev`), at
`http://localhost:8000`. Alone:

```bash
docker network create platform 2>/dev/null; docker compose -f deploy/compose.yml up -d --build
./tests/smoke.sh http://localhost:8000
```

### Where the data is

Nowhere: the gateway stores nothing and holds no secrets.

### How it is tested

`ci.yml` builds the image, checks the configuration with `nginx -t` and runs `tests/smoke.sh`
(health, 404/401/503 with the envelope, correlation id, CORS).

### What is missing

Routes of barbershop, schedule, appointment and the other domains, added by their owners.
