////
///  WTaskPositions.swift
//

import Foundation

public struct WTaskPosition: WObject, ListChild {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .TaskPosition

    public let listId: Int
    public var values: [Int]

// sourcery:inline:auto:WTaskPosition.property
public static let storedProperty: [PartialKeyPath<WTaskPosition>:String] = [
        \WTaskPosition.id :"id",
        \WTaskPosition.revision :"revision",
        \WTaskPosition.type :"type",
        \WTaskPosition.listId :"list_id",
        \WTaskPosition.values :"values"
    ]

public static let mutableProperty: [PartialKeyPath<WTaskPosition>:String] = [
        \WTaskPosition.values :"values"
    ]
// sourcery:end
}
