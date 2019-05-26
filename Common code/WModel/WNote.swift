////
///  WNote.swift
//

import Foundation

public struct WNote: WObject, TaskChild, WCreatable {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .Note
    public let createdByRequestId: String?

    public var taskId: Int
    public var content: String

    public static let createFieldList: [PartialKeyPath<WNote>] = [
        \WNote.taskId,
        \WNote.content
    ]

// sourcery:inline:auto:WNote.property
public static let storedProperty: [PartialKeyPath<WNote>:String] = [
        \WNote.id :"id",
        \WNote.revision :"revision",
        \WNote.type :"type",
        \WNote.createdByRequestId :"created_by_request_id",
        \WNote.taskId :"task_id",
        \WNote.content :"content"
    ]

public static let mutableProperty: [PartialKeyPath<WNote>:String] = [
        \WNote.content :"content"
    ]
// sourcery:end
}
