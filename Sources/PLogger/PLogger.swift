//
//  Plogger.swift
//  Quentin Yann PIDOUX
//
//  Created by Quentin PIDOUX on 09/10/2019.
//  Copyright © 2019 Quentin PIDOUX. All rights reserved.
//

import Foundation
import os.log

//let log = PLogger.self

public class PLogger {
	enum LogType: String {
		case INFO
		case DEBUG
		case VERBOSE
		case WARNING
		case NOTICE
		case ERROR
		case FAULT
	}
	
	private static var formaters: [PLoggerErrorFormater] = []
	
	static public func addFormater(_ formater: PLoggerErrorFormater) {
		self.formaters.append(formater)
	}
	
	static public func info(_ message   : @autoclosure () -> Any,
													_ file      : String 	= #file,
													_ function  : String 	= #function,
													line        : Int 		= #line,
													column      : Int 		= #column,
													context     : Any? 		= nil,
													isPrivate	 	: Bool 		= false) {
		
		self.printLog(type		: .INFO,
									message	: message(),
									file,
									function,
									line		: line,
									column	: column,
									context	: context,
									isPrivate: isPrivate)
	}
	
	static public func debug(_ message   : @autoclosure () -> Any,
													 _ file      : String = #file,
													 _ function  : String = #function,
													 line        : Int 		= #line,
													 column      : Int 		= #column,
													 context     : Any? 	= nil,
													 isPrivate	 : Bool 	= false) {
		self.printLog(type 		: .DEBUG,
									message : message(),
									file,
									function,
									line    : line,
									column  : column,
									context : context,
									isPrivate: isPrivate)
	}
	
	static public func verbose(_ message   : @autoclosure () -> Any,
														 _ file      : String = #file,
														 _ function  : String = #function,
														 line        : Int 		= #line,
														 column      : Int 		= #column,
														 context     : Any? 	= nil,
														 isPrivate	 : Bool 	= false) {
		self.printLog(type    : .VERBOSE,
									message : message(),
									file,
									function,
									line    : line,
									column  : column,
									context : context,
									isPrivate: isPrivate)
	}
	
	@available(*, deprecated, renamed: "notice")
	static public func warning(_ message   : @autoclosure () -> Any,
														 _ file      : String = #file,
														 _ function  : String = #function,
														 line        : Int 		= #line,
														 column      : Int 		= #column,
														 context     : Any? 	= nil,
														 isPrivate	 : Bool 	= false) {
		self.printLog(type    : .WARNING,
									message : message(),
									file,
									function,
									line    : line,
									column  : column,
									context : context,
									isPrivate: isPrivate)
	}
	
	static public func notice(_ message   : @autoclosure () -> Any,
														_ file      : String = #file,
														_ function  : String = #function,
														line        : Int 	 = #line,
														column      : Int 	 = #column,
														context     : Any? 	 = nil,
														isPrivate	 	: Bool 	 = false) {
		self.printLog(type    : .NOTICE,
									message : message(),
									file,
									function,
									line    : line,
									column  : column,
									context : context,
									isPrivate: isPrivate)
	}
	
	static public func error(_ message   : @autoclosure () -> Any,
													 _ file      : String = #file,
													 _ function  : String = #function,
													 line        : Int 		= #line,
													 column      : Int 		= #column,
													 context     : Any? 	= nil,
													 isPrivate	 : Bool 	= false) {
		self.printLog(type    : .ERROR,
									message : message(),
									file,
									function,
									line    : line,
									column  : column,
									context : context,
									isPrivate: isPrivate)
	}
	
	static public func fault(_ message   : @autoclosure () -> Any,
													 _ file      : String = #file,
													 _ function  : String = #function,
													 line        : Int 		= #line,
													 column      : Int 		= #column,
													 context     : Any? 	= nil,
													 isPrivate	 : Bool 	= false) {
		self.printLog(type    : .FAULT,
									message : message(),
									file,
									function,
									line    : line,
									column  : column,
									context : context,
									isPrivate: isPrivate)
	}
	
	
	private static func printLog(type: LogType,
															 message   : @autoclosure () -> Any,
															 _ file    : String,
															 _ function: String,
															 line      : Int,
															 column    : Int,
															 context   : Any? = nil,
															 isPrivate : Bool = false) {
		
		
		let logMessage = Formatter().composer(type		: type,
																					message	: message(),
																					file,
																					function,
																					line		: line,
																					column	: column,
																					context	: context,
																					formatters: formaters)
		
		#if DEBUG
		if #available(OSX 10.14, iOS 12.0, *) {
			var logType: OSLogType = .default
			
			switch type {
				case .INFO:
					logType = .info
				case .DEBUG:
					logType = .debug
				case .ERROR:
					logType = .error
				case .FAULT:
					logType = .fault
				case .VERBOSE, .WARNING, .NOTICE:
					break
			}
			
			os_log("%{public}@", log: OSLog(subsystem: "Logger",
																			category: "App\(type.rawValue.uppercased())"), type: logType, logMessage)
			
		} else {
			print(logMessage)
		}
		
		#else
		if !isPrivate {
			if #available(OSX 10.14, iOS 12.0, *) {
				var logType: OSLogType = .default
				
				switch type {
					case .INFO:
						logType = .info
					case .DEBUG:
						logType = .debug
					case .ERROR:
						logType = .error
					case .FAULT:
						logType = .fault
					case .VERBOSE, .WARNING, .NOTICE:
						break
				}
				
				os_log("%{public}@", log: OSLog(subsystem: "Logger",
																				category: "App\(type.rawValue.uppercased())"), type: logType, logMessage)
				
			} else {
				print(logMessage)
			}
		}
		#endif
	}
}

