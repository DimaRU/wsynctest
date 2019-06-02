////
///  WFeature.swift
//

import Foundation

public struct WFeature: WObject {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public var revision: Int
    public let type: MappingType = .Feature
    public let createdByRequestId: String?

    public let name: String
    public let variant: String

// sourcery:inline:auto:WFeature.property
public static let storedProperty: [PartialKeyPath<WFeature>:String] = [
        \WFeature.id :"id",
        \WFeature.revision :"revision",
        \WFeature.type :"type",
        \WFeature.createdByRequestId :"created_by_request_id",
        \WFeature.name :"name",
        \WFeature.variant :"variant"
    ]

public static let mutableProperty: [PartialKeyPath<WFeature>:String] = [
    :
    ]
// sourcery:end
}
