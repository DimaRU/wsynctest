////
///  WTaskComment.swift
//

import Foundation

public struct WTaskComment: WObject, TaskChild {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .TaskComment

    public var text: String
    public let taskId: Int
    public let localCreatedAt: Date?
    public let author: WAuthor
    public let createdAt: Date?

    public struct WAuthor: Codable, Equatable {
        public let id: Int
        public let name: String
        public let avatar: URL?
    }

// sourcery:inline:auto:WTaskComment.property
    public static let storedProperty: [String:PartialKeyPath<WTaskComment>] = [
        "id": \WTaskComment.id,
        "revision": \WTaskComment.revision,
        "type": \WTaskComment.type,
        "task_id": \WTaskComment.taskId,
        "local_created_at": \WTaskComment.localCreatedAt,
        "created_at": \WTaskComment.createdAt,
        "author": \WTaskComment.author,
        "text": \WTaskComment.text
    ]

    public static let mutableProperty: [String:PartialKeyPath<WTaskComment>] = [
        "text": \WTaskComment.text
    ]
// sourcery:end
}
