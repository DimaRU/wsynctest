////
///  WUpload.swift
//

import Foundation

public struct WUpload: JSONAble {
    public let id: Int
    public let type: MappingType
    public let userId: Int
    public let state: String
    public let expiresAt: Date?
    public struct Part: Codable {
        public let url: URL
        public let date: String
        public let authorization: String
    }
    public let part: Part?
}
