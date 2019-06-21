////
///  WSubtask.swift
//

import Foundation

public struct WSubtask: WObject, TaskChild, WCreatable {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public var revision: Int
    public let type: MappingType = .Subtask
    public let createdByRequestId: WRequestId?

    public var taskId: Int
    public var title: String
    public var completed: Bool
    public let createdAt: Date?
    public let createdById: Int?

    public static let createFieldList: [PartialKeyPath<WSubtask>] = [
        \WSubtask.taskId,
        \WSubtask.title
    ]

// sourcery:inline:auto:WSubtask.property
public static let storedProperty: [PartialKeyPath<WSubtask>:String] = [
        \WSubtask.id :"id",
        \WSubtask.revision :"revision",
        \WSubtask.type :"type",
        \WSubtask.createdByRequestId :"created_by_request_id",
        \WSubtask.taskId :"task_id",
        \WSubtask.title :"title",
        \WSubtask.completed :"completed",
        \WSubtask.createdAt :"created_at",
        \WSubtask.createdById :"created_by_id"
    ]

public static let mutableProperty: [PartialKeyPath<WSubtask>:String] = [
        \WSubtask.title :"title",
        \WSubtask.completed :"completed"
    ]
// sourcery:end
}
