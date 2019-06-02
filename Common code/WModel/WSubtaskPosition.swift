////
///  WSubtaskPosition.swift
//

import Foundation

public struct WSubtaskPosition: WObject, TaskChild {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public var revision: Int
    public let type: MappingType = .SubtaskPosition

    public var taskId: Int
    public var values: [Int]

// sourcery:inline:auto:WSubtaskPosition.property
public static let storedProperty: [PartialKeyPath<WSubtaskPosition>:String] = [
        \WSubtaskPosition.id :"id",
        \WSubtaskPosition.revision :"revision",
        \WSubtaskPosition.type :"type",
        \WSubtaskPosition.taskId :"task_id",
        \WSubtaskPosition.values :"values"
    ]

public static let mutableProperty: [PartialKeyPath<WSubtaskPosition>:String] = [
        \WSubtaskPosition.values :"values"
    ]
// sourcery:end
}
