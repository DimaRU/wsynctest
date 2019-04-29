////
///  WFile.swift
//

import Foundation

public struct WFile: WObject, TaskChild {
    public var uObjectState: ObjectState? = .localCreated
    public let id: Int
    public let revision: Int
    public let type: MappingType = .File

    public let taskId: Int
    public let userId: Int
    public let url: URL
    public let contentType: String
    public let fileName: String
    public let fileSize: Int
    public let fileIcon: String?
    public let fileProvider: String?
    public let localCreatedAt: Date?
    public let createdAt: Date
    public let updatedAt: Date

// sourcery:inline:auto:WFile.property
    public static let storedProperty: [String:PartialKeyPath<WFile>] = [
        "id": \WFile.id,
        "revision": \WFile.revision,
        "type": \WFile.type,
        "task_id": \WFile.taskId,
        "user_id": \WFile.userId,
        "url": \WFile.url,
        "content_type": \WFile.contentType,
        "file_name": \WFile.fileName,
        "file_size": \WFile.fileSize,
        "file_icon": \WFile.fileIcon,
        "file_provider": \WFile.fileProvider,
        "local_created_at": \WFile.localCreatedAt,
        "created_at": \WFile.createdAt,
        "updated_at": \WFile.updatedAt
    ]

    public static let mutableProperty: [String:PartialKeyPath<WFile>] = [
    :
    ]
// sourcery:end
}
