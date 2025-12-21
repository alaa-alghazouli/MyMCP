import SwiftUI

@main
struct MyMCPApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        // Main window
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, minHeight: 600)
                .environmentObject(appState)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1100, height: 750)
        .commands {
            CommandGroup(replacing: .newItem) { }

            CommandMenu("Server") {
                Button("Refresh All") {
                    Task { await appState.refreshAll() }
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }

        // Menu bar extra
        MenuBarExtra("MyMCP", systemImage: "server.rack") {
            MenuBarView()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.window)
    }
}
