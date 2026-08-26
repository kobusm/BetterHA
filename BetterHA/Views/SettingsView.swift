import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: TabConfigStore

    var body: some View {
        NavigationStack {
            List(store.configs) { config in
                NavigationLink(config.displayName) {
                    TabConfigEditorView(config: config)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
