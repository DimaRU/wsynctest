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
public static let storedProperty: [PartialKeyPath<WRoot>:String] = [
        \WRoot.id :"id",
        \WRoot.revision :"revision",
        \WRoot.type :"type",
        \WRoot.userId :"user_id"
    ]

public static let mutableProperty: [PartialKeyPath<WRoot>:String] = [
    :
    ]
// sourcery:end
}
