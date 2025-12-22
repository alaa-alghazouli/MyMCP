import SwiftUI

/// Component for selecting Claude Code scopes to install a server to
struct ClaudeCodeScopeInstallSection: View {
    let server: UnifiedInstalledServer
    @Binding var selectedScopes: Set<ClaudeCodeScope>
    let knownProjectPaths: [String]

    @State private var isExpanded = false

    private var allScopes: [ClaudeCodeScope] {
        var scopes: [ClaudeCodeScope] = [.global]
        for path in knownProjectPaths {
            scopes.append(.local(projectPath: path))
            scopes.append(.project(projectPath: path))
        }
        return scopes.sorted()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header row
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Image(systemName: MCPClientType.claudeCode.systemIconFallback)
                        .foregroundStyle(MCPClientType.claudeCode.accentColor)
                        .frame(width: 24)

                    Text("Claude Code")

                    if !selectedScopes.isEmpty {
                        Text("(\(selectedScopes.count) selected)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
            }
            .buttonStyle(.plain)

            // Scope list
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(allScopes, id: \.self) { scope in
                        ScopeInstallToggleRow(
                            scope: scope,
                            isInstalled: server.claudeCodeScopes[scope] != nil,
                            isSelected: Binding(
                                get: { selectedScopes.contains(scope) },
                                set: { selected in
                                    if selected {
                                        selectedScopes.insert(scope)
                                    } else {
                                        selectedScopes.remove(scope)
                                    }
                                }
                            )
                        )
                    }
                }
                .padding(.leading, 32)
            }
        }
    }
}

struct ScopeInstallToggleRow: View {
    let scope: ClaudeCodeScope
    let isInstalled: Bool
    @Binding var isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Toggle("", isOn: $isSelected)
                .toggleStyle(.checkbox)
                .disabled(isInstalled)

            Image(systemName: scope.systemIconName)
                .foregroundStyle(scope.color)
                .frame(width: 16)

            Text(scope.displayName)
                .font(.subheadline)
                .foregroundStyle(isInstalled ? .secondary : .primary)

            if isInstalled {
                Text("(installed)")
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ClaudeCodeScopeInstallSection(
        server: UnifiedInstalledServer(
            id: "test",
            name: "test-server",
            clients: [:],
            registryServer: nil,
            claudeCodeScopes: [.global: InstalledServerConfig(name: "test", command: "npx", args: ["-y", "test"])]
        ),
        selectedScopes: .constant([]),
        knownProjectPaths: ["/Users/demo/project1", "/Users/demo/project2"]
    )
    .padding()
}
