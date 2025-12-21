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

            // Filter pills and sort picker
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterPill(title: "All", isSelected: viewModel.selectedPackageType == nil) {
                            viewModel.selectedPackageType = nil
                        }

                        ForEach(PackageRegistryType.allCases, id: \.self) { type in
                            FilterPill(
                                title: type.displayName,
                                isSelected: viewModel.selectedPackageType == type
                            ) {
                                viewModel.selectedPackageType = type
                            }
                        }
                    }
                    .padding(.leading)
                }

                // Sort picker
                Picker("Sort", selection: $viewModel.sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Label(option.rawValue, systemImage: option.systemImage)
                            .tag(option)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .frame(width: 140)
                .padding(.trailing)
            }
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
