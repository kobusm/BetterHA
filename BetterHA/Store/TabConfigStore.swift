import Foundation

protocol KeyValueStoring: AnyObject {
    func data(forKey key: String) -> Data?
    func set(_ value: Any?, forKey key: String)
}

extension UserDefaults: KeyValueStoring {}
extension NSUbiquitousKeyValueStore: KeyValueStoring {}

final class TabConfigStore: ObservableObject {
    @Published var configs: [TabConfig]

    private let localStore: KeyValueStoring
    private let cloudStore: KeyValueStoring?
    private var cloudObserver: NSObjectProtocol?
    private static let storageKey = "tabConfigs.v1"
    private static let tabCount = 4

    init(
        localStore: KeyValueStoring = UserDefaults.standard,
        cloudStore: KeyValueStoring? = NSUbiquitousKeyValueStore.default
    ) {
        self.localStore = localStore
        self.cloudStore = cloudStore

        // Prefer iCloud's copy so a fresh install on another device picks up
        // settings already configured elsewhere, falling back to the local
        // cache (e.g. iCloud unavailable) and then to empty defaults.
        if let decoded = Self.decode(cloudStore?.data(forKey: Self.storageKey))
            ?? Self.decode(localStore.data(forKey: Self.storageKey)) {
            self.configs = decoded
        } else {
            self.configs = (0..<Self.tabCount).map { TabConfig(id: $0) }
        }

        if let cloudStore {
            (cloudStore as? NSUbiquitousKeyValueStore)?.synchronize()
            cloudObserver = NotificationCenter.default.addObserver(
                forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: cloudStore,
                queue: nil
            ) { [weak self] _ in
                self?.reloadFromCloud()
            }
        }
    }

    deinit {
        if let cloudObserver {
            NotificationCenter.default.removeObserver(cloudObserver)
        }
    }

    func update(_ config: TabConfig) {
        guard let index = configs.firstIndex(where: { $0.id == config.id }) else { return }
        configs[index] = config
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(configs) else { return }
        localStore.set(data, forKey: Self.storageKey)
        cloudStore?.set(data, forKey: Self.storageKey)
    }

    private func reloadFromCloud() {
        guard let data = cloudStore?.data(forKey: Self.storageKey),
              let decoded = Self.decode(data) else { return }
        configs = decoded
        localStore.set(data, forKey: Self.storageKey)
    }

    private static func decode(_ data: Data?) -> [TabConfig]? {
        guard let data, let decoded = try? JSONDecoder().decode([TabConfig].self, from: data),
              decoded.count == tabCount else { return nil }
        return decoded
    }
}
