import XCTest
@testable import PLogger

final class FormatterTests: XCTestCase {

	struct TestError: Error {
		let code: Int
	}
	
	func test_given_a_date_at_10091990_should_sucess_then_a_missmatch_date_should_fail() {
		let date 				= Date(timeIntervalSince1970: TimeInterval(exactly: 652960800) ?? 0)
		let secondDate 	= Date()
		
		let expected 		= FormattedResult(title: nil, values: ["Date": "\(date)"])
		let test 				= Formatter().date(currentDate: date)
		let secondTest 	= Formatter().date(currentDate: secondDate)
		
		XCTAssertEqual(test, expected)
		XCTAssertNotEqual(secondTest, expected)
	}
	
	
	func test_given_current_thread_should_be_equal() {
		let expected = FormattedResult(title: "Thread", values: ["Priority": "0.5",
																														 "Name": "com.apple.main-thread",
																														 "Executing": "true",
																														 "Stack size": "524288",
																														 "Main Thread": "true"])
		let test = Formatter().thread()
		
		XCTAssertEqual(test, expected)
	}
	
	func test_status_debug_should_be_equal_then_given_status_fault_should_not_be_equal() {
		let expected = FormattedResult(title: nil, values: ["Status": "💜 Debug"])
		let test = Formatter().status(logType: .DEBUG)
		let secondTest = Formatter().status(logType: .FAULT)

		XCTAssertEqual(test, expected)
		XCTAssertNotEqual(secondTest, expected)
	}
	
	func test_given_nothing_fileDescription_should_be_equal_then_given_coccupted_filename_sould_not_be_equal() {
		let expected = FormattedResult(title: "File", values: ["Line": "10",
																													 "Name": "FormatterTests.swift",
																													 "Function": "testFunction()",
																													 "Column": "80"])
		let test = Formatter().fileDescription("FormatterTests.swift",
																					 "testFunction()",
																					 line: 10,
																					 column: 80)
		
		
		let secondTest = Formatter().fileDescription("Formatter/Tests.swift",
																								 "testFunction()",
																								 line: 10,
																								 column: 80)

		
		XCTAssertEqual(test, expected)
		XCTAssertNotEqual(secondTest, expected)
	}
	
	func test_given_message_with_text_should_be_equal_then_given_int_should_be_nil() {
		let expected = FormattedResult(title: "Log", values: ["Message": "test output"])
		let test = Formatter().message(message: "test output")
		
		let secondTest = Formatter().message(message: 42)

		XCTAssertEqual(test, expected)
		XCTAssertNil(secondTest, "Result should be nil")
	}
	
	func test_context_given_string_should_be_equal_then_with_int_should_be_equal_then_with_error_and_no_formatter_should_be_equal_then_with_error_and_formatter_should_be_equal() {
		let expected = FormattedResult(title: nil, values: ["Context": "test"])
		let test = Formatter().context(context: "test", formatters: [])
		
		let secondExpected = FormattedResult(title: nil, values: ["Context": "42"])
		let secondTest = Formatter().context(context: 42, formatters: [])
		
		
		let error = TestError(code: 500)
		let thirdExpected = FormattedResult(title: "Error", values: ["Error": "TestError(code: 500)",
																																 "Localized": "The operation couldn’t be completed. (PLoggerTests.FormatterTests.TestError error 1.)"])
		let thirdTest = Formatter().context(context: error, formatters: [])
		
		
		class testFormatter: PLoggerErrorFormater {
			func getErrorType() -> Any.Type {
				TestError.self
			}
			func getErrorName() -> String {
				"TestError"
			}
			func getErrorMessages(_ error: Error) -> [String: Any] {
				guard ((error as? TestError) != nil) else {
					return [:]
				}
				let error = error as! TestError
				return ["code": error.code]
			}
		}
		
		let fourthExpected = FormattedResult(title: "TestError", values: ["code": "500"])
		let fourthTest = Formatter().context(context: error, formatters: [testFormatter()])
		
		XCTAssertEqual(test, expected)
		XCTAssertEqual(secondTest, secondExpected)
		XCTAssertEqual(thirdTest, thirdExpected)
		XCTAssertEqual(fourthTest, fourthExpected)
	}
	
	func test_stringformatter_given_full_object_should_be_equal_then_given_only_values_should_be_equal_then_given_only_title_should_be_equal_then_given_empty_object_should_be_equal() {
		let expected = """
		|	title
		|		val: output

		"""
		let test = Formatter().stringFormatter(FormattedResult(title: "title", values: ["val":"output"]))
		
		let secondExpected = """
		|	val: output

		"""
		let secondTest = Formatter().stringFormatter(FormattedResult(title: nil, values: ["val":"output"]))
		
		let thirdExpected = """
		|	title

		"""
		let thirdTest = Formatter().stringFormatter(FormattedResult(title: "title", values: [:]))
		
		let fourExpected = ""
		let fourTest = Formatter().stringFormatter(FormattedResult(title: nil, values: [:]))
		
		XCTAssertEqual(test, expected)
		XCTAssertEqual(secondTest, secondExpected)
		XCTAssertEqual(thirdTest, thirdExpected)
		XCTAssertEqual(fourTest, fourExpected)
	}
	
	static var allTests = [
		("date", test_given_a_date_at_10091990_should_sucess_then_a_missmatch_date_should_fail),
		("thread", test_given_current_thread_should_be_equal),
		("status", test_status_debug_should_be_equal_then_given_status_fault_should_not_be_equal),
		("fileDescription", test_given_nothing_fileDescription_should_be_equal_then_given_coccupted_filename_sould_not_be_equal),
		("message", test_given_message_with_text_should_be_equal_then_given_int_should_be_nil),
		("error", test_context_given_string_should_be_equal_then_with_int_should_be_equal_then_with_error_and_no_formatter_should_be_equal_then_with_error_and_formatter_should_be_equal),
		("string formatter", test_stringformatter_given_full_object_should_be_equal_then_given_only_values_should_be_equal_then_given_only_title_should_be_equal_then_given_empty_object_should_be_equal),
	]
}
