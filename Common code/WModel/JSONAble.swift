////
///  JSONAble.swift
//

import Foundation

public protocol JSONAble: Codable {
    var id: Int { get }
    var type: MappingType { get }
}

public protocol Revisionable: JSONAble {
    var revision: Int { get }
}
