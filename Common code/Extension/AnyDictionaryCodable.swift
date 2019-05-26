////
///  AnyDictionaryCodable.swift
//


import Foundation

struct DynamicKey: CodingKey {
    var stringValue: String
    init(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int?
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer {
    func decode(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any] {
        let container = try self.nestedContainer(keyedBy: DynamicKey.self, forKey: key)
        return try container.decode(type)
    }

    func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        var dictionary = [String: Any]()

        for key in allKeys {
            print(key.stringValue)
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let dateValue = try? decode(Date.self, forKey: key) {
                dictionary[key.stringValue] = dateValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let intArrayValue = try? decode([Int].self, forKey: key) {
                dictionary[key.stringValue] = intArrayValue
            } else if let stringArrayValue = try? decode([String].self, forKey: key) {
                dictionary[key.stringValue] = stringArrayValue
            } else if let nestedDictionary = try? decode([String: Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {
    mutating func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        let nestedContainer = try self.nestedContainer(keyedBy: DynamicKey.self)
        return try nestedContainer.decode(type)
    }
}


extension KeyedEncodingContainerProtocol where Key == DynamicKey {
    mutating func encode(_ value: [String: Any]) throws {
        for (key, value) in value {
            let key = DynamicKey(stringValue: key)
            switch value {
            case let value as Bool:
                try encode(value, forKey: key)
            case let value as Int:
                try encode(value, forKey: key)
            case let value as String:
                try encode(value, forKey: key)
            case let value as Date:
                try encode(value, forKey: key)
            case let value as [String: Any]:
                try encode(value, forKey: key)
            case let value as [Int]:
                try encode(value, forKey: key)
            case let value as [String]:
                try encode(value, forKey: key)
            case Optional<Any>.none:
                try encodeNil(forKey: key)
            default:
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + [key], debugDescription: "Invalid JSON value"))
            }
        }
    }
}

extension KeyedEncodingContainerProtocol {
    mutating func encode(_ value: [String: Any]?, forKey key: Key) throws {
        if value != nil {
            var container = self.nestedContainer(keyedBy: DynamicKey.self, forKey: key)
            try container.encode(value!)
        }
    }
}
