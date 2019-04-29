////
///  JSONAble.swift
//

import Foundation

public protocol JSONAble: Codable {
    var id: Int { get }
    var type: MappingType { get }
}
