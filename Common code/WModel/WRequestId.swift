////
///  WRequestId.swift
//

import Foundation

public struct WRequestId {
    var UUIDstring: String
}

extension WRequestId: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        let requestId = string.split(separator: ":").last
        UUIDstring = String(requestId ?? Substring(string))
    }
}

extension WRequestId: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(UUIDstring)
    }
}
