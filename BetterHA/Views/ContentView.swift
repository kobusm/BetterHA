import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: TabConfigStore
    @AppStorage("lastActiveTabIndex") private var activeTab = 0

    var body: some View {
        TabView(selection: $activeTab) {
            ForEach(store.configs) { config in
                HATabContainerView(tabID: config.id)
                    .tabItem {
                        Label(config.displayName, systemImage: "house.fill")
                    }
                    .tag(config.id)
            }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
    }
}
