////
///  WTaskCommentsState.swift
//

import Foundation

public struct WTaskCommentsState: WObject, TaskChild {
    public var uObjectState: ObjectState? = .localCreated
    public let id: Int
    public let revision: Int
    public let type: MappingType = .TaskCommentsState

    public let taskId: Int
    public let unreadCount: Int
    public let lastReadId: Int?

// sourcery:inline:auto:WTaskCommentsState.property
    public static let storedProperty: [String:PartialKeyPath<WTaskCommentsState>] = [
        "id": \WTaskCommentsState.id,
        "revision": \WTaskCommentsState.revision,
        "type": \WTaskCommentsState.type,
        "task_id": \WTaskCommentsState.taskId,
        "unread_count": \WTaskCommentsState.unreadCount,
        "last_read_id": \WTaskCommentsState.lastReadId
    ]

    public static let mutableProperty: [String:PartialKeyPath<WTaskCommentsState>] = [
    :
    ]
// sourcery:end
}
