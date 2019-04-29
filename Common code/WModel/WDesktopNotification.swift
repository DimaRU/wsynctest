////
///  WDesktopNotification.swift
//

import Foundation

struct WDesktopNotification: JSONAble {
    let id: Int
    let type: MappingType
    let event: String
    let senderId: Int
    let message: String
    let recipientId: Int
}
