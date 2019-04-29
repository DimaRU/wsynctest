////
///  WUnreadActivityCount.swift
//

import Foundation

public struct WUnreadActivityCount: JSONAble {
    public let id: Int
    public let type: MappingType

    public let activities: Int
    public let conversations: Int
}
