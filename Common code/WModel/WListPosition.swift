////
///  WListPosition.swift
//

import Foundation

public struct WListPosition: WObject {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .ListPosition

    public let userId: Int
    public var values: [Int]

// sourcery:inline:auto:WListPosition.property
public static let storedProperty: [PartialKeyPath<WListPosition>:String] = [
        \WListPosition.id :"id",
        \WListPosition.revision :"revision",
        \WListPosition.type :"type",
        \WListPosition.userId :"user_id",
        \WListPosition.values :"values"
    ]

public static let mutableProperty: [PartialKeyPath<WListPosition>:String] = [
        \WListPosition.values :"values"
    ]
// sourcery:end
}
