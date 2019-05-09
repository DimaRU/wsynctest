////
///  WRevision.swift
//

import Foundation

public struct WRevision: WObject {
    public var storedSyncState: WSyncState?
    public let id: Int
    public let revision: Int
    public let type: MappingType
    
    public static let storedProperty: [String : PartialKeyPath<WRevision>] = [:]
    public static let mutableProperty: [String : PartialKeyPath<WRevision>] = [:]
}
