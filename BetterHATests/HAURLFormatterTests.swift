import XCTest
@testable import BetterHA

final class HAURLFormatterTests: XCTestCase {
    func testBareIPGetsSchemeAndPort() {
        XCTAssertEqual(HAURLFormatter.format("192.168.1.10"), "http://192.168.1.10:8123")
    }

    func testHostnameGetsSchemeAndPort() {
        XCTAssertEqual(HAURLFormatter.format("myhome.duckdns.org"), "http://myhome.duckdns.org:8123")
    }

    func testExistingSchemeIsPreserved() {
        XCTAssertEqual(HAURLFormatter.format("https://myhome.duckdns.org"), "https://myhome.duckdns.org:8123")
    }

    func testExistingSchemeIsCaseInsensitive() {
        XCTAssertEqual(HAURLFormatter.format("HTTP://192.168.1.10"), "HTTP://192.168.1.10:8123")
    }

    func testExistingPortIsPreserved() {
        XCTAssertEqual(HAURLFormatter.format("192.168.1.10:8124"), "http://192.168.1.10:8124")
    }

    func testTrailingSlashIsStripped() {
        XCTAssertEqual(HAURLFormatter.format("192.168.1.10/"), "http://192.168.1.10:8123")
    }

    func testWhitespaceIsTrimmed() {
        XCTAssertEqual(HAURLFormatter.format("  192.168.1.10  "), "http://192.168.1.10:8123")
    }

    func testEmptyStringReturnsNil() {
        XCTAssertNil(HAURLFormatter.format(""))
    }

    func testWhitespaceOnlyReturnsNil() {
        XCTAssertNil(HAURLFormatter.format("   "))
    }
}
