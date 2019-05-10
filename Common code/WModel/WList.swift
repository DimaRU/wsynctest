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
public static let storedProperty: [PartialKeyPath<WList>:String] = [
        \WList.id :"id",
        \WList.revision :"revision",
        \WList.type :"type",
        \WList.createdByRequestId :"created_by_request_id",
        \WList.title :"title",
        \WList.ownerId :"owner_id",
        \WList.ownerType :"owner_type",
        \WList.listType :"list_type",
        \WList.`public` :"public",
        \WList.createdAt :"created_at"
    ]

public static let mutableProperty: [PartialKeyPath<WList>:String] = [
        \WList.title :"title"
    ]
// sourcery:end
}
