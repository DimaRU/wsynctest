////
///  WFile.swift
//

import Foundation

public struct WFile: WObject, TaskChild {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .File
    public let createdByRequestId: String?

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
public static let storedProperty: [PartialKeyPath<WFile>:String] = [
        \WFile.id :"id",
        \WFile.revision :"revision",
        \WFile.type :"type",
        \WFile.createdByRequestId :"created_by_request_id",
        \WFile.taskId :"task_id",
        \WFile.userId :"user_id",
        \WFile.url :"url",
        \WFile.contentType :"content_type",
        \WFile.fileName :"file_name",
        \WFile.fileSize :"file_size",
        \WFile.fileIcon :"file_icon",
        \WFile.fileProvider :"file_provider",
        \WFile.localCreatedAt :"local_created_at",
        \WFile.createdAt :"created_at",
        \WFile.updatedAt :"updated_at"
    ]

public static let mutableProperty: [PartialKeyPath<WFile>:String] = [
    :
    ]
// sourcery:end
}
