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
    public static let storedProperty: [String:PartialKeyPath<WMembership>] = [
        "id": \WMembership.id,
        "revision": \WMembership.revision,
        "type": \WMembership.type,
        "list_id": \WMembership.listId,
        "owner": \WMembership.owner,
        "muted": \WMembership.muted,
        "state": \WMembership.state,
        "user_id": \WMembership.userId
    ]

    public static let mutableProperty: [String:PartialKeyPath<WMembership>] = [
    :
    ]
// sourcery:end
}
