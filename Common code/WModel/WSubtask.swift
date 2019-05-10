////
///  WSubtask.swift
//

import Foundation

public struct WSubtask: WObject, TaskChild, WCreatable {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .Subtask
    public let createdByRequestId: String?

    public let taskId: Int
    public var title: String
    public var completed: Bool
    public let createdAt: Date?
    public let createdById: Int?

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
