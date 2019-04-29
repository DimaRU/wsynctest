////
///  WFeature.swift
//

import Foundation

public struct WFeature: WObject {
    public var uObjectState: ObjectState? = .localCreated
    public let id: Int
    public let revision: Int
    public let type: MappingType = .Feature

    public let name: String
    public let variant: String

// sourcery:inline:auto:WFeature.property
    public static let storedProperty: [String:PartialKeyPath<WFeature>] = [
        "id": \WFeature.id,
        "revision": \WFeature.revision,
        "type": \WFeature.type,
        "name": \WFeature.name,
        "variant": \WFeature.variant
    ]

    public static let mutableProperty: [String:PartialKeyPath<WFeature>] = [
    :
    ]
// sourcery:end
}
