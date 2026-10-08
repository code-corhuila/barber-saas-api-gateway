# Changelog

All notable changes to `barber-saas-api-gateway` are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[2.0.0]: https://github.com/code-corhuila/barber-saas-api-gateway/releases/tag/v2.0.0
