////
///  WFolder.swift
//

import Foundation

public struct WFolder: WObject, WCreatable {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public var revision: Int
    public let type: MappingType = .Folder
    public let createdByRequestId: String?

    public var title: String
    public var listIds: [Int]
    public let userId: Int?
    public let createdById: Int?
    public let createdAt: Date?
    public let updatedAt: Date?

    public static let createFieldList: [PartialKeyPath<WFolder>] = [
        \WFolder.title,
        \WFolder.listIds
    ]

// sourcery:inline:auto:WFolder.property
public static let storedProperty: [PartialKeyPath<WFolder>:String] = [
        \WFolder.id :"id",
        \WFolder.revision :"revision",
        \WFolder.type :"type",
        \WFolder.createdByRequestId :"created_by_request_id",
        \WFolder.title :"title",
        \WFolder.listIds :"list_ids",
        \WFolder.userId :"user_id",
        \WFolder.createdById :"created_by_id",
        \WFolder.createdAt :"created_at",
//        \WFolder.updatedAt :"updated_at"
    ]

public static let mutableProperty: [PartialKeyPath<WFolder>:String] = [
        \WFolder.title :"title",
        \WFolder.listIds :"list_ids"
    ]
// sourcery:end
}
