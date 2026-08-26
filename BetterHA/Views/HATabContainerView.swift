import SwiftUI

struct HATabContainerView: View {
    @EnvironmentObject private var store: TabConfigStore
    let tabID: Int

    private var config: TabConfig? {
        store.configs.first { $0.id == tabID }
    }

    var body: some View {
        if let config, config.isConfigured {
            HATabView(config: config)
        } else {
            UnconfiguredTabView()
        }
    }
}
