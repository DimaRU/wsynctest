////
///  WNote.swift
//

import Foundation

public struct WNote: WObject, TaskChild {
    public var uObjectState: ObjectState? = .localCreated
    public let id: Int
    public let revision: Int
    public let type: MappingType = .Note

    public let taskId: Int
    public var content: String

// sourcery:inline:auto:WNote.property
    public static let storedProperty: [String:PartialKeyPath<WNote>] = [
        "id": \WNote.id,
        "revision": \WNote.revision,
        "type": \WNote.type,
        "task_id": \WNote.taskId,
        "content": \WNote.content
    ]

    public static let mutableProperty: [String:PartialKeyPath<WNote>] = [
        "content": \WNote.content
    ]
// sourcery:end
}
