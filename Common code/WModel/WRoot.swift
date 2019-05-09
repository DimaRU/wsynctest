////
///  WRoot.swift
//

import Foundation

public struct WRoot: WObject {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public let revision: Int
    public let type: MappingType = .Root

    public let userId: Int
    
    public init(id: Int, revision: Int) {
        self.id = id
        self.revision = revision
        userId = 0
    }

// sourcery:inline:auto:WRoot.property
    public static let storedProperty: [String:PartialKeyPath<WRoot>] = [
        "id": \WRoot.id,
        "revision": \WRoot.revision,
        "type": \WRoot.type,
        "user_id": \WRoot.userId
    ]

    public static let mutableProperty: [String:PartialKeyPath<WRoot>] = [
    :
    ]
// sourcery:end
}
