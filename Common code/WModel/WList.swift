////
///  WList.swift
//

import Foundation

public struct WList: WObject, WCreatable {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .List
    public let createdByRequestId: String?

    public var title: String
    public let ownerId: Int?
    public let ownerType: String?
    public let listType: String?
    public let `public`: Bool?
    public let createdAt: Date?

    var isPublic: Bool? {
        return `public`
    }

// sourcery:inline:auto:WList.property
    public static let storedProperty: [String:PartialKeyPath<WList>] = [
        "id": \WList.id,
        "revision": \WList.revision,
        "type": \WList.type,
        "owner_id": \WList.ownerId,
        "owner_type": \WList.ownerType,
        "title": \WList.title,
        "list_type": \WList.listType,
        "public": \WList.`public`,
        "created_at": \WList.createdAt
    ]

    public static let mutableProperty: [String:PartialKeyPath<WList>] = [
        "title": \WList.title
    ]
// sourcery:end
}
