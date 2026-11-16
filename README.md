# CostRail Food Cost Calculator MCP Server (`com.food-cost-calculator/costrail`)

Hosted **Streamable HTTP** Model Context Protocol (MCP) server for restaurant recipe food costing, butcher trim yield calculations, and bar pour cost math.

- **Remote MCP Endpoint:** `https://www.food-cost-calculator.com/api/mcp`
- **Transport:** `streamable-http` (JSON-RPC 2.0 over HTTPS — no local install required)
- **Registry ID:** `com.food-cost-calculator/costrail` (`v1.0.0`)
- **Publisher:** CostRail Operations ([support@food-cost-calculator.com](mailto:support@food-cost-calculator.com))
- **Website & Docs:** [https://www.food-cost-calculator.com/mcp](https://www.food-cost-calculator.com/mcp)

---

## Quickstart: Connect in Your MCP Client

The public `cost_dish_or_pour` tool works over HTTPS with **no API key or account required**.

### 1. Cursor

Copy [`.cursor/mcp.json`](./.cursor/mcp.json) into your project's `.cursor/mcp.json` (or `~/.cursor/mcp.json` globally):

```json
{
  "mcpServers": {
    "costrail": {
      "type": "http",
      "url": "https://www.food-cost-calculator.com/api/mcp"
    }
  }
}
```

### 2. Claude Code

Add the remote Streamable HTTP server directly from your terminal:

```bash
claude mcp add --transport http costrail https://www.food-cost-calculator.com/api/mcp
```

### 3. Claude Desktop

- **Option A (Connectors UI):** Open **Settings → Connectors → Add custom connector** and enter `https://www.food-cost-calculator.com/api/mcp`.
- **Option B (`claude_desktop_config.json`):** Use [`claude_desktop_config.json`](./claude_desktop_config.json) with `mcp-remote`:

```json
{
  "mcpServers": {
    "costrail": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://www.food-cost-calculator.com/api/mcp"
      ]
    }
  }
}
```

### 4. Windsurf

Add CostRail to `~/.codeium/windsurf/mcp_config.json`:

```json
{
  "mcpServers": {
    "costrail": {
      "serverUrl": "https://www.food-cost-calculator.com/api/mcp"
    }
  }
}
```

### 5. Antigravity

In Antigravity's `mcp_config.json`, register the remote Streamable HTTP endpoint:

```json
{
  "mcpServers": {
    "costrail": {
      "serverUrl": "https://www.food-cost-calculator.com/api/mcp"
    }
  }
}
```

---

## Available MCP Tool

### `cost_dish_or_pour`

Calculate plate cost, pour cost, food-cost percentage, and suggested menu price from natural language or structured ingredient descriptions.

- **Input Schema:**
  ```json
  {
    "type": "object",
    "properties": {
      "text": {
        "type": "string",
        "description": "Dish or pour description with pack prices and portion sizes"
      }
    },
    "required": ["text"]
  }
  ```
- **Example `tools/call` Payload (Dish):**
  ```json
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "cost_dish_or_pour",
      "arguments": {
        "text": "House burger plate cost"
      }
    }
  }
  ```
- **Example `tools/call` Payload (Pour):**
  ```json
  {
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/call",
    "params": {
      "name": "cost_dish_or_pour",
      "arguments": {
        "text": "1.5 oz vodka pour cost"
      }
    }
  }
  ```

---

## Discovery & Verification Endpoints

| Endpoint | Purpose |
| :--- | :--- |
| `https://www.food-cost-calculator.com/api/mcp` | Streamable HTTP JSON-RPC 2.0 MCP endpoint (`POST` for `initialize`, `tools/list`, `tools/call`; `GET` returns server summary & tools). |
| `https://www.food-cost-calculator.com/.well-known/mcp.json` | Machine-readable MCP server manifest (`protocolVersion: "2025-03-26"`, version `1.0.0`, repository link). |
| `https://www.food-cost-calculator.com/.well-known/mcp-registry-auth` | Ed25519 domain ownership proof (`v=MCPv1; k=ed25519; ...`) for the Official MCP Registry. |
| `https://www.food-cost-calculator.com/.well-known/agent-card.json` | Agent-to-Agent (A2A) discovery card describing `cost_dish_or_pour`. |
| `https://www.food-cost-calculator.com/llms.txt` | Concise `llms.txt` directory covering CostRail calculators, `/kitchen`, pricing, and WebMCP context. |
| `https://www.food-cost-calculator.com/mcp` | Web reference page with JSON-RPC 2.0 schemas and example payloads. |

---

## Web Calculators & Pricing

- **Guest Calculators (Free, No Sign-In):** [Food Cost Calculator](https://www.food-cost-calculator.com/), [Pour Cost Calculator](https://www.food-cost-calculator.com/pour-cost-calculator), [Cocktail Cost Calculator](https://www.food-cost-calculator.com/cocktail-cost-calculator), [Menu Pricing Calculator](https://www.food-cost-calculator.com/menu-pricing-calculator), [Recipe & Batch Cost Calculator](https://www.food-cost-calculator.com/recipe-cost-calculator), and [Butcher Yield Loss Calculator](https://www.food-cost-calculator.com/butcher-yield-loss-calculator).
- **Plans ([Pricing](https://www.food-cost-calculator.com/pricing)):**
  - **Free Account:** Save up to 3 dishes and 3 drinks.
  - **Menu Costing Sheet Pass (`$9` one-time):** Export PDF and Excel costing sheets.
  - **Kitchen Plan (`$29/mo`):** Save unlimited recipes, vendor prices, and CSV price-move alerts.

---

## Verify Live with `curl`

Run the included smoke-test script (no token required):

```bash
chmod +x ./examples/verify-mcp.sh
./examples/verify-mcp.sh
```

Direct `curl` example:

```bash
curl -sS -X POST https://www.food-cost-calculator.com/api/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "cost_dish_or_pour",
      "arguments": { "text": "House burger plate cost" }
    }
  }'
```

---

## Repository Contents

- [`server.json`](./server.json) — Official MCP Registry manifest (`2025-12-11` schema, version `1.0.0`)
- [`.cursor/mcp.json`](./.cursor/mcp.json) — Cursor Streamable HTTP MCP configuration
- [`claude_desktop_config.json`](./claude_desktop_config.json) — Claude Desktop `mcp-remote` configuration
- [`examples/verify-mcp.sh`](./examples/verify-mcp.sh) — Executable `curl` smoke-test script
- [`LICENSE`](./LICENSE) — MIT License

---

## Publisher, Support & Policies

- **Publisher:** CostRail Operations
- **Support:** [support@food-cost-calculator.com](mailto:support@food-cost-calculator.com)
- **Policies:** [Privacy Policy](https://www.food-cost-calculator.com/privacy) · [Terms of Service](https://www.food-cost-calculator.com/terms) · [Refund Policy](https://www.food-cost-calculator.com/refund)
- **License:** [MIT](./LICENSE)

## Zero-Install Stdio Bridge (`npx`)

For stdio-only MCP clients (like Claude Desktop), connect without cloning or managing dependencies:

```json
{
  "mcpServers": {
    "costrail-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "github:venkork/costrail-mcp"
      ]
    }
  }
}
```

Or run directly via terminal: `npx -y github:venkork/costrail-mcp` (package ID: `costrail-mcp@1.0.0`).
