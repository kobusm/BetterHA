import Foundation

final class TabConfigStore: ObservableObject {
    @Published var configs: [TabConfig]

    private let defaults: UserDefaults
    private static let storageKey = "tabConfigs.v1"
    private static let tabCount = 4

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode([TabConfig].self, from: data),
           decoded.count == Self.tabCount {
            self.configs = decoded
        } else {
            self.configs = (0..<Self.tabCount).map { TabConfig(id: $0) }
        }
    }

    func update(_ config: TabConfig) {
        guard let index = configs.firstIndex(where: { $0.id == config.id }) else { return }
        configs[index] = config
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(configs) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
