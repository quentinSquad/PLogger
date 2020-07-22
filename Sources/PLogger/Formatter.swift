//
//  Formatter.swift
//  Quentin Yann PIDOUX
//
//  Created by Quentin PIDOUX on 17/07/2020.
//  Copyright © 2020 Quentin PIDOUX. All rights reserved.
//

import Foundation

private extension String {
	func levelIndentation(_ level: Int, value: Any? = nil) -> String {
		var res = "|"
		for _ in 0...level {
			res += "\t"
		}
		if let value = value {
			return "\(res)\(self): \(value)\n"
		} else {
			return "\(res)\(self)\n"
		}
	}
}

struct FormattedResult: Equatable {
	let title: String?
	let values: [String: String]
	
	static func == (lhs: FormattedResult, rhs: FormattedResult) -> Bool {
		if lhs.values.count != rhs.values.count {
			return false
		}
		
		for left in lhs.values {
			if left.value != rhs.values[left.key] {
				return false
			}
		}
		
		return lhs.title == rhs.title
	}
}

class Formatter {

	func date(currentDate: Date = Date()) -> FormattedResult {
		FormattedResult(title: nil, values: ["Date": "\(currentDate)"])
	}

	func thread() -> FormattedResult {
		var results: [String: String] = [:]
		results["Stack size"] = "\(Thread.current.stackSize)"
		results["Priority"] 	= "\(Thread.current.threadPriority)"

		if let name = OperationQueue.current?.underlyingQueue?.label {
			results["Name"] = name
		}

		if Thread.current.isCancelled { results["Cancelled"] 		= "\(true)" }
		if Thread.current.isExecuting { results["Executing"] 		= "\(true)" }
		if Thread.current.isFinished { results["Finished"] 		= "\(true)" }
		if Thread.current.isMainThread { results["Main Thread"] 	= "\(true)" }

		return FormattedResult(title: "Thread", values: results)
	}

	func status(logType: PLogger.LogType) -> FormattedResult {
		var status = ""

		switch logType {
			case .INFO:
				status += "💙 \(logType.rawValue.capitalized)"
			case .DEBUG:
				status += "💜 \(logType.rawValue.capitalized)"
			case .VERBOSE:
				status += "💚 \(logType.rawValue.capitalized)"
			case .WARNING:
				status += "🧡 \(logType.rawValue.capitalized)"
			case .NOTICE:
				status += "🧡 \(logType.rawValue.capitalized)"
			case .ERROR:
				status += "❤️ \(logType.rawValue.capitalized)"
			case .FAULT:
				status += "🖤 \(logType.rawValue.capitalized)"
		}

		return FormattedResult(title: nil, values: ["Status": status])
	}

	func fileDescription(_ file    	: String,
											 _ function	: String,
											 line      	: Int,
											 column    	: Int) -> FormattedResult {
		var results: [String: String] = [:]

		if let file = file.components(separatedBy: "/").last {
			results["Name"] = "\(file)"
		}

		results["Function"] = "\(function)"
		results["Line"] 		= "\(line)"
		results["Column"] 	= "\(column)"

		return FormattedResult(title: "File", values: results)
	}

	func message(message : @autoclosure () -> Any) -> FormattedResult? {
		guard let message = message() as? String else { return nil }

		return FormattedResult(title: "Log", values: ["Message": message])
	}

	func error(message   : @autoclosure () -> Any,
						 context   : Any? = nil,
						 logType   : PLogger.LogType,
						 formatters: [PLoggerErrorFormater]) -> FormattedResult? {
		if let error = message() as? Error {
			return printError(error, formatters: formatters)
		}
		return nil
	}

	func context(context   : Any? = nil,
							 formatters: [PLoggerErrorFormater]) -> FormattedResult? {
		guard let context = context else { return nil }

		if let error = context as? Error {
			return printError(error, formatters: formatters)
		}

		return FormattedResult(title: nil, values: ["Context": "\(context)"])
	}

	func printError(_ error: Error,
									formatters: [PLoggerErrorFormater]) -> FormattedResult {
		var results: [String: String] = [:]

		for formatter in formatters {
			if type(of: error.self) == formatter.getErrorType() {
				for value in formatter.getErrorMessages(error) {
					results[value.key] = "\(value.value)"
				}
				return FormattedResult(title: formatter.getErrorName(), values: results)
			}
		}
		results["Localized"] 	= "\(error.localizedDescription)"
		results["Error"] 			= "\(error)"

		return FormattedResult(title: "Error", values: results)
	}

	func stringFormatter(_ input: FormattedResult) -> String {
		if let title = input.title {
			var string = title.levelIndentation(0)
			for value in input.values {
				string += value.key.levelIndentation(1, value: value.value)
			}
			return string
		} else {
			var string = ""
			for value in input.values {
				string += value.key.levelIndentation(0, value: value.value)
			}
			return string
		}
	}

	func composer(type: PLogger.LogType,
								message   : @autoclosure () -> Any,
								_ file    : String,
								_ function: String,
								line      : Int,
								column    : Int,
								context   : Any? = nil,
								formatters: [PLoggerErrorFormater]) -> String {

		var string = "\n┌--- logger\n"

		string += stringFormatter(self.date())
		string += stringFormatter(self.status(logType: type))

		switch type {
			case .INFO: break
			case .DEBUG:
				string += stringFormatter(self.fileDescription(file, function, line: line, column: column))
			case .VERBOSE, .WARNING, .NOTICE, .ERROR, .FAULT:
				string += stringFormatter(self.thread())
				string += stringFormatter(self.fileDescription(file, function, line: line, column: column))
		}

		if let value = self.message(message: message()) {
			string += stringFormatter(value)
		}

		if let value = self.error(message: message(), context: context, logType: type, formatters: formatters) {
			string += stringFormatter(value)
		}

		if let value = self.context(context: context, formatters: formatters) {
			string += stringFormatter(value)
		}

		string += "└-------\n"

		return string
	}
}
