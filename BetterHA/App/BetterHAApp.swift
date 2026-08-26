import SwiftUI

@main
struct BetterHAApp: App {
    @StateObject private var store = TabConfigStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
