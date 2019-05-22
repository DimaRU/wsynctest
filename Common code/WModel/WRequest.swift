////
///  WRequest.swift
//


import Foundation

public enum WRequest {
    case create(object: Revisionable)
    case delete(object: Revisionable)
    case modify(object: Revisionable, modified: Revisionable)

    enum CodingKeys: String, CodingKey {
        case create
        case delete
        case modify
        case object
        case modified
        case type
    }
}

extension WRequest: Codable {
    public func encode(to encoder: Encoder) throws {
        var containerTop = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .create(let object):
            var container = containerTop.nestedContainer(keyedBy: CodingKeys.self, forKey: .create)
            try container.encodeJSONAble(object as AnyObject, forKey: .object)
        case .delete(let object):
            var container = containerTop.nestedContainer(keyedBy: CodingKeys.self, forKey: .delete)
            try container.encodeJSONAble(object as AnyObject, forKey: .object)
        case .modify(let object, let modified):
            var container = containerTop.nestedContainer(keyedBy: CodingKeys.self, forKey: .modify)
            try container.encodeJSONAble(object as AnyObject, forKey: .object)
            try container.encodeJSONAble(modified as AnyObject, forKey: .modified)
        }
    }

    public init(from decoder: Decoder) throws {
        let topContainer = try decoder.container(keyedBy: CodingKeys.self)
        if let container = try? topContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .create) {
            let object = try container.decodeWobject(keyedBy: CodingKeys.self, forKey: .object, typeKey: .type)
            self = WRequest.create(object: object)
        } else if let container = try? topContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .delete) {
            let object = try container.decodeWobject(keyedBy: CodingKeys.self, forKey: .object, typeKey: .type)
            self = WRequest.delete(object: object)
        } else if let container = try? topContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .modify) {
            let object = try container.decodeWobject(keyedBy: CodingKeys.self, forKey: .object, typeKey: .type)
            let modified = try container.decodeWobject(keyedBy: CodingKeys.self, forKey: .modified, typeKey: .type)
            self = WRequest.modify(object: object, modified: modified)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: topContainer.codingPath, debugDescription: "No WRequest key found"))
        }
    }
}

extension KeyedEncodingContainer {
    mutating func encodeJSONAble(_ value: AnyObject, forKey key: K) throws {
        switch value.self {
        case let value as WFile: try encode(value, forKey: key)
        case let value as WFolder: try encode(value, forKey: key)
        case let value as WList: try encode(value, forKey: key)
        case let value as WTask: try encode(value, forKey: key)
        case let value as WMembership: try encode(value, forKey: key)
        case let value as WNote: try encode(value, forKey: key)
        case let value as WReminder: try encode(value, forKey: key)
        case let value as WSetting: try encode(value, forKey: key)
        case let value as WSubtask: try encode(value, forKey: key)
        case let value as WTaskComment: try encode(value, forKey: key)
        case let value as WTaskCommentsState: try encode(value, forKey: key)
        case let value as WListPosition: try encode(value, forKey: key)
        case let value as WTaskPosition: try encode(value, forKey: key)
        case let value as WSubtaskPosition: try encode(value, forKey: key)
        case let value as WUser: try encode(value, forKey: key)
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: "Unsupported type \(type(of: value))"))
        }
    }
}

extension KeyedDecodingContainer {
    func decodeWobject(keyedBy type: K.Type, forKey key: K, typeKey: K) throws -> Revisionable {
        let objContainer = try nestedContainer(keyedBy: type, forKey: key)
        let mappingType = try objContainer.decode(MappingType.self, forKey: typeKey)
        switch mappingType {
        case .File: return try decode(WFile.self, forKey: key)
        case .Folder: return try decode(WFolder.self, forKey: key)
        case .List: return try decode(WList.self, forKey: key)
        case .Task: return try decode(WTask.self, forKey: key)
        case .Membership: return try decode(WMembership.self, forKey: key)
        case .Note: return try decode(WNote.self, forKey: key)
        case .Reminder: return try decode(WReminder.self, forKey: key)
        case .Setting: return try decode(WSetting.self, forKey: key)
        case .Subtask: return try decode(WSubtask.self, forKey: key)
        case .TaskComment: return try decode(WTaskComment.self, forKey: key)
        case .TaskCommentsState: return try decode(WTaskCommentsState.self, forKey: key)
        case .ListPosition: return try decode(WListPosition.self, forKey: key)
        case .TaskPosition: return try decode(WTaskPosition.self, forKey: key)
        case .SubtaskPosition: return try decode(WSubtaskPosition.self, forKey: key)
        case .User: return try decode(WUser.self, forKey: key)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: objContainer.codingPath, debugDescription: "Unsuported object type \(mappingType.rawValue)"))
        }
    }
}
