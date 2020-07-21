import XCTest

import PLoggerTests

var tests = [XCTestCaseEntry]()
tests += PLoggerTests.allTests()
tests += FormatterTests.allTests()
XCTMain(tests)
