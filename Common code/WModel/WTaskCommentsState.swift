////
///  WTaskCommentsState.swift
//

import Foundation

public struct WTaskCommentsState: WObject, TaskChild {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public var revision: Int
    public let type: MappingType = .TaskCommentsState

    public var taskId: Int
    public let unreadCount: Int
    public let lastReadId: Int?

// sourcery:inline:auto:WTaskCommentsState.property
public static let storedProperty: [PartialKeyPath<WTaskCommentsState>:String] = [
        \WTaskCommentsState.id :"id",
        \WTaskCommentsState.revision :"revision",
        \WTaskCommentsState.type :"type",
        \WTaskCommentsState.taskId :"task_id",
        \WTaskCommentsState.unreadCount :"unread_count",
        \WTaskCommentsState.lastReadId :"last_read_id"
    ]

public static let mutableProperty: [PartialKeyPath<WTaskCommentsState>:String] = [
    :
    ]
// sourcery:end
}
