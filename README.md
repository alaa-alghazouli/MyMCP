# MyMCP

A native macOS application for managing Model Context Protocol (MCP) servers across multiple AI clients.

## What is MyMCP?

MyMCP is a GUI tool that makes it easy to:

- **Discover** MCP servers from the official registry
- **Install** servers to multiple clients with one click
- **Manage** your installed servers across all your AI tools
- **Enable/disable** servers without losing configuration

Instead of manually editing JSON config files for each client, MyMCP provides a unified interface to manage your MCP servers.

## Supported Clients

MyMCP automatically detects and manages servers for:

| Client | Config Format | Config Location |
|--------|--------------|-----------------|
| Claude Desktop | JSON | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Claude Code | JSON | `~/.claude.json` |
| Cursor | JSON | `~/.cursor/mcp.json` |
| VS Code | JSON | `~/Library/Application Support/Code/User/settings.json` |
| Windsurf | JSON | `~/.codeium/windsurf/mcp_config.json` |
| Gemini CLI | JSON | `~/.gemini/settings.json` |
| OpenAI Codex | TOML | `~/.codex/config.toml` |

## Features

- **Registry Browser**: Browse and search the official MCP server registry
- **One-Click Install**: Install servers to multiple clients simultaneously
- **Server Management**: View, enable, disable, or uninstall servers
- **Client Overview**: See all servers installed in each client
- **Environment Variables**: Configure API keys and other env vars during install
- **GitHub Metadata**: View stars, forks, and activity for registry servers

## Requirements

- macOS 15.0 (Sequoia) or later
- Xcode 16.0+ (for building from source)

## Installation

### Download Release

Download the latest `.app` from the [Releases](https://github.com/joshka/MyMCP/releases) page.

### Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/joshka/MyMCP.git
   cd MyMCP
   ```

2. Open in Xcode:
   ```bash
   open MyMCP/MyMCP.xcodeproj
   ```

3. Build and run (Cmd+R)

## Usage

1. **Browse Registry**: Select "Registry" in the sidebar to discover available MCP servers
2. **Install Server**: Click on a server, select which clients to install to, and click "Install"
3. **Manage Installed**: Select "Installed" to see all your servers and manage them
4. **Client Details**: Click on a client in the sidebar to see its specific configuration

## Architecture

```
MyMCP/
├── Models/          # Data models (MCPServer, MCPClient, etc.)
├── Services/        # Business logic (ConfigFileService, RegistryService, etc.)
├── ViewModels/      # State management (AppState)
└── Views/           # SwiftUI components
    ├── Registry/    # Server browser views
    ├── Installed/   # Installed server management
    ├── Clients/     # Per-client views
    ├── Sidebar/     # Navigation
    └── Shared/      # Reusable components
```

## Notes

### GitHub Metadata

The GitHub metadata feature (stars, forks, activity indicators) fetches data from an external API. If unavailable, servers will still display but without GitHub stats. This feature is optional and does not affect core functionality.

### Config File Safety

MyMCP reads and writes to your client config files. It:
- Creates backups before modifying
- Preserves existing configuration not related to MCP
- Logs all operations for debugging

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

MIT License - see [LICENSE](LICENSE) for details.
