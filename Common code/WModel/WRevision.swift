////
///  WRevision.swift
//

import Foundation

public struct WRevision: WObject {
    public var storedSyncState: WSyncState?
    public let id: Int
    public let revision: Int
    public let type: MappingType
    
// sourcery:inline:auto:WRevision.property
    public static let storedProperty: [String:PartialKeyPath<WRevision>] = [
        "id": \WRevision.id,
        "revision": \WRevision.revision,
        "type": \WRevision.type
    ]

    public static let mutableProperty: [String:PartialKeyPath<WRevision>] = [
    :
    ]
// sourcery:end
}
