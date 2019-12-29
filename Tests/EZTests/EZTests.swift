import XCTest
@testable import EZ

final class EZTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        class TestApp: EZApp {
            var database: EZDatabase = EZDatabase()
            
            var migrations: [Migration] = []
        }
        
        let app = TestApp()
        XCTAssertNoThrow(try app.configureDatabase())
        
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
