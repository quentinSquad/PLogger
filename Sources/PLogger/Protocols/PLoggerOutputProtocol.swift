//
//  PLoggerOutputProtocol.swift
//  Quentin Yann PIDOUX
//
//  Created by Quentin PIDOUX on 22/07/2020.
//  Copyright © 2020 Quentin PIDOUX. All rights reserved.
//

import Foundation

public protocol PLoggerOutputProtocol {
	func actionFor(log: String, type: PLogger.LogType, isPrivate: Bool)
}
