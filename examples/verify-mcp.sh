#!/usr/bin/env bash
set -euo pipefail

MCP_URL="${COSTRAIL_MCP_URL:-https://www.food-cost-calculator.com/api/mcp}"
WELL_KNOWN_URL="${COSTRAIL_WELL_KNOWN_URL:-https://www.food-cost-calculator.com/.well-known/mcp.json}"

echo "Verifying CostRail Remote MCP endpoint: ${MCP_URL}"
echo ""

echo "1) GET /.well-known/mcp.json..."
curl -fsS "${WELL_KNOWN_URL}" | head -c 500
echo ""
echo ""

echo "2) JSON-RPC initialize..."
INIT_RESP="$(curl -fsS -X POST "${MCP_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2025-03-26",
      "capabilities": {},
      "clientInfo": { "name": "costrail-mcp-verify", "version": "1.0.0" }
    }
  }')"
echo "${INIT_RESP}" | head -c 500
echo ""
echo ""

echo "3) JSON-RPC tools/list..."
TOOLS_RESP="$(curl -fsS -X POST "${MCP_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list",
    "params": {}
  }')"

if command -v python3 >/dev/null 2>&1; then
  TOOLS_RESP_JSON="${TOOLS_RESP}" python3 - <<'PY'
import json, os, sys
data = json.loads(os.environ["TOOLS_RESP_JSON"])
tools = data.get("result", {}).get("tools", [])
if not tools:
    print("No tools returned", file=sys.stderr)
    sys.exit(1)
print(f"Discovered {len(tools)} public tool(s):")
for t in tools:
    print(f"  - {t.get('name')}")
PY
else
  echo "${TOOLS_RESP}" | head -c 500
fi
echo ""

echo "4) Smoke test: cost_dish_or_pour (dish)..."
DISH_RESP="$(curl -fsS -X POST "${MCP_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
      "name": "cost_dish_or_pour",
      "arguments": { "text": "House burger plate cost" }
    }
  }')"

if command -v python3 >/dev/null 2>&1; then
  DISH_RESP_JSON="${DISH_RESP}" python3 - <<'PY'
import json, os, sys
data = json.loads(os.environ["DISH_RESP_JSON"])
if "error" in data:
    print("Dish tool error:", data["error"], file=sys.stderr)
    sys.exit(1)
sc = data.get("result", {}).get("structuredContent", {})
if not sc.get("ok"):
    print("Expected ok=true:", sc, file=sys.stderr)
    sys.exit(1)
print("  kind:", sc.get("kind"), "| name:", sc.get("name"), "| cost:", sc.get("cost"), "| percent:", sc.get("percent"), "| suggest:", sc.get("suggest"))
PY
else
  echo "${DISH_RESP}" | head -c 500
fi
echo ""

echo "5) Smoke test: cost_dish_or_pour (pour)..."
POUR_RESP="$(curl -fsS -X POST "${MCP_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 4,
    "method": "tools/call",
    "params": {
      "name": "cost_dish_or_pour",
      "arguments": { "text": "1.5 oz vodka pour cost" }
    }
  }')"

if command -v python3 >/dev/null 2>&1; then
  POUR_RESP_JSON="${POUR_RESP}" python3 - <<'PY'
import json, os, sys
data = json.loads(os.environ["POUR_RESP_JSON"])
if "error" in data:
    print("Pour tool error:", data["error"], file=sys.stderr)
    sys.exit(1)
sc = data.get("result", {}).get("structuredContent", {})
if not sc.get("ok"):
    print("Expected ok=true:", sc, file=sys.stderr)
    sys.exit(1)
print("  kind:", sc.get("kind"), "| name:", sc.get("name"), "| cost:", sc.get("cost"), "| percent:", sc.get("percent"), "| suggest:", sc.get("suggest"))
PY
else
  echo "${POUR_RESP}" | head -c 500
fi

echo ""
echo "Verification completed."
