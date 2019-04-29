////
///  URLExtensions.swift
//

import Foundation

extension URL {
    func uri() -> String {
        let offset = absoluteString.range(of: path)!.lowerBound
        return String(absoluteString[offset...])
    }
}
