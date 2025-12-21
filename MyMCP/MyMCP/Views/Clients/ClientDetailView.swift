import SwiftUI

struct ClientDetailView: View {
    @EnvironmentObject var appState: AppState
    let client: MCPClient

    // Uninstall flow state
    @State private var serverToUninstall: InstalledServerConfig?
    @State private var showUninstallConfirm = false
    @State private var showProgressSheet = false
    @State private var uninstallSteps: [InstallationStep] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                Divider()

                overviewSection

                if let configPath = client.configPath {
                    configFileSection(configPath)
                }

                installedServersSection
            }
            .padding()
        }
        .navigationTitle(client.type.displayName)
        .confirmationDialog(
            "Uninstall Server",
            isPresented: $showUninstallConfirm,
            presenting: serverToUninstall
        ) { config in
            Button("Uninstall from \(client.type.displayName)", role: .destructive) {
                performUninstall(config)
            }
            Button("Cancel", role: .cancel) {}
        } message: { config in
            Text("Are you sure you want to uninstall \"\(config.name)\" from \(client.type.displayName)?")
        }
        .sheet(isPresented: $showProgressSheet) {
            InstallationProgressSheet(
                title: "Uninstalling",
                serverName: serverToUninstall?.name ?? "",
                steps: $uninstallSteps,
                onDismiss: { showProgressSheet = false }
            )
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(client.type.accentColor.opacity(0.15))
                Image(systemName: client.type.systemIconFallback)
                    .font(.system(size: 32))
                    .foregroundStyle(client.type.accentColor)
            }
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text(client.type.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Spacer()

            if client.isInstalled {
                Button("Open \(client.type.displayName)") {
                    openClient()
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)

            HStack(spacing: 16) {
                StatusCard(
                    title: "Servers",
                    value: "\(client.installedServers.count)",
                    color: .blue,
                    icon: "server.rack"
                )
            }
        }
    }

    private func configFileSection(_ configPath: URL) -> some View {
        let configExists = FileManager.default.fileExists(atPath: configPath.path)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Configuration File")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text(configPath.path)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    if configExists {
                        Button(action: {
                            NSWorkspace.shared.selectFile(
                                configPath.path,
                                inFileViewerRootedAtPath: configPath.deletingLastPathComponent().path
                            )
                        }) {
                            Label("Show in Finder", systemImage: "folder")
                        }
                        .buttonStyle(.bordered)

                        Button(action: {
                            NSWorkspace.shared.open(configPath)
                        }) {
                            Label("Edit Config", systemImage: "pencil")
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button(action: {
                            createConfigFile(at: configPath)
                        }) {
                            Label("Create Config", systemImage: "plus")
                        }
                        .buttonStyle(.bordered)
                    }

                    CopyButton(configPath.path, label: "Copy Path")
                        .buttonStyle(.borderless)
                }
            }
            .sectionStyle()
        }
    }

    private func createConfigFile(at path: URL) {
        do {
            let directory = path.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try "{}".write(to: path, atomically: true, encoding: .utf8)
            NSWorkspace.shared.open(path)
        } catch {
            MCPLogger.ui.error("Failed to create config at \(path.path, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Disabled servers for this client
    private var disabledServersForClient: [DisabledServerEntry] {
        appState.disabledServersStore.entries.filter { $0.clientType == client.type }
    }

    private var installedServersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Servers")
                    .font(.headline)

                if !disabledServersForClient.isEmpty {
                    Text("(\(disabledServersForClient.count) disabled)")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                Spacer()

                Text("\(client.installedServers.count) enabled")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            let hasAnyServers = !client.installedServers.isEmpty || !disabledServersForClient.isEmpty

            if !hasAnyServers {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)

                    Text("No servers installed")
                        .foregroundStyle(.secondary)

                    Text("Browse the Registry to discover and install MCP servers.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .cardStyle(padding: 0)
            } else {
                // Enabled servers
                ForEach(Array(client.installedServers.values.sorted(by: { $0.name < $1.name })), id: \.name) { config in
                    ClientServerRow(
                        config: config,
                        clientType: client.type,
                        registryServer: unifiedServer(for: config.name)?.registryServer,
                        isEnabled: true,
                        onViewInRegistry: {
                            if let unified = unifiedServer(for: config.name) {
                                if let repoURL = unified.registryServer?.repository?.url,
                                   !repoURL.isEmpty,
                                   let url = URL(string: repoURL) {
                                    NSWorkspace.shared.open(url)
                                } else {
                                    appState.navigateToRegistryEntry(for: unified)
                                }
                            }
                        },
                        onUninstall: {
                            serverToUninstall = config
                            showUninstallConfirm = true
                        }
                    )
                }

                // Disabled servers
                ForEach(disabledServersForClient.sorted(by: { $0.serverName < $1.serverName })) { entry in
                    ClientServerRow(
                        config: entry.config.toInstalledServerConfig(name: entry.serverName),
                        clientType: client.type,
                        registryServer: unifiedServer(for: entry.serverName)?.registryServer,
                        isEnabled: false,
                        onViewInRegistry: {
                            if let unified = unifiedServer(for: entry.serverName) {
                                if let repoURL = unified.registryServer?.repository?.url,
                                   !repoURL.isEmpty,
                                   let url = URL(string: repoURL) {
                                    NSWorkspace.shared.open(url)
                                } else {
                                    appState.navigateToRegistryEntry(for: unified)
                                }
                            }
                        },
                        onUninstall: {}  // Can't uninstall disabled servers
                    )
                }
            }
        }
    }

    private func openClient() {
        if let bundleId = client.type.bundleIdentifiers.first,
           let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Registry Server Lookup

    private func unifiedServer(for serverName: String) -> UnifiedInstalledServer? {
        appState.installedServers.first { $0.name == serverName }
    }

    // MARK: - Uninstall Actions

    private func performUninstall(_ config: InstalledServerConfig) {
        guard let configPath = client.configPath else { return }

        uninstallSteps = [InstallationStep(clientType: client.type, configPath: configPath)]
        showProgressSheet = true

        Task {
            var steps = uninstallSteps
            steps[0].status = .inProgress
            steps[0].message = "Removing from \(client.type.displayName)..."
            uninstallSteps = steps

            do {
                try await appState.uninstallServer(config.name, fromClient: client.type)
                var steps = uninstallSteps
                steps[0].status = .success
                steps[0].message = "Removed successfully"
                uninstallSteps = steps
            } catch {
                var steps = uninstallSteps
                steps[0].status = .failed(error.localizedDescription)
                steps[0].message = error.localizedDescription
                uninstallSteps = steps
            }

            serverToUninstall = nil
        }
    }
}

struct ClientServerRow: View {
    @EnvironmentObject var appState: AppState
    let config: InstalledServerConfig
    let clientType: MCPClientType
    let registryServer: MCPServer?
    let isEnabled: Bool
    let onViewInRegistry: (() -> Void)?
    let onUninstall: () -> Void

    @State private var isToggling = false

    var body: some View {
        HStack {
            Image(systemName: "server.rack")
                .foregroundStyle(isEnabled ? .secondary : .tertiary)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(config.name)
                        .font(.headline)
                        .foregroundStyle(isEnabled ? .primary : .secondary)

                    if !isEnabled {
                        DisabledBadge()
                    }
                }

                // Description from registry
                if let description = registryServer?.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            // Action buttons
            HStack(spacing: 8) {
                // Enable/Disable toggle
                if isToggling {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Toggle("", isOn: Binding(
                        get: { isEnabled },
                        set: { toggleEnabled($0) }
                    ))
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .help(isEnabled ? "Disable" : "Enable")
                }

                // Open repository or view in Registry
                if registryServer != nil, let onViewInRegistry {
                    Button(action: onViewInRegistry) {
                        Image(systemName: "globe")
                    }
                    .buttonStyle(.borderless)
                    .help(registryServer?.repository?.url != nil ? "Open Repository" : "View in Registry")
                }

                // Uninstall button (only for enabled servers)
                if isEnabled {
                    Button(action: onUninstall) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.red)
                    .help("Uninstall from \(clientType.displayName)")
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .opacity(isEnabled ? 1.0 : 0.7)
    }

    private func toggleEnabled(_ newValue: Bool) {
        isToggling = true
        Task {
            _ = await appState.toggleServerEnabled(config.name, enabled: newValue, forClient: clientType)
            await MainActor.run { isToggling = false }
        }
    }
}

#Preview {
    ClientDetailView(client: MCPClient(
        type: .claudeDesktop,
        configPath: URL(fileURLWithPath: "/Users/demo/Library/Application Support/Claude/claude_desktop_config.json"),
        isInstalled: true,
        installedServers: [
            "filesystem": InstalledServerConfig(
                name: "filesystem",
                command: "npx",
                args: ["-y", "@modelcontextprotocol/server-filesystem"]
            ),
            "weather": InstalledServerConfig(
                name: "weather",
                command: "uvx",
                args: ["mcp-server-weather"],
                env: ["API_KEY": "secret"]
            )
        ]
    ))
    .environmentObject(AppState())
    .frame(width: 600, height: 700)
}
