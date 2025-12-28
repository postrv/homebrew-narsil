# Homebrew Tap for narsil-mcp

Official Homebrew tap for [narsil-mcp](https://github.com/postrv/narsil-mcp) - a blazingly fast MCP server for code intelligence.

## Installation

```bash
brew tap postrv/narsil
brew install narsil-mcp
```

## Usage

```bash
narsil-mcp --repos /path/to/your/project
```

For full usage instructions, see:
```bash
narsil-mcp --help
```

## Configuration with AI Assistants

### Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "narsil-mcp": {
      "command": "narsil-mcp",
      "args": ["--repos", "/path/to/your/projects"]
    }
  }
}
```

### VS Code with Copilot

Create `.vscode/mcp.json` in your workspace:

```json
{
  "servers": {
    "narsil-mcp": {
      "command": "narsil-mcp",
      "args": ["--repos", "${workspaceFolder}"]
    }
  }
}
```

### Cursor

Create `.cursor/mcp.json` in your project:

```json
{
  "mcpServers": {
    "narsil-mcp": {
      "command": "narsil-mcp",
      "args": ["--repos", "."]
    }
  }
}
```

## Updating

```bash
brew update
brew upgrade narsil-mcp
```

## Uninstalling

```bash
brew uninstall narsil-mcp
brew untap postrv/narsil
```

## Supported Platforms

- macOS (Intel and Apple Silicon)
- Linux (x86_64)

## Documentation

See the [main repository](https://github.com/postrv/narsil-mcp) for full documentation, including:
- All 76 available MCP tools
- Advanced features (call graphs, security scanning, supply chain analysis)
- LSP integration
- Remote repository support

## Troubleshooting

If installation fails:

1. Update Homebrew: `brew update`
2. Check formula: `brew audit narsil-mcp`
3. Report issues at https://github.com/postrv/homebrew-narsil/issues

## License

This tap is licensed under MIT OR Apache-2.0, same as narsil-mcp itself.
