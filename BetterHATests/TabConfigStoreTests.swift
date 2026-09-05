import XCTest
@testable import BetterHA

final class FakeKeyValueStore: KeyValueStoring {
    private var storage: [String: Any] = [:]

    func data(forKey key: String) -> Data? {
        storage[key] as? Data
    }

    func string(forKey key: String) -> String? {
        storage[key] as? String
    }

    func set(_ value: Any?, forKey key: String) {
        if let value {
            storage[key] = value
        } else {
            storage.removeValue(forKey: key)
        }
    }
}

final class TabConfigStoreTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "TabConfigStoreTests")
        defaults.removePersistentDomain(forName: "TabConfigStoreTests")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "TabConfigStoreTests")
        defaults = nil
        super.tearDown()
    }

    func testInitializesFourEmptyConfigs() {
        let store = TabConfigStore(localStore: defaults, cloudStore: nil)
        XCTAssertEqual(store.configs.count, 4)
        XCTAssertEqual(store.configs.map(\.id), [0, 1, 2, 3])
        XCTAssertTrue(store.configs.allSatisfy { !$0.isConfigured })
    }

    func testUpdatePersistsAndReloads() {
        let store = TabConfigStore(localStore: defaults, cloudStore: nil)
        var config = store.configs[1]
        config.name = "Living Room"
        config.localAddress = "192.168.1.10"
        store.update(config)

        XCTAssertEqual(store.configs[1].name, "Living Room")

        let reloaded = TabConfigStore(localStore: defaults, cloudStore: nil)
        XCTAssertEqual(reloaded.configs[1].name, "Living Room")
        XCTAssertEqual(reloaded.configs[1].localAddress, "192.168.1.10")
    }

    func testUpdateIgnoresUnknownID() {
        let store = TabConfigStore(localStore: defaults, cloudStore: nil)
        let bogus = TabConfig(id: 99, name: "Nope")
        store.update(bogus)
        XCTAssertFalse(store.configs.contains { $0.id == 99 })
    }

    func testUpdateWritesToCloudStore() {
        let cloud = FakeKeyValueStore()
        let store = TabConfigStore(localStore: defaults, cloudStore: cloud)
        var config = store.configs[2]
        config.name = "Garage"
        config.localAddress = "192.168.1.20"
        config.remoteAddress = "garage.duckdns.org"
        store.update(config)

        // A second store backed by the same cloud data (fresh install / new
        // device) should pick up the full config, addresses included, not
        // just the name.
        let otherDeviceDefaults = UserDefaults(suiteName: "TabConfigStoreTests.otherDevice")
        otherDeviceDefaults?.removePersistentDomain(forName: "TabConfigStoreTests.otherDevice")
        let otherDevice = TabConfigStore(localStore: otherDeviceDefaults!, cloudStore: cloud)
        XCTAssertEqual(otherDevice.configs[2].name, "Garage")
        XCTAssertEqual(otherDevice.configs[2].localAddress, "192.168.1.20")
        XCTAssertEqual(otherDevice.configs[2].remoteAddress, "garage.duckdns.org")
        otherDeviceDefaults?.removePersistentDomain(forName: "TabConfigStoreTests.otherDevice")
    }

    func testExternalCloudChangeUpdatesConfigs() {
        let cloud = FakeKeyValueStore()
        let store = TabConfigStore(localStore: defaults, cloudStore: cloud)

        var updated = store.configs
        updated[0].name = "Kitchen"
        updated[0].localAddress = "10.0.0.5"
        let data = try! JSONEncoder().encode(updated)
        cloud.set(data.base64EncodedString(), forKey: "tabConfigs.v1")

        NotificationCenter.default.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloud
        )

        XCTAssertEqual(store.configs[0].name, "Kitchen")
        XCTAssertEqual(store.configs[0].localAddress, "10.0.0.5")
    }
}
