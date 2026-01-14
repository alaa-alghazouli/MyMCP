import SwiftUI
import Sentry

enum WindowID {
    static let main = "main-window"
}

@main
struct MyMCPApp: App {
    @StateObject private var appState = AppState()

    init() {
        // Only initialize Sentry if DSN is provided via environment variable
        // This allows open source users to opt-out of crash reporting
        if let sentryDSN = ProcessInfo.processInfo.environment["SENTRY_DSN"], !sentryDSN.isEmpty {
            SentrySDK.start { options in
                options.dsn = sentryDSN
                options.debug = false
                options.tracesSampleRate = 1.0
                options.sendDefaultPii = false
                options.attachStacktrace = true

                #if DEBUG
                options.environment = "development"
                #else
                options.environment = "production"
                #endif
            }
        }
    }

    var body: some Scene {
        // Main window
        WindowGroup(id: WindowID.main) {
            ContentView()
                .frame(minWidth: 900, minHeight: 600)
                .environmentObject(appState)
                .handlesExternalEvents(preferring: [WindowID.main], allowing: [WindowID.main])
        }
        .handlesExternalEvents(matching: [WindowID.main])
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
