import XCTest
@testable import PLogger

final class PLoggerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PLogger().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
