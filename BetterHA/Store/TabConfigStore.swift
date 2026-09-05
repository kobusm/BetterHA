import Foundation

protocol KeyValueStoring: AnyObject {
    func data(forKey key: String) -> Data?
    func string(forKey key: String) -> String?
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
        if let decoded = Self.decode(Self.cloudData(cloudStore))
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
        // NSUbiquitousKeyValueStore is a property-list store at heart; a raw
        // binary Data blob has historically synced far less reliably through
        // it than a plist-native String, which is why addresses (part of the
        // same blob as everything else) could silently fail to propagate.
        // Base64-encoding to a String sidesteps that.
        cloudStore?.set(data.base64EncodedString(), forKey: Self.storageKey)
    }

    private func reloadFromCloud() {
        guard let data = Self.cloudData(cloudStore),
              let decoded = Self.decode(data) else { return }
        configs = decoded
        localStore.set(data, forKey: Self.storageKey)
    }

    private static func cloudData(_ cloudStore: KeyValueStoring?) -> Data? {
        guard let base64 = cloudStore?.string(forKey: Self.storageKey) else { return nil }
        return Data(base64Encoded: base64)
    }

    private static func decode(_ data: Data?) -> [TabConfig]? {
        guard let data, let decoded = try? JSONDecoder().decode([TabConfig].self, from: data),
              decoded.count == tabCount else { return nil }
        return decoded
    }
}
