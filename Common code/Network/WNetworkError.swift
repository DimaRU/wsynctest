////
///  WNetworkError.swift
//

import Foundation

enum WNetworkError: Error {
    case unauthorized
    case notFound
    case conflict
    case replyError(code: Int, message: WNetworkErrorMessage)
    case serverError(code: Int, data: String?)
    case networkError(underlying: Error)
    case replyDataError(underlying: Error)
    case upload(code: Int)
}
