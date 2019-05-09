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
    public static let storedProperty: [String:PartialKeyPath<WListPosition>] = [
        "id": \WListPosition.id,
        "revision": \WListPosition.revision,
        "type": \WListPosition.type,
        "user_id": \WListPosition.userId,
        "values": \WListPosition.values
    ]

    public static let mutableProperty: [String:PartialKeyPath<WListPosition>] = [
        "values": \WListPosition.values
    ]
// sourcery:end
}
