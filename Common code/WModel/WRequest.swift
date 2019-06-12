////
///  WRequest.swift
//

import Foundation

struct WParams: Codable {
    var container: [String: Any]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)
        self.container = try container.decode([String: Any].self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        try container.encode(self.container)
    }

    init(_ dict: [String: Any]) {
        container = dict
    }
}

struct WRequest: Codable {
    enum RequestType: String, Codable {
        case create, update, delete
    }
    let requestType: RequestType
    var id: Int
    var parentId: Int?
    let uuid: String = UUID().uuidString.lowercased()
    var type: MappingType
    var params: WParams
}

extension WRequest {
    private init<T: WObject>(_ requestType: WRequest.RequestType, wobject: T, params: [String: Any]) {
        self.requestType = requestType
        self.id = wobject.id
        self.params = WParams(params)
        self.type = wobject.type
        switch wobject {
        case let wobject as ListChild:
            parentId = wobject.listId
        case let wobject as TaskChild:
            parentId = wobject.taskId
        default:
            parentId = nil
        }
    }

    static func create<T: WObject & WCreatable>(wobject: T) -> WRequest {
        return WRequest(.create, wobject: wobject, params: [:])
    }

    static func delete<T: WObject>(wobject: T) -> WRequest {
        return WRequest(.delete, wobject: wobject, params: [:])
    }

    static func update<T: WObject>(wobject: T, updated: T) -> WRequest {
        let params = wobject.updatableParams()
        return WRequest(.update, wobject: wobject, params: params)
    }
}
