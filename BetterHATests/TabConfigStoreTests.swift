import XCTest
@testable import BetterHA

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
        let store = TabConfigStore(defaults: defaults)
        XCTAssertEqual(store.configs.count, 4)
        XCTAssertEqual(store.configs.map(\.id), [0, 1, 2, 3])
        XCTAssertTrue(store.configs.allSatisfy { !$0.isConfigured })
    }

    func testUpdatePersistsAndReloads() {
        let store = TabConfigStore(defaults: defaults)
        var config = store.configs[1]
        config.name = "Living Room"
        config.localAddress = "192.168.1.10"
        store.update(config)

        XCTAssertEqual(store.configs[1].name, "Living Room")

        let reloaded = TabConfigStore(defaults: defaults)
        XCTAssertEqual(reloaded.configs[1].name, "Living Room")
        XCTAssertEqual(reloaded.configs[1].localAddress, "192.168.1.10")
    }

    func testUpdateIgnoresUnknownID() {
        let store = TabConfigStore(defaults: defaults)
        let bogus = TabConfig(id: 99, name: "Nope")
        store.update(bogus)
        XCTAssertFalse(store.configs.contains { $0.id == 99 })
    }
}
