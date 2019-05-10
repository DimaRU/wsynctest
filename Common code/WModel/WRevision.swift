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
public static let storedProperty: [PartialKeyPath<WRevision>:String] = [
        \WRevision.id :"id",
        \WRevision.revision :"revision",
        \WRevision.type :"type"
    ]

public static let mutableProperty: [PartialKeyPath<WRevision>:String] = [
    :
    ]
// sourcery:end
}
