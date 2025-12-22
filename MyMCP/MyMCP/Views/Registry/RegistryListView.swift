import SwiftUI

struct RegistryListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = RegistryViewModel()
    @State private var selectedServer: MCPServer?

    var body: some View {
        HSplitView {
            serverList
                .frame(minWidth: 300, idealWidth: 400)

            Group {
                if let server = selectedServer {
                    ServerDetailView(server: server)
                } else {
                    EmptyStateView(
                        title: "Select a Server",
                        message: "Choose a server from the list to view details and install.",
                        systemImage: "server.rack"
                    )
                }
            }
            .frame(minWidth: 400)
        }
        .navigationTitle("MCP Registry")
        .onChange(of: appState.pendingRegistrySelection) { _, newValue in
            if let server = newValue {
                selectedServer = server
                appState.pendingRegistrySelection = nil
            }
        }
        .onAppear {
            if let pending = appState.pendingRegistrySelection {
                selectedServer = pending
                appState.pendingRegistrySelection = nil
            }
        }
    }

    private var serverList: some View {
        VStack(spacing: 0) {
            // Search bar
            SearchField(text: $viewModel.searchText, placeholder: "Search servers...")
                .padding()

            // Filter and sort controls
            HStack(spacing: 16) {
                // Type filter
                Menu {
                    Button("All") { viewModel.selectedPackageType = nil }
                    Divider()
                    ForEach(PackageRegistryType.allCases, id: \.self) { type in
                        Button(type.displayName) { viewModel.selectedPackageType = type }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease")
                        Text(viewModel.selectedPackageType?.displayName ?? "All")
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
                .menuStyle(.borderlessButton)

                Divider()
                    .frame(height: 16)

                // Sort menu
                Menu {
                    ForEach(SortOption.allCases) { option in
                        Button {
                            viewModel.sortOption = option
                        } label: {
                            Label(option.rawValue, systemImage: option.systemImage)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(viewModel.sortOption.rawValue)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
                .menuStyle(.borderlessButton)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            .padding(.bottom, 8)

            Divider()

            // Server list - wait for both registry and GitHub metadata
            if appState.isLoadingRegistry || appState.isLoadingMetadata {
                VStack {
                    Spacer()
                    ProgressView("Loading registry...")
                    Spacer()
                }
            } else {
                let filteredServers = viewModel.filteredServers(
                    from: appState.registryServers,
                    metadata: appState.githubMetadata
                )

                if filteredServers.isEmpty {
                    EmptyStateView(
                        title: "No Servers Found",
                        message: viewModel.searchText.isEmpty
                            ? "The registry appears to be empty."
                            : "Try adjusting your search or filters.",
                        systemImage: "magnifyingglass"
                    )
                } else {
                    List(filteredServers, selection: $selectedServer) { server in
                        RegistryServerRow(
                            server: server,
                            metadata: appState.githubMetadata[server.name]
                        )
                        .tag(server)
                    }
                    .listStyle(.inset)
                }
            }
        }
    }
}

#Preview {
    RegistryListView()
        .environmentObject(AppState())
}
