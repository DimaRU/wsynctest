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
    public var taskId: Int
    public let localCreatedAt: Date?
    public let author: WAuthor
    public let createdAt: Date?

    public struct WAuthor: Codable, Equatable {
        public let id: Int
        public let name: String
        public let avatar: URL?
    }

    public static let createFieldList: [PartialKeyPath<WTaskComment>] = [
        \WTaskComment.taskId,
        \WTaskComment.text,
        \WTaskComment.localCreatedAt
    ]

// sourcery:inline:auto:WTaskComment.property
public static let storedProperty: [PartialKeyPath<WTaskComment>:String] = [
        \WTaskComment.id :"id",
        \WTaskComment.revision :"revision",
        \WTaskComment.type :"type",
        \WTaskComment.createdByRequestId :"created_by_request_id",
        \WTaskComment.text :"text",
        \WTaskComment.taskId :"task_id",
        \WTaskComment.localCreatedAt :"local_created_at",
        \WTaskComment.author :"author",
        \WTaskComment.createdAt :"created_at"
    ]

public static let mutableProperty: [PartialKeyPath<WTaskComment>:String] = [
        \WTaskComment.text :"text"
    ]
// sourcery:end
}
