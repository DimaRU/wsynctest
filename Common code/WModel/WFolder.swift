////
///  WFolder.swift
//

import Foundation

public struct WFolder: WObject, WCreatable {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .Folder
    public let createdByRequestId: String?

    public var title: String
    public var listIds: [Int]
    public let userId: Int?
    public let createdAt: Date?
    public let createdById: Int?
    public let updatedAt: Date?

// sourcery:inline:auto:WFolder.property
    public static let storedProperty: [String:PartialKeyPath<WFolder>] = [
        "id": \WFolder.id,
        "revision": \WFolder.revision,
        "type": \WFolder.type,
        "created_by_request_id": \WFolder.createdByRequestId,
        "title": \WFolder.title,
        "list_ids": \WFolder.listIds,
        "user_id": \WFolder.userId,
        "created_at": \WFolder.createdAt,
        "created_by_id": \WFolder.createdById,
        "updated_at": \WFolder.updatedAt
    ]

    public static let mutableProperty: [String:PartialKeyPath<WFolder>] = [
        "title": \WFolder.title,
        "list_ids": \WFolder.listIds
    ]
// sourcery:end
}
