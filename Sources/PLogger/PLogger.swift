//
//  Plogger.swift
//  Quentin Yann PIDOUX
//
//  Created by Quentin PIDOUX on 09/10/2019.
//  Copyright © 2019 Fitnext. All rights reserved.
//

import Foundation
import os.log
#if canImport(Alamofire)
import Alamofire
#endif

//let log = PLogger.self

public class PLogger {
  private enum LogType {
    case INFO
    case DEBUG
    case VERBOSE
    case WARNING
    case ERROR
  }
  
	static public func info(_ message   : @autoclosure () -> Any,
                  _ file      : String = #file,
                  _ function  : String = #function,
                  line        : Int = #line,
                  column      : Int = #column,
                  context     : Any? = nil) {
    
    self.printLog(type: .INFO, message: message(), file, function, line: line, column: column, context: context)
  }
  
  static public func debug(_ message   : @autoclosure () -> Any,
                   _ file      : String = #file,
                   _ function  : String = #function,
                   line        : Int = #line,
                   column      : Int = #column,
                   context     : Any? = nil) {
    self.printLog(type    : .DEBUG,
                      message : message(),
                      file,
                      function,
                      line    : line,
                      column  : column,
                      context : context)
  }
  
  static public func verbose(_ message   : @autoclosure () -> Any,
                     _ file      : String = #file,
                     _ function  : String = #function,
                     line        : Int = #line,
                     column      : Int = #column,
                     context     : Any? = nil) {
    self.printLog(type    : .VERBOSE,
                      message : message(),
                      file,
                      function,
                      line    : line,
                      column  : column,
                      context : context)
  }
  
  static public func warning(_ message   : @autoclosure () -> Any,
                     _ file      : String = #file,
                     _ function  : String = #function,
                     line        : Int = #line,
                     column      : Int = #column,
                     context     : Any? = nil) {
    self.printLog(type    : .WARNING,
                      message : message(),
                      file,
                      function,
                      line    : line,
                      column  : column,
                      context : context)
  }
  
   static public func error(_ message   : @autoclosure () -> Any,
                    _ file      : String = #file,
                    _ function  : String = #function,
                    line        : Int = #line,
                    column      : Int = #column,
                    context     : Any? = nil) {
    self.printLog(type    : .ERROR,
                      message : message(),
                      file,
                      function,
                      line    : line,
                      column  : column,
                      context : context)
  }
  
  private static func printDate(to message: String) -> String {
    let string = "|\t- Date     : \(Date())\n"
    return "\(message)\(string)"
  }
  
  private static func printStatus(to message: String, type: LogType) -> String {
    var string = "|\t- Status   : "
    switch type {
    case .INFO:
      string += "💙 Info\n"
    case .DEBUG:
      string += "💜 Debug\n"
    case .VERBOSE:
      string += "💚 Verbose\n"
    case .WARNING:
      string += "🧡 Warning\n"
    case .ERROR:
      string += "❤️ Error\n"
    }
    return "\(message)\(string)"
  }
  
  private static func printThread(to message: String) -> String {
    var string = "|\t- Thread   :\n"
    
    string += "|\t\t+ Stack size  : \(Thread.current.stackSize)\n"
    string += "|\t\t+ Priority    : \(Thread.current.threadPriority)\n"
    
    if let name = OperationQueue.current?.underlyingQueue?.label {
      string += "|\t\t+ Name        : \(name)\n"
    }
    
    if Thread.current.isCancelled {
      string += "|\t\t+ Cancelled   : true\n"
    }
    if Thread.current.isExecuting {
      string += "|\t\t+ Executing   : true\n"
    }
    if Thread.current.isFinished {
      string += "|\t\t+ Finished    : true\n"
    }
    if Thread.current.isMainThread {
      string += "|\t\t+ Main Thread : true\n"
    }
    
    return "\(message)\(string)"
  }
  
  private static func printFileDescription(to message: String,
                                          _ file    : String,
                                          _ function: String,
                                          line      : Int,
                                          column    : Int) -> String {
    var string = "|\t- File     :\n"
    if let file = file.components(separatedBy: "/").last {
      string += "|\t\t+ Name     : \(file)\n"
    }

    string += "|\t\t+ Function : \(function)\n"
    string += "|\t\t+ Line     : \(line)\n"
    string += "|\t\t+ Column   : \(column)\n"
    
    return "\(message)\(string)"
  }
  
