import XCTest
@testable import EZ

final class EZTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        _ = EZDatabase()
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
