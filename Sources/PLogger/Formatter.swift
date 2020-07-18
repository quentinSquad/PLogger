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

class Formatter {
	
	func date(to message: String) -> String {
		let val = "Date".levelIndentation(0, value: Date())
		return "\(message)\(val)"
	}
	
	func thread(to message: String) -> String {
		var string = "Thread".levelIndentation(0)
		
		string += "Stack size".levelIndentation(1, value: Thread.current.stackSize)
		string += "Priority".levelIndentation(1, value: Thread.current.threadPriority)
		
		if let name = OperationQueue.current?.underlyingQueue?.label {
			string += "Name".levelIndentation(1, value: name)
		}
		
		if Thread.current.isCancelled 	{ string += "Cancelled".levelIndentation(1, value: true)}
		if Thread.current.isExecuting 	{ string += "Executing".levelIndentation(1, value: true) }
		if Thread.current.isFinished 		{ string += "Finished".levelIndentation(1, value: true) }
		if Thread.current.isMainThread 	{ string += "Main Thread".levelIndentation(1, value: true) }
		
		return "\(message)\(string)"
	}
	
	func status(to message: String,
							type: PLogger.LogType) -> String {
		var status = ""
		
		switch type {
			case .INFO:
				status += "💙 \(type.rawValue.capitalized)"
			case .DEBUG:
				status += "💜 \(type.rawValue.capitalized)"
			case .VERBOSE:
				status += "💚 \(type.rawValue.capitalized)"
			case .WARNING:
				status += "🧡 \(type.rawValue.capitalized)"
			case .NOTICE:
				status += "🧡 \(type.rawValue.capitalized)"
			case .ERROR:
				status += "❤️ \(type.rawValue.capitalized)"
			case .FAULT:
				status += "🖤 \(type.rawValue.capitalized)"
		}
		
		let string = "Status".levelIndentation(0, value: status)
		return "\(message)\(string)"
	}
	
	func FileDescription(to message	: String,
											 _ file    	: String,
											 _ function	: String,
											 line      	: Int,
											 column    	: Int) -> String {
		var string = "File".levelIndentation(0)
		if let file = file.components(separatedBy: "/").last {
			string += "Name".levelIndentation(1, value: file)
		}
		
		string += "Function".levelIndentation(1, value: function)
		string += "Line".levelIndentation(1, value: line)
		string += "Column".levelIndentation(1, value: column)
		
		return "\(message)\(string)"
	}
	
	func message(to dest	: String,
							 message : @autoclosure () -> Any) -> String {
		
		guard let message = message() as? String else { return dest }
		
		var string = "Log".levelIndentation(0)
		string += "Message".levelIndentation(1, value: message)
		
		return "\(dest)\(string)"
	}
	
	func error(to dest	: String,
						 message   : @autoclosure () -> Any,
						 context   : Any? = nil,
						 logType   : PLogger.LogType,
						 formatters: [PLoggerErrorFormater]) -> String {
		if logType == .ERROR || logType == .FAULT {
			if let error = message() as? Error {
				var string = "Error".levelIndentation(0)
				
				var formatterFounded = false
				for formatter in formatters {
					if type(of: error.self) == formatter.getErrorType() {
						formatterFounded = true
						string += formatter.getErrorName().levelIndentation(1)
						for value in formatter.getErrorMessages(error) {
							string += value.0.levelIndentation(2, value: value.1)
						}
					}
				}
				if formatterFounded == false {
					string += "Localized".levelIndentation(1, value: error.localizedDescription)
					string += "Error".levelIndentation(1, value: error)
				}
				return "\(dest)\(string)"
			}
		}
		return dest
	}
	
	func context(to dest	: String,
							 context   : Any? = nil,
							 formatters: [PLoggerErrorFormater]) -> String {
		guard let context = context else { return dest }
		if let error = context as? Error {
			var string = "Error".levelIndentation(0)
			var formatterFounded = false
			for formatter in formatters {
				if type(of: error.self) == formatter.getErrorType() {
					formatterFounded = true
					string += formatter.getErrorName().levelIndentation(1)
					for value in formatter.getErrorMessages(error) {
						string += value.0.levelIndentation(2, value: value.1)
					}
				}
			}
			if formatterFounded == false {
				string += "Localized".levelIndentation(1, value: error.localizedDescription)
				string += "Error".levelIndentation(1, value: error)
			}
			return "\(dest)\(string)"
		}
		
		return "\(dest)Context".levelIndentation(1, value: context)
	}
	
	func composer(type: PLogger.LogType,
								message   : @autoclosure () -> Any,
								_ file    : String,
								_ function: String,
								line      : Int,
								column    : Int,
								context   : Any? = nil,
								formatters: [PLoggerErrorFormater]) -> String {
		
		var string = "┌--- logger\n"
		
		string = self.date(to: string)
		string = self.status(to: string, type: type)
		
		switch type {
			case .INFO: break
			case .DEBUG:
				string = self.FileDescription(to: string, file, function, line: line, column: column)
			case .VERBOSE, .WARNING, .NOTICE, .ERROR, .FAULT:
				string = self.thread(to: string)
				string = self.FileDescription(to: string, file, function, line: line, column: column)
		}
		
		string = self.message(to: string, message: message())
		string = self.error(to: string, message: message(), context: context, logType: type, formatters: formatters)
		string = self.context(to: string, context: context, formatters: formatters)
		string += "└-------\n"
		
		return string
	}
}
