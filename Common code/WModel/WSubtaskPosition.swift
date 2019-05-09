////
///  WSubtaskPosition.swift
//

import Foundation

public struct WSubtaskPosition: WObject, TaskChild {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .SubtaskPosition

    public let taskId: Int
    public var values: [Int]

// sourcery:inline:auto:WSubtaskPosition.property
    public static let storedProperty: [String:PartialKeyPath<WSubtaskPosition>] = [
        "id": \WSubtaskPosition.id,
        "revision": \WSubtaskPosition.revision,
        "type": \WSubtaskPosition.type,
        "task_id": \WSubtaskPosition.taskId,
        "values": \WSubtaskPosition.values
    ]

    public static let mutableProperty: [String:PartialKeyPath<WSubtaskPosition>] = [
        "values": \WSubtaskPosition.values
    ]
// sourcery:end
}
