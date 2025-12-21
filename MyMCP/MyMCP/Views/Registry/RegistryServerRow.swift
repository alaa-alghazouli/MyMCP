import SwiftUI

struct RegistryServerRow: View {
    @EnvironmentObject var appState: AppState
    let server: MCPServer
    var metadata: GitHubMetadata?

    private var installedClients: [MCPClientType] {
        appState.installedServers
            .first { $0.name == server.displayName || server.name.lowercased().contains($0.name.lowercased()) }?
            .installedClientTypes ?? []
    }

    var body: some View {
        HStack(spacing: 12) {
            // Server icon
            ServerIconView(url: server.iconURL, size: 36)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(server.displayName)
                        .font(.headline)
                        .lineLimit(1)

                    if !installedClients.isEmpty {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }

                    Spacer()

                    // GitHub stars badge (right-aligned)
                    if let meta = metadata {
                        StarsBadge(count: meta.stars)
                    }
                }

                if let description = server.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // Transport type badges and archived indicator
                HStack(spacing: 4) {
                    ForEach(server.uniqueTransportTypes.prefix(3), id: \.self) { transport in
                        TransportTypeBadge(type: transport)
                    }

                    Spacer()

                    // Archived badge (important warning)
                    if metadata?.archived == true {
                        ArchivedBadge()
                    }

                    // Installed client badges
                    if !installedClients.isEmpty {
                        ClientBadgeStack(clientTypes: installedClients, size: 20)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct TransportTypeBadge: View {
    let type: TransportType

    var color: Color {
        switch type {
        case .stdio: return .green
        case .sse: return .orange
        case .streamableHttp: return .blue
        case .unknown: return .gray
        }
    }

    var body: some View {
        Text(type.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .cornerRadius(4)
    }
}

struct PackageTypeBadge: View {
    let type: PackageRegistryType

    var color: Color {
        switch type {
        case .npm: return .red
        case .pypi: return .blue
        case .oci: return .cyan
        case .mcpb: return .purple
        case .unknown: return .gray
        }
    }

    var body: some View {
        Text(type.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .cornerRadius(4)
    }
}

#Preview {
    List {
        RegistryServerRow(
            server: MCPServer(
                name: "io.github.example/filesystem",
                title: "Filesystem",
                description: "A server for file system operations with support for reading and writing files.",
                version: "1.0.0",
                packages: [
                    MCPPackage(registryType: .npm, identifier: "@modelcontextprotocol/server-filesystem",
                               transport: MCPTransport(type: .stdio))
                ]
            ),
            metadata: GitHubMetadata(
                stars: 25271, forks: 1842, openIssues: 156,
                language: "TypeScript", topics: ["mcp", "ai"],
                license: "MIT", lastCommitAt: Date(), archived: false
            )
        )

        RegistryServerRow(
            server: MCPServer(
                name: "io.github.bytedance/mcp-server-search",
                title: "Search Server",
                description: "MCP server with multiple transports - shows stdio, sse, http badges.",
                version: "1.0.0",
                packages: [
                    MCPPackage(registryType: .npm, identifier: "@agent-infra/mcp-server-search",
                               transport: MCPTransport(type: .stdio)),
                    MCPPackage(registryType: .npm, identifier: "@agent-infra/mcp-server-search",
                               transport: MCPTransport(type: .sse, url: "http://127.0.0.1:8089/sse")),
                    MCPPackage(registryType: .npm, identifier: "@agent-infra/mcp-server-search",
                               transport: MCPTransport(type: .streamableHttp, url: "http://127.0.0.1:8089/mcp"))
                ]
            ),
            metadata: GitHubMetadata(
                stars: 19988, forks: 1908, openIssues: 308,
                language: "TypeScript", topics: ["mcp", "agent"],
                license: "Apache-2.0", lastCommitAt: Date(), archived: false
            )
        )

        RegistryServerRow(
            server: MCPServer(
                name: "io.github.example/no-transport",
                title: "No Transport",
                description: "A server without transport info (legacy package).",
                version: "1.0.0",
                packages: [MCPPackage(registryType: .pypi, identifier: "mcp-server-weather")]
            ),
            metadata: GitHubMetadata(
                stars: 42, forks: 5, openIssues: 2,
                language: "Python", topics: ["weather"],
                license: "MIT", lastCommitAt: Date(), archived: true
            )
        )
    }
    .environmentObject(AppState())
    .frame(width: 400, height: 400)
}
