////
///  WMembership.swift
//

import Foundation

public struct WMembership: WObject, ListChild, WCreatable {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .Membership
    public let createdByRequestId: String?

    public let listId: Int
    public let owner: Bool
    public let muted: Bool?
    public let state: String
    public let userId: Int

// sourcery:inline:auto:WMembership.property
public static let storedProperty: [PartialKeyPath<WMembership>:String] = [
        \WMembership.id :"id",
        \WMembership.revision :"revision",
        \WMembership.type :"type",
        \WMembership.createdByRequestId :"created_by_request_id",
        \WMembership.listId :"list_id",
        \WMembership.owner :"owner",
        \WMembership.muted :"muted",
        \WMembership.state :"state",
        \WMembership.userId :"user_id"
    ]

public static let mutableProperty: [PartialKeyPath<WMembership>:String] = [
    :
    ]
// sourcery:end
}
