////
///  Queue.swift
//


public struct Queue<T: Codable> {
    fileprivate var array: [T] = [] {
        didSet {
            diskStore?.persist(array)
        }
    }
    private weak var diskStore: DiskStore?
    
    public var count: Int {
        return array.count
    }
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }

    public mutating func enqueueFirst(_ element: T) {
        array.insert(element, at: 0)
    }

    public mutating func replaceFirst(_ element: T) {
        if array.isEmpty {
            array.insert(element, at: 0)
        } else {
            array[0] = element
        }
    }

    @discardableResult
    public mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
    
    public var front: T? {
        return array.first
    }

    init(_ diskStore: DiskStore?) {
        self.diskStore = diskStore
        array = diskStore?.load([T].self) ?? []
    }
}

extension Queue where T == WRequest {
    mutating func replaceId<E: WObject>(for wtype: E.Type, fakeId: Int, id: Int, parentId: Int?) {
        guard !array.isEmpty else { return }
        var newArray: [T] = []
        newArray.reserveCapacity(array.count)
        for index in array.indices {
            var request = array[index]
            if request.id == fakeId {
                request.id = id
            }
            request.parentId = request.parentId == fakeId ? id: parentId
            if (request.params.container["list_id"] as? Int) == fakeId {
                request.params.container["list_id"] = id
            }
            if (request.params.container["task_id"] as? Int) == fakeId {
                request.params.container["task_id"] = id
            }
            if let values = request.params.container["values"] as? [Int] {
                request.params.container["values"] = values.map { $0 == fakeId ? id: fakeId }
            }
            if let listIds = request.params.container["list_ids"] as? [Int] {
                request.params.container["list_ids"] = listIds.map { $0 == fakeId ? id: fakeId }
            }

            newArray.append(request)
        }
        array = newArray
    }
}
