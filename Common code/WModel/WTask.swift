////
///  WTask.swift
//

import Foundation

public struct WTask: WObject, ListChild, WCreatable {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public var revision: Int
    public let type: MappingType = .Task
    public let createdByRequestId: WRequestId?

    public var title: String
    public var completed: Bool
    public var starred: Bool
    public var listId: Int
    public var recurrenceType: String?
    public var recurrenceCount: Int?
    public var assigneeId: Int?
    public let assignerId: Int?
    public var dueDate: String?
    public let completedAt: Date?
    public let completedById: Int?
    public let createdAt: Date
    public let createdById: Int?

    public static let createFieldList: [PartialKeyPath<WTask>] = [
        \WTask.listId,
        \WTask.title,
        \WTask.starred
    ]

// sourcery:inline:auto:WTask.property
public static let storedProperty: [PartialKeyPath<WTask>:String] = [
        \WTask.id :"id",
        \WTask.revision :"revision",
        \WTask.type :"type",
        \WTask.createdByRequestId :"created_by_request_id",
        \WTask.title :"title",
        \WTask.completed :"completed",
        \WTask.starred :"starred",
        \WTask.listId :"list_id",
        \WTask.recurrenceType :"recurrence_type",
        \WTask.recurrenceCount :"recurrence_count",
        \WTask.assigneeId :"assignee_id",
        \WTask.dueDate :"due_date",
        \WTask.completedAt :"completed_at",
        \WTask.completedById :"completed_by_id",
        \WTask.createdAt :"created_at",
        \WTask.createdById :"created_by_id"
    ]

public static let mutableProperty: [PartialKeyPath<WTask>:String] = [
        \WTask.title :"title",
        \WTask.completed :"completed",
        \WTask.starred :"starred",
        \WTask.listId :"list_id",
        \WTask.recurrenceType :"recurrence_type",
        \WTask.recurrenceCount :"recurrence_count",
        \WTask.assigneeId :"assignee_id",
        \WTask.assignerId :"assigner_id",
        \WTask.dueDate :"due_date"
    ]
// sourcery:end
}
