////
///  WFolder.swift
//

import Foundation

public struct WFolder: WObject {
    public var uObjectState: ObjectState? = .localCreated
    public let id: Int
    public let revision: Int
    public let type: MappingType = .Folder

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
        "user_id": \WFolder.userId,
        "title": \WFolder.title,
        "list_ids": \WFolder.listIds,
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
