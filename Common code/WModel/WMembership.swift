////
///  WMembership.swift
//

import Foundation

public struct WMembership: WObject, ListChild {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public var revision: Int
    public let type: MappingType = .Membership
    public let createdByRequestId: WRequestId?

    public var listId: Int
    public let owner: Bool
    public var muted: Bool?
    public let state: String
    public let userId: Int

    public static let createFieldList: [PartialKeyPath<WMembership>] = [
        \WMembership.listId,
        \WMembership.userId,
        \WMembership.muted
    ]

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
        \WMembership.muted :"muted"
    ]
// sourcery:end
}
