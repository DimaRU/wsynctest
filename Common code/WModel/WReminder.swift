////
///  WReminder.swift
//

import Foundation

public struct WReminder: WObject {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .Reminder

    public let taskId: Int
    public let date: Date
    public let createdAt: Date?
    public let updatedAt: Date?

// sourcery:inline:auto:WReminder.property
    public static let storedProperty: [String:PartialKeyPath<WReminder>] = [
        "id": \WReminder.id,
        "revision": \WReminder.revision,
        "type": \WReminder.type,
        "task_id": \WReminder.taskId,
        "date": \WReminder.date,
        "created_at": \WReminder.createdAt,
        "updated_at": \WReminder.updatedAt
    ]

    public static let mutableProperty: [String:PartialKeyPath<WReminder>] = [
    :
    ]
// sourcery:end
}
