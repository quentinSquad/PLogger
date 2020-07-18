//
//  PLoggerErrorFormater.swift
//  Quentin Yann PIDOUX
//
//  Created by Quentin PIDOUX on 17/07/2020.
//  Copyright © 2020 Quentin PIDOUX. All rights reserved.
//

import Foundation


public protocol PLoggerErrorFormater {
	func getErrorType() -> Any.Type
	func getErrorName() -> String
	func getErrorMessages(_ error: Error) -> [(String, Any)]
}
