////
///  WTaskComment.swift
//

import Foundation

public struct WTaskComment: WObject, TaskChild, WCreatable {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .TaskComment
    public let createdByRequestId: String?

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
        "created_by_request_id": \WTaskComment.createdByRequestId,
        "text": \WTaskComment.text,
        "task_id": \WTaskComment.taskId,
        "local_created_at": \WTaskComment.localCreatedAt,
        "author": \WTaskComment.author,
        "created_at": \WTaskComment.createdAt
    ]

    public static let mutableProperty: [String:PartialKeyPath<WTaskComment>] = [
        "text": \WTaskComment.text
    ]
// sourcery:end
}
