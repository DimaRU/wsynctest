////
///  WTaskPositions.swift
//

import Foundation

public struct WTaskPosition: WObject, ListChild {
    public var uObjectState: ObjectState? = .localCreated
    public let id: Int
    public let revision: Int
    public let type: MappingType = .TaskPosition

    public let listId: Int
    public var values: [Int]

// sourcery:inline:auto:WTaskPosition.property
    public static let storedProperty: [String:PartialKeyPath<WTaskPosition>] = [
        "id": \WTaskPosition.id,
        "revision": \WTaskPosition.revision,
        "type": \WTaskPosition.type,
        "list_id": \WTaskPosition.listId,
        "values": \WTaskPosition.values
    ]

    public static let mutableProperty: [String:PartialKeyPath<WTaskPosition>] = [
        "values": \WTaskPosition.values
    ]
// sourcery:end
}
