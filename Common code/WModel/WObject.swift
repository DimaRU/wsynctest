////
///  WObject.swift
//

import Foundation

public enum WSyncState: String, Codable {
    case synced
    case modified
    case created
    case deleted
}

public protocol WObject: Revisionable, Hashable {
    var storedSyncState: WSyncState? { get set }
    static var storedProperty: [PartialKeyPath<Self>:String] { get }
    static var mutableProperty: [PartialKeyPath<Self>:String] { get }
}

public extension WObject {
    var syncState: WSyncState {
        get {
            return storedSyncState ?? .synced
        }
        set {
            storedSyncState = newValue
        }
    }
}

public protocol ListChild {
    var listId: Int { get set }
}

public protocol TaskChild {
    var taskId: Int { get set }
}

public protocol WCreatable {
    var createdByRequestId: String? { get }
    static var createFieldList: [PartialKeyPath<Self>] { get }
}

public extension WObject {
    static func typeName() -> String {
        return String(String(describing: self).dropFirst())
    }
    
    static func fileId() -> String {
        return self.typeName()
    }

    static func fileId(parentId: Int) -> String {
        let t = self.typeName()
            return "\(t)-\(parentId)"
    }
}


// MARK: - compare revisions, return true if not equal
infix operator <>
// MARK: - compare stored properties, return true, if all equal
infix operator ====

public extension WObject {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }


    /// Compare id
    ///
    /// - Returns: true if id equal
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func <> (lhs: Self, rhs: Self) -> Bool {
        return lhs.revision != rhs.revision
    }
    
    static func ==== (lhs: Self, rhs: Self) -> Bool {
        for (path, key) in Self.storedProperty {
            if "\(lhs[keyPath: path])" != "\(rhs[keyPath: path])" {
                print("\(lhs.type):\(lhs.id) Not equal:", key, "\(lhs[keyPath: path]) != \(rhs[keyPath: path])")
                return false
            }
        }
        return true
    }
}

fileprivate func compareAny(a: Any, b: Any) -> Bool {
    switch type(of: a) {
    case is String?.Type,
         is String.Type:
        return (a as? String) == (b as? String)
    case is Int?.Type,
         is Int.Type:
        return (a as? Int) == (b as? Int)
    case is Date?.Type,
         is Date.Type:
        return (a as? Date) == (b as? Date)
    case is Bool?.Type,
         is Bool.Type:
        return (a as? Bool) == (b as? Bool)
    case is [Int].Type:
        return (a as? [Int]) == (b as? [Int])
    default: fatalError()
    }
}

fileprivate func filterDates(param: Any) -> Any {
    switch type(of: param) {
    case is Date?.Type,
         is Date.Type:
        let date = param as! Date
        return date.iso8601 as Any
    default: return param
    }
}

extension WObject {
    public func updatableParams() -> [String: Any] {
        var dict: [String: Any] = [:]

        Self.mutableProperty.forEach{ dict[$1] = self[keyPath: $0] }
        return dict
    }

    public func updateParams(from: Self) -> [String: Any] {
        var dict: [String: Any] = [:]
        var deletedList: [String] = []

        let pathList = Self.mutableProperty
        for (path, key) in pathList {
            let oldValue = from[keyPath: path]
            let newValue = self[keyPath: path]
            if compareAny(a: oldValue, b: newValue) {
                continue
            }
            if case Optional<Any>.none = newValue {
                deletedList.append(key)
            } else {
                dict[key] = filterDates(param: newValue)
            }
        }
        if !deletedList.isEmpty {
            dict["remove"] = deletedList
        }
        if !dict.isEmpty {
            dict["revision"] = from.revision
        }
        return dict
    }

    public func updateParams(from source: [String: Any]) -> [String: Any] {
        var dict: [String: Any] = [:]
        var deletedList: [String] = []

        let pathList = Self.mutableProperty
        for (path, key) in pathList {
            let oldValue = source[key] as Any
            let newValue = self[keyPath: path]
            if compareAny(a: oldValue, b: newValue) {
                continue
            }
            if case Optional<Any>.none = newValue {
                deletedList.append(key)
            } else {
                dict[key] = filterDates(param: newValue)
            }
        }
        if !deletedList.isEmpty {
            dict["remove"] = deletedList
        }
        if !dict.isEmpty {
            dict["revision"] = self.revision
        }
        return dict
    }
}

extension WObject where Self: WCreatable {
    public func createParams() -> [String:Any] {
        var params: [String: Any] = [:]

        for path in Self.createFieldList {
            let key = Self.storedProperty[path]!
            let value = self[keyPath: path]
            if case Optional<Any>.none = value {
                continue
            }
            params[key] = filterDates(param: value)
        }
        return params
    }
}

public extension Set where Element: WObject {
    subscript(index: Int) -> Element? {
        get {
            return self.first(where: {$0.id == index})
        }
    }
    
    static func ==== (lhs: Set<Element>, rhs: Set<Element>) -> Bool {
        for lhsValue in lhs {
            guard let rhsValue = rhs[lhsValue.id], lhsValue ==== rhsValue else {
                return false
            }
        }
        return true
    }

    mutating func remove(id: Int) {
        if let member = self[id] {
            self.remove(member)
        }
    }
}
