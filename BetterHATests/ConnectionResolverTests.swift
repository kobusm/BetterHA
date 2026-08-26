import XCTest
@testable import BetterHA

final class ConnectionResolverTests: XCTestCase {
    private let localURL = URL(string: "http://192.168.1.10:8123")!
    private let remoteURL = URL(string: "http://myhome.duckdns.org:8123")!

    func testReturnsLocalWhenLocalReachable() async {
        let result = await ConnectionResolver.resolve(
            localURL: localURL,
            remoteURL: remoteURL,
            probe: { url, _ in url == self.localURL }
        )
        XCTAssertEqual(result, .local(localURL))
    }

    func testFallsBackToRemoteWhenLocalUnreachable() async {
        let result = await ConnectionResolver.resolve(
            localURL: localURL,
            remoteURL: remoteURL,
            probe: { url, _ in url == self.remoteURL }
        )
        XCTAssertEqual(result, .remote(remoteURL))
    }

    func testReturnsNilWhenBothUnreachable() async {
        let result = await ConnectionResolver.resolve(
            localURL: localURL,
            remoteURL: remoteURL,
            probe: { _, _ in false }
        )
        XCTAssertNil(result)
    }

    func testReturnsNilWhenNoURLsProvided() async {
        let result = await ConnectionResolver.resolve(
            localURL: nil,
            remoteURL: nil,
            probe: { _, _ in true }
        )
        XCTAssertNil(result)
    }

    func testSkipsLocalProbeWhenLocalURLIsNil() async {
        let result = await ConnectionResolver.resolve(
            localURL: nil,
            remoteURL: remoteURL,
            probe: { url, _ in url == self.remoteURL }
        )
        XCTAssertEqual(result, .remote(remoteURL))
    }
}
