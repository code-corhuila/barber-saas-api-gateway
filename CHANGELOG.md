# Changelog

All notable changes to `barber-saas-api-gateway` are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2026-11-05

MVP 3 (corte 3): promoted from `develop` through `qa` with `git cherry-pick -x` (norm 10–11).

User stories: code-corhuila/barber-saas-docs#124, code-corhuila/barber-saas-docs#127, code-corhuila/barber-saas-docs#130, code-corhuila/barber-saas-docs#155.

### Added

- **routes:** route the subscription, the payments and Wompi's events
- **routes:** require a token for the user's own account
- **routes:** route the public reviews list of appointment without a token
- **routes:** route the simulated checkout without a token

### Fixed

- **security:** take the real client from X-Forwarded-For behind Caddy
- **nginx:** keep the client's correlation id only when it is a uuid or 32 hex characters

### Documentation

- **readme:** explain which correlation ids the gateway keeps

### Tests

- **smoke:** rate-limit each client behind the same proxy on its own
- **smoke:** check that a malformed correlation id is replaced and the error body stays json

## [2.0.0] - 2026-10-08

MVP 2 (corte 2): first release of this repository to `main`, promoted from `develop` through `qa`
with `git cherry-pick -x` (norm 10–11).

User stories: code-corhuila/barber-saas-docs#3, code-corhuila/barber-saas-docs#4, code-corhuila/barber-saas-docs#5, code-corhuila/barber-saas-docs#7, code-corhuila/barber-saas-docs#9, code-corhuila/barber-saas-docs#10, code-corhuila/barber-saas-docs#12, code-corhuila/barber-saas-docs#59.

### Added

- **nginx:** log every request as one json line with its correlation id
- **nginx:** resolve services per request so one down service does not stop the gateway
- **nginx:** add rate limits, cors for the app origins and the credentials filter
- **nginx:** send the security and cors headers on every response
- **nginx:** answer the gateway's own errors with the shared envelope
- **routes:** answer the gateway health check
- **routes:** route the identity-auth operations
- **deploy:** build the gateway image and publish only port 8000
- **routes:** route the barbershop operations with the anonymous catalog
- **routes:** route the schedule operations
- **routes:** route the appointment operations
- **routes:** route the workflow's saga operations
- **routes:** route the finance and inventory operations
- **routes:** route platform-admin through the gateway
- **routes:** route the notifications inbox and device tokens
- **routes:** route the loyalty operations

### Documentation

- **readme:** explain the gateway, how to add a domain and how to test it
- **readme:** point the header to Barber Saas and barber-saas-docs

### Tests

- **ci:** validate the configuration and run the smoke checks on every pull request
- **smoke:** check the saga routes and that /internal is never routed

### Maintenance

- **gateway:** ignore local env files and keys
- **gateway:** keep shell scripts with lf line endings
- **github:** add the pull request template
- **github:** track the story environment on the board
- **env:** state that the gateway holds no secrets
- use the new repository name barber-saas-infra-postgres

[3.0.0]: https://github.com/code-corhuila/barber-saas-api-gateway/releases/tag/v3.0.0
[2.0.0]: https://github.com/code-corhuila/barber-saas-api-gateway/releases/tag/v2.0.0
