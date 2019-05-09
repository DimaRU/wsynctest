////
///  WTask.swift
//

import Foundation

public struct WTask: WObject, ListChild {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .Task

    public var title: String
    public var completed: Bool
    public var starred: Bool
    public var listId: Int
    public var recurrenceType: String?
    public var recurrenceCount: Int?
    public var assigneeId: Int?
    public var assignerId: Int?
    public var dueDate: String?
    public let completedAt: Date?
    public let completedById: Int?
    public let createdAt: Date
    public let createdById: Int?

// sourcery:inline:auto:WTask.property
    public static let storedProperty: [String:PartialKeyPath<WTask>] = [
        "id": \WTask.id,
        "revision": \WTask.revision,
        "type": \WTask.type,
        "list_id": \WTask.listId,
        "title": \WTask.title,
        "recurrence_type": \WTask.recurrenceType,
        "recurrence_count": \WTask.recurrenceCount,
        "due_date": \WTask.dueDate,
        "starred": \WTask.starred,
        "completed": \WTask.completed,
        "assignee_id": \WTask.assigneeId,
        "assigner_id": \WTask.assignerId,
        "completed_at": \WTask.completedAt,
        "completed_by_id": \WTask.completedById,
        "created_at": \WTask.createdAt,
        "created_by_id": \WTask.createdById
    ]

    public static let mutableProperty: [String:PartialKeyPath<WTask>] = [
        "list_id": \WTask.listId,
        "title": \WTask.title,
        "recurrence_type": \WTask.recurrenceType,
        "recurrence_count": \WTask.recurrenceCount,
        "due_date": \WTask.dueDate,
        "starred": \WTask.starred,
        "completed": \WTask.completed
    ]
// sourcery:end
}
