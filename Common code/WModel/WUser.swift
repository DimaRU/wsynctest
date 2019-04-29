////
///  WUser.swift
//

import Foundation

public struct WUser: WObject {
    public var uObjectState: ObjectState? = .localCreated
    public let id: Int
    public let revision: Int
    public let type: MappingType = .User

    public let name: String
    public let email: String
    public let createdAt: Date
    public let updatedAt: Date

// sourcery:inline:auto:WUser.property
    public static let storedProperty: [String:PartialKeyPath<WUser>] = [
        "id": \WUser.id,
        "revision": \WUser.revision,
        "type": \WUser.type,
        "name": \WUser.name,
        "email": \WUser.email,
        "created_at": \WUser.createdAt,
        "updated_at": \WUser.updatedAt
    ]

    public static let mutableProperty: [String:PartialKeyPath<WUser>] = [
    :
    ]
// sourcery:end
}
