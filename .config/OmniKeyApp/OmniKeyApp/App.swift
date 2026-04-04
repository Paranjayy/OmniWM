// OmniKeyApp — SwiftUI Mac App
// Visual keyboard layer editor that exports to Karabiner JSON

import SwiftUI

@main
struct OmniKeyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
