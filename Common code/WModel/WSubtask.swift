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
    public static let storedProperty: [String:PartialKeyPath<WSubtask>] = [
        "id": \WSubtask.id,
        "revision": \WSubtask.revision,
        "type": \WSubtask.type,
        "created_by_request_id": \WSubtask.createdByRequestId,
        "task_id": \WSubtask.taskId,
        "title": \WSubtask.title,
        "completed": \WSubtask.completed,
        "created_at": \WSubtask.createdAt,
        "created_by_id": \WSubtask.createdById
    ]

    public static let mutableProperty: [String:PartialKeyPath<WSubtask>] = [
        "title": \WSubtask.title,
        "completed": \WSubtask.completed
    ]
// sourcery:end
}
