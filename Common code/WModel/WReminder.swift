////
///  WReminder.swift
//

import Foundation

public struct WReminder: WObject, WCreatable {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public var revision: Int
    public let type: MappingType = .Reminder
    public let createdByRequestId: String?

    public var taskId: Int
    public var date: Date
    public let createdAt: Date?
    public let updatedAt: Date?

    public static let createFieldList: [PartialKeyPath<WReminder>] = [
        \WReminder.taskId,
        \WReminder.date
    ]

// sourcery:inline:auto:WReminder.property
public static let storedProperty: [PartialKeyPath<WReminder>:String] = [
        \WReminder.id :"id",
        \WReminder.revision :"revision",
        \WReminder.type :"type",
        \WReminder.createdByRequestId :"created_by_request_id",
        \WReminder.taskId :"task_id",
        \WReminder.date :"date",
        \WReminder.createdAt :"created_at",
//        \WReminder.updatedAt :"updated_at"
    ]

public static let mutableProperty: [PartialKeyPath<WReminder>:String] = [
        \WReminder.date :"date"
    ]
// sourcery:end
}
