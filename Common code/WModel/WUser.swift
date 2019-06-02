////
///  WUser.swift
//

import Foundation

public struct WUser: WObject {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public var revision: Int
    public let type: MappingType = .User

    public let name: String
    public let email: String
    public let createdAt: Date
    public let updatedAt: Date

// sourcery:inline:auto:WUser.property
public static let storedProperty: [PartialKeyPath<WUser>:String] = [
        \WUser.id :"id",
        \WUser.revision :"revision",
        \WUser.type :"type",
        \WUser.name :"name",
        \WUser.email :"email",
        \WUser.createdAt :"created_at",
        \WUser.updatedAt :"updated_at"
    ]

public static let mutableProperty: [PartialKeyPath<WUser>:String] = [
    :
    ]
// sourcery:end
}
