import Foundation
import SwiftUI

/// Known MCP client applications
enum MCPClientType: String, CaseIterable, Identifiable, Codable {
    case claudeDesktop = "claude_desktop"
    case claudeCode = "claude_code"
    case cursor = "cursor"
    case vscode = "vscode"
    case windsurf = "windsurf"
    case geminiCLI = "gemini_cli"
    case openaiCodex = "openai_codex"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .claudeDesktop: return "Claude Desktop"
        case .claudeCode: return "Claude Code"
        case .cursor: return "Cursor"
        case .vscode: return "VS Code"
        case .windsurf: return "Windsurf"
        case .geminiCLI: return "Gemini CLI"
        case .openaiCodex: return "OpenAI Codex"
        }
    }

    var iconName: String {
        switch self {
        case .claudeDesktop: return "claude_icon"
        case .claudeCode: return "claude_code_icon"
        case .cursor: return "cursor_icon"
        case .vscode: return "vscode_icon"
        case .windsurf: return "windsurf_icon"
        case .geminiCLI: return "gemini_icon"
        case .openaiCodex: return "openai_icon"
        }
    }

    var systemIconFallback: String {
        switch self {
        case .claudeDesktop, .claudeCode: return "brain"
        case .cursor, .vscode, .windsurf: return "curlybraces"
        case .geminiCLI: return "sparkles"
        case .openaiCodex: return "terminal"
        }
    }

    var accentColor: Color {
        switch self {
        case .claudeDesktop, .claudeCode: return .orange
        case .cursor: return .blue
        case .vscode: return .cyan
        case .windsurf: return .green
        case .geminiCLI: return .blue
        case .openaiCodex: return .mint
        }
    }

    /// Whether this client uses TOML config format instead of JSON
    var usesTomlConfig: Bool {
        self == .openaiCodex
    }

    /// Paths to config files (relative to home directory)
    var configPaths: [String] {
        switch self {
        case .claudeDesktop:
            return ["Library/Application Support/Claude/claude_desktop_config.json"]
        case .claudeCode:
            // MCP servers defined in ~/.claude.json under "mcpServers" key
            // Note: ~/.claude/settings.json is for permissions, NOT for defining servers
            return [".claude.json"]
        case .cursor:
            return [".cursor/mcp.json"]
        case .vscode:
            return [
                "Library/Application Support/Code/User/settings.json",
                ".vscode/mcp.json"
            ]
        case .windsurf:
            // ~/.codeium/windsurf/mcp_config.json is the current standard location
            return [".codeium/windsurf/mcp_config.json"]
        case .geminiCLI:
            return [".gemini/settings.json"]
        case .openaiCodex:
            return [".codex/config.toml"]
        }
    }

    /// Bundle identifier for checking if app is installed
    var bundleIdentifiers: [String] {
        switch self {
        case .claudeDesktop: return ["com.anthropic.claudefordesktop"]
        case .claudeCode: return []
        case .cursor: return ["com.todesktop.230313mzl4w4u92"]
        case .vscode: return ["com.microsoft.VSCode"]
        case .windsurf: return ["com.codeium.windsurf"]
        case .geminiCLI: return []  // CLI tool
        case .openaiCodex: return []  // CLI tool
        }
    }

    /// Process names for detecting running status
    var processNames: [String] {
        switch self {
        case .claudeDesktop: return ["Claude"]
        case .claudeCode: return ["claude"]
        case .cursor: return ["Cursor"]
        case .vscode: return ["Code"]
        case .windsurf: return ["Windsurf"]
        case .geminiCLI: return ["gemini"]
        case .openaiCodex: return ["codex"]
        }
    }

    /// The key used in the config file to store MCP servers
    var configKey: String {
        switch self {
        case .claudeDesktop, .cursor, .windsurf, .claudeCode, .geminiCLI:
            return "mcpServers"
        case .vscode:
            return "mcp.servers"
        case .openaiCodex:
            return "mcp_servers"  // TOML table prefix
        }
    }

    /// Key path for accessing MCP servers in config dictionary
    /// Returns array of keys to traverse (e.g., ["mcpServers"] or ["mcp", "servers"])
    var serversKeyPath: [String] {
        switch self {
        case .vscode:
            return ["mcp", "servers"]
        case .openaiCodex:
            return []  // TOML handled separately
        default:
            return ["mcpServers"]
        }
    }

    /// CLI command name for CLI-based clients (used for detection via `which`)
    var cliCommand: String? {
        switch self {
        case .claudeCode: return "claude"
        case .geminiCLI: return "gemini"
        case .openaiCodex: return "codex"
        default: return nil
        }
    }
}

/// Represents a detected MCP client on the system
struct MCPClient: Identifiable, Hashable {
    let id: UUID
    let type: MCPClientType
    let configPath: URL?
    let isInstalled: Bool
    var installedServers: [String: InstalledServerConfig]

    init(type: MCPClientType, configPath: URL? = nil, isInstalled: Bool = false,
         installedServers: [String: InstalledServerConfig] = [:]) {
        self.id = UUID()
        self.type = type
        self.configPath = configPath
        self.isInstalled = isInstalled
        self.installedServers = installedServers
    }

    static func == (lhs: MCPClient, rhs: MCPClient) -> Bool {
        lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}
