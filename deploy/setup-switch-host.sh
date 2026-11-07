#!/usr/bin/env bash
# Application Desk - Flip the Switch demo host bring-up.
# Runs INSIDE a fresh GitHub Codespace (default image has Docker + Node).
# Zero-spend: uses only free/open components. Idempotent-ish; safe to re-run.
set -euo pipefail

SWITCH_VERSION="${SWITCH_VERSION:-0.31.0}"   # latest stable tag from ghcr.io/sandbox-quantum/standalone-compose
WORK="${WORK:-$HOME/switch-demo}"
BRIDGE="http://localhost:8000"               # switch-core API / agent bridge (loopback)
GW="http://localhost:3000"                   # gateway web + management routes

mkdir -p "$WORK" && cd "$WORK"

# 1. Compose file + env -------------------------------------------------------
if [ ! -f docker-compose.yml ]; then
  curl -fsSL https://raw.githubusercontent.com/sandbox-quantum/switch/main/deploy/local/standalone-docker-compose.yml -o docker-compose.yml
  curl -fsSL https://raw.githubusercontent.com/sandbox-quantum/switch/main/.env.example -o .env
fi

setenv() { # setenv KEY VALUE  (in-place, no echo of secrets)
  local k="$1" v="$2"
  grep -q "^${k}=" .env && sed -i "s|^${k}=.*|${k}=${v}|" .env || echo "${k}=${v}" >> .env
}

if ! grep -q '^DB_PASSWORD=.\+' .env; then
  setenv SWITCH_VERSION "$SWITCH_VERSION"
  setenv FEATURE_FLAGS_ENABLED "agent_management"
  setenv DB_PASSWORD "$(openssl rand -hex 24)"
  setenv DB_OWNER_PASSWORD "$(openssl rand -hex 24)"
  setenv AGENT_REGISTRATION_TOKEN "$(openssl rand -hex 24)"
  setenv GATEWAY_ADMIN_PASSWORD "$(openssl rand -hex 24)"
  setenv MATTERMOST_ADMIN_PASSWORD "$(openssl rand -hex 24)"
  setenv MATTERMOST_USER_PASSWORD "$(openssl rand -hex 24)"
  setenv JWT_SECRET_KEY "$(openssl rand -hex 32)"
  setenv CONTROLLER_TOKEN_SECRET "$(openssl rand -hex 32)"
  setenv SECRET_KEYS "local:$(openssl rand -hex 32)"
  setenv TELEMETRY_ENVIRONMENT "local"
fi

# 2. Stack up -----------------------------------------------------------------
docker compose --profile collab --profile gateway up -d
echo "Waiting for switch-core health..."
for i in $(seq 1 60); do
  curl -fsS "$BRIDGE/health" >/dev/null 2>&1 && break || sleep 5
done
curl -fsS "$BRIDGE/health" >/dev/null

# 3. Gateway admin session ----------------------------------------------------
ADMIN_EMAIL=$(grep '^GATEWAY_ADMIN_EMAIL=' .env | cut -d= -f2)
ADMIN_PASS=$(grep '^GATEWAY_ADMIN_PASSWORD=' .env | cut -d= -f2)
curl -fsS -c "$WORK/cookies.txt" -X POST "$GW/auth/login" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASS\"}" >/dev/null

# 4. Agent controller ---------------------------------------------------------
if ! command -v switch-agent-controller >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/sandbox-quantum/switch/main/console/packages/agent-controller/install.sh | sh
fi
export PATH="$PATH:$HOME/.local/bin"

if [ ! -d "$HOME/.local/share/switch-agent-controller" ]; then
  CODE=$(curl -fsS -b "$WORK/cookies.txt" -X POST "$GW/management/enrollment-codes" | python3 -c 'import sys,json;print(json.load(sys.stdin)["code"])')
  switch-agent-controller enroll --server "$BRIDGE" --code "$CODE" --name build-box --secret-store file
fi

# 5. OpenCode -----------------------------------------------------------------
if ! command -v opencode >/dev/null 2>&1; then
  curl -fsSL https://opencode.ai/install | bash
fi
export PATH="$PATH:$HOME/.opencode/bin"

# 6. Controller env (model key appended by caller: OPENROUTER_API_KEY=...)
touch "$WORK/agent.env"
nohup switch-agent-controller run --env-file "$WORK/agent.env" > "$WORK/controller.log" 2>&1 &

echo "STACK UP. Mattermost on :8065 (seeded team 'switch', user 'user'), Gateway on :3000, API on :8000"
echo "Next: POST /rooms/from-yaml with the Application Desk template."
