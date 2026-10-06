#!/usr/bin/env sh
# The checks the gateway must pass (annex F). Usage: ./tests/smoke.sh http://localhost:8000
# They need only the gateway: a route whose service is not running answers 503 with the envelope.
set -u
BASE="${1:-http://localhost:8000}"
APP_ORIGIN="http://localhost:8100"
PROTECTED="$BASE/api/v1/auth/logout"
fail=0

check() {  # description, expected status, curl arguments...
  desc="$1"; want="$2"; shift 2
  got=$(curl -s -o /dev/null -w '%{http_code}' "$@")
  if [ "$got" = "$want" ]; then echo "  ok    $desc ($got)"; else echo "  FAIL  $desc: want $want, got $got"; fail=1; fi
}

contains() {  # description, expected text, curl arguments...
  desc="$1"; want="$2"; shift 2
  if curl -s -i "$@" | grep -qi -- "$want"; then echo "  ok    $desc"; else echo "  FAIL  $desc: missing $want"; fail=1; fi
}

absent() {  # description, forbidden text, curl arguments...
  desc="$1"; bad="$2"; shift 2
  if curl -s -i "$@" | grep -qi -- "$bad"; then echo "  FAIL  $desc: found $bad"; fail=1; else echo "  ok    $desc"; fi
}

check    "health answers"                          200 "$BASE/health"
check    "unknown route is 404"                    404 "$BASE/nope"
contains "404 uses the error envelope"             '"error":"NOT_FOUND"' "$BASE/nope"
check    "protected route without token is 401"    401 -X POST "$PROTECTED"
contains "401 uses the error envelope"             '"error":"UNAUTHORIZED"' -X POST "$PROTECTED"
check    "platform route without token is 401"     401 "$BASE/api/v1/platform/plans"
absent   "public plans need no token"              "a bearer token is required" "$BASE/api/v1/plans"
check    "a service that is down is 503"           503 -X POST -H 'Authorization: Bearer x' "$PROTECTED"
contains "503 uses the error envelope"             '"error":"SERVICE_UNAVAILABLE"' -X POST -H 'Authorization: Bearer x' "$PROTECTED"
contains "a correlation id is generated"           'X-Correlation-Id:' -X POST "$PROTECTED"
contains "the client's correlation id is kept"     'X-Correlation-Id: smoke-1' -X POST -H 'X-Correlation-Id: smoke-1' "$PROTECTED"
check    "preflight is allowed"                    204 -X OPTIONS -H "Origin: $APP_ORIGIN" "$PROTECTED"
contains "CORS allows Idempotency-Key"             'Idempotency-Key' -X OPTIONS -H "Origin: $APP_ORIGIN" "$PROTECTED"
contains "CORS exposes X-Correlation-Id"           'Access-Control-Expose-Headers: X-Correlation-Id' -X POST -H "Origin: $APP_ORIGIN" "$PROTECTED"
contains "the installed iOS app is allowed"        'Access-Control-Allow-Origin: capacitor://localhost' -X POST -H 'Origin: capacitor://localhost' "$PROTECTED"
absent   "an unknown origin gets no CORS grant"    'Access-Control-Allow-Origin' -X POST -H 'Origin: http://evil.example' "$PROTECTED"
check    "owner sign-up needs no token"            503 -X POST "$BASE/api/v1/sagas/owner-onboarding"
check    "reading a saga needs a token"            401 "$BASE/api/v1/sagas/35920dc9-bd55-41a0-8e41-5832377383e5"
check    "internal operations are never routed"    404 -X POST -H 'Authorization: Bearer x' "$BASE/internal/v1/owners"

exit $fail