  private static func printMessage(to dest   : String,
                                  message   : @autoclosure () -> Any,
                                  context   : Any? = nil,
                                  type      : LogType) -> String {
    var string = "|\t- Log      :\n"
    
    switch type {
    case .INFO, .DEBUG, .VERBOSE, .WARNING:
      string += "|\t\t+ Message  : "

      if let message = message() as? String {
        string += "\(message)\n"
      } else {
        string += "\(message())\n"
      }
    case .ERROR:
      string += "|\t\t+ Error    : \n"
      var errorPrinted = false
      
      if let error = message() as? Error {
        string += "|\t\t\t+ Localized : \(error.localizedDescription)\n"
        string += "|\t\t\t+ error     : \(error)\n"
        errorPrinted = true
      }
      #if canImport(Alamofire)
      if let error = message() as? AFError {
        string += "|\t\t\t+ Alamofire :\n"
        
        if let value = error.recoverySuggestion {
          string += "|\t\t\t\t- Recovery suggestion       : \(value)\n"
        }
        if error.isInvalidURLError {
          string += "|\t\t\t\t- Is Invalid URL            : true\n"
        }
        if error.isMultipartEncodingError {
          string += "|\t\t\t\t- Is multipart encoding     : true\n"
        }
        if error.isParameterEncodingError {
          string += "|\t\t\t\t- Is parameter encoding     : true\n"
        }
        if error.isResponseValidationError {
          string += "|\t\t\t\t- Is response validation    : true\n"
        }
        if error.isResponseSerializationError {
          string += "|\t\t\t\t- Is response serialization : true\n"
        }
        
        if let value = error.responseCode {
          string += "|\t\t\t\t- Response code             : \(value)\n"
        }
        if let value = error.failureReason {
          string += "|\t\t\t\t- Failure reason            : \(value)\n"
        }
        if let value = error.url {
          string += "|\t\t\t\t- Url                       : \(value)\n"
        }
        
        string += "|\t\t\t+ error     : \(error)\n"
        errorPrinted = true
      }
      #endif
      if errorPrinted == false {
        string += "|\t\(message())\n"
      }
    }
    
    if let context = context {
      string += "|\t\t+ Context  : \(context)\n"
    }
    
    return "\(dest)\(string)"
  }
  
	private static func printLog(type: LogType,
															 message   : @autoclosure () -> Any,
															 _ file    : String,
															 _ function: String,
															 line      : Int,
															 column    : Int,
															 context   : Any? = nil) {
		
		
		var string = "┌--- logger\n"
		
		string = self.printDate(to: string)
		string = self.printStatus(to: string, type: type)
		
		switch type {
			case .INFO: break
			case .DEBUG:
				string = self.printFileDescription(to: string, file, function, line: line, column: column)
			case .VERBOSE, .WARNING, .ERROR:
				string = self.printThread(to: string)
				string = self.printFileDescription(to: string, file, function, line: line, column: column)
		}
		
		string = self.printMessage(to: string, message: message(), context: context, type: type)
		string += "└-------\n"
		
		#if DEBUG
		if #available(OSX 10.14, iOS 12.0, *) {
			var logType: OSLogType = .default
			var catType = ""

			switch type {
				case .INFO:
					logType = .info
					catType = "Info"
					break
				case .DEBUG:
					logType = .debug
					catType = "Debug"
				case .ERROR:
					logType = .error
					catType = "Error"
				case .VERBOSE:
					catType = "Verbose"
				case .WARNING:
					catType = "Warning"
			}
			
			os_log("%@", log: OSLog(subsystem: "Logger", category: "App\(catType)"), type: logType, string)
		} else {
			print(string)
		}
		#else
		if #available(OSX 10.14, iOS 12.0, *) {
			if type == .ERROR {
				let logType: OSLogType = .error
				let catType = "Error"
			}
			os_log("%@", log: OSLog(subsystem: "Logger", category: "App\(catType)"), type: logType, string)
			var catType = ""
		} else if type == .ERROR {
			print(string)
		}
		#endif
	}
}

