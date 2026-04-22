@testable import Renami
import XCTest

final class AppInfoTests: XCTestCase {
    func testTitleIsConfigured() {
        XCTAssertEqual(AppInfo.title, "Renami")
    }
}
