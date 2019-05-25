//
//  DiskStore.swift
//  wsync
//
//  Created by Dmitriy Borovikov on 30.04.2018.
//  Copyright © 2018 Dmitriy Borovikov. All rights reserved.
//

import Foundation

public enum DiskStoreStoreErrors: Error {
    case CannotUseProvidedItem(item: Any, includedError: NSError)
    case CannotFindItemsFor(type: Any.Type, error: NSError)
    case CannotUse(object : Any, inStoreWithType: Any.Type)
    case CannotUseType(type : Any.Type, inStoreWithType: Any.Type)
    case noValidPathProvided
    case CouldntFindItemForId(id: String, error: NSError)
}

class DiskStore {
    let directory: Disk.Directory
    let filePath: String
    let persistQueue = DispatchQueue(label: "diskStore.wsync", qos: .background)
    
    init(filePath: String, directory: Disk.Directory = .caches) {
        self.filePath = filePath
        self.directory = directory
    }

    private func createPathFrom<T>(_ type: T.Type, parentId: Int? = nil) -> String where T : WObject {
        let fileId = parentId == nil ? T.fileId() : T.fileId(parentId: parentId!)
        return filePath + fileId + ".json"
    }

    private func createPathFrom<T: Codable>(_ type: T.Type) -> String {
        let fileId = String(String(describing: type).dropFirst())
        return filePath + fileId + ".json"
    }

    func getURL() -> URL? {
        return try? Disk.createURL(for: filePath, in: directory)
    }

    func persist<T: WObject>(_ wobject: T) {
        let path = createPathFrom(T.self)
        persistQueue.async {
            try? Disk.save(wobject, to: self.directory, as: path)
        }
    }

    func persist<T: Codable>(_ wobject: [T]) {
        let path = createPathFrom(T.self)
        persistQueue.async {
            try? Disk.save(wobject, to: self.directory, as: path)
        }
    }

    func persist<T: WObject>(_ wobject: Set<T>) {
        let path = createPathFrom(T.self)
        let warray = Array<T>(wobject)
        persistQueue.async {
            try? Disk.save(warray, to: self.directory, as: path)
        }
    }
    
    func persist<T: WObject>(_ wobject: Set<T>?, parentId: Int) {
        let path = createPathFrom(T.self, parentId: parentId)
        guard let wobject = wobject, !wobject.isEmpty else {
            persistQueue.async {
                try? Disk.remove(path, from: self.directory)
            }
            return
        }
        persistQueue.async {
            try? Disk.save(wobject, to: self.directory, as: path)
        }
    }
    
    func load<T: WObject>(_ type: T.Type) -> T? {
        let path = createPathFrom(T.self)
        return try? Disk.retrieve(path, from: directory, as: type)
    }
    
    func load<T: WObject>(_ type: Set<T>.Type) -> Set<T>? {
        let path = createPathFrom(T.self)
        guard let wobject = try? Disk.retrieve(path, from: directory, as: [T].self) else {
            return nil
        }
        return Set<T>(wobject)
    }

    func load<T>(_ type: [T].Type) -> [T]? where T : Codable {
        let path = createPathFrom(T.self)
        return try? Disk.retrieve(path, from: directory, as: [T].self)
    }

    func load<T>(_ type: Set<T>.Type, parentId: Int) -> Set<T>? where T : WObject {
        let path = createPathFrom(T.self, parentId: parentId)
        guard let wobject = try? Disk.retrieve(path, from: directory, as: [T].self) else {
            return nil
        }
        return Set<T>(wobject)
    }

    func delete<T: Codable>(_ type: T.Type) throws {
        let path = createPathFrom(T.self)
        try Disk.remove(path, from: directory)
    }

    func delete<T>(_ type: T.Type) throws where T : WObject {
        let path = createPathFrom(T.self)
        try Disk.remove(path, from: directory)
    }
    
    func delete<T>(_ type: [T].Type, parentId: Int) throws where T : WObject {
        let path = createPathFrom(T.self, parentId: parentId)
        try Disk.remove(path, from: directory)
    }
    
    func exists<T: Codable>(_ type: T.Type) -> Bool {
        let path = createPathFrom(T.self)
        return Disk.exists(path, in: directory)
    }

    func exists<T>(_ type: T.Type) -> Bool where T : WObject {
        let path = createPathFrom(T.self)
        return Disk.exists(path, in: directory)
    }
    
    func exists<T>(_ type: [T].Type, parentId: Int) -> Bool where T : WObject {
        let path = createPathFrom(T.self, parentId: parentId)
        return Disk.exists(path, in: directory)
    }
    
}
