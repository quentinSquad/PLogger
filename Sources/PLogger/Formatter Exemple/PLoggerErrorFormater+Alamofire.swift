//
//  PLoggerErrorFormater+Alamofire.swift
//  Quentin Yann PIDOUX
//
//  Created by Quentin PIDOUX on 21/07/2020.
//  Copyright © 2020 Quentin PIDOUX. All rights reserved.
//

import Foundation
#if canImport(Alamofire)
import Alamofire

open class AlamofireFormatter: PLoggerErrorFormater {
	public func getErrorType() -> Any.Type {
		AFError.self
	}

	public func getErrorName() -> String {
		"Alamofire"
	}

	public func getErrorMessages(_ error: Error) -> [String: Any] {
		guard ((error as? AFError) != nil) else {
			return [:]
		}
		let error = error as! AFError
		var result: [String: Any] = [:]

		if let value = error.recoverySuggestion { result["Recovery suggestion"] = value }
		if error.isInvalidURLError == true { result["Is Invalid URL"] = true }
		if error.isMultipartEncodingError == true { result["Is multipart encoding"] = true }
		if error.isParameterEncodingError == true { result["Is parameter encoding"] = true }
		if error.isResponseValidationError == true { result["Is response validation"] = true }
		if error.isResponseSerializationError == true { result["Is response serialization"] = true }
		if let value = error.responseCode { result["Response code"] = value }
		if let value = error.failureReason { result["Failure reason"] = value }
		if let value = error.url { result["Url"] = value }

		return result
	}
}

#endif
