# Configuration

## MCP Server (Optional)

If using Codesign MCP for spec enrichment, configure your `~/.copilot/mcp-config.json`:

```json
{
  "mcpServers": {
    "codesign": {
      "type": "http",
      "url": "https://codesign-mcp.intel.com/sse"
    }
  }
}
```

## Environment Variables

Set `WORKAREA` to your PCH workarea path:
```bash
export WORKAREA=/path/to/your/workarea
```

This is required for build commands (grdlbuild), test runs (trex), and debug analysis.
