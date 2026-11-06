#!/usr/bin/env sh
# OBS-01: a request that takes 1.2 s leaves durationMs near 1200 in the access log.
# Needs Docker and the image built as "gateway". Usage: ./tests/latency-log.sh
set -u
export MSYS_NO_PATHCONV=1
net=latency-log-test
slow='import http.server, time
class H(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        time.sleep(1.2)
        self.send_response(200); self.send_header("Content-Length", "0"); self.end_headers()
http.server.ThreadingHTTPServer(("", 8080), H).serve_forever()'

cleanup() {
  docker rm -f latency-gateway identity-auth-api >/dev/null 2>&1
  docker network rm "$net" >/dev/null 2>&1
}
cleanup
trap cleanup EXIT

docker network create "$net" >/dev/null
docker run -d --name identity-auth-api --network "$net" python:3.12-alpine python -c "$slow" >/dev/null
docker run -d --name latency-gateway --network "$net" -p 8001:8000 gateway >/dev/null
sleep 3

curl -s -o /dev/null -X POST http://localhost:8001/api/v1/auth/login
sleep 1
line=$(docker logs latency-gateway 2>/dev/null | grep '/api/v1/auth/login' | tail -1)
ms=$(echo "$line" | sed -E 's/.*"durationMs":([0-9]+)}.*/\1/')
echo "  access log: $line"
case "$ms" in
  ''|*[!0-9]*) echo "  FAIL  durationMs is not an integer"; exit 1 ;;
esac
if [ "$ms" -ge 1200 ] && [ "$ms" -le 1300 ]
then echo "  ok    durationMs is $ms for a 1.2 s request"
else echo "  FAIL  durationMs is $ms, want 1200 to 1300"; exit 1
fi
