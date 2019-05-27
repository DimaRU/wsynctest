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
        let mappingType = MappingType(object: wtype)
        for index in array.indices {
            var request = array[index]
            if request.type == mappingType, request.id == fakeId {
                request.id = id
            }
            request.parentId = request.parentId == fakeId ? id: parentId
            switch wtype {
            case is WList.Type:
                if (request.params.container["list_id"] as? Int) == fakeId {
                    request.params.container["list_id"] = id
                }
            case is WTask.Type:
                if (request.params.container["task_id"] as? Int) == fakeId {
                    request.params.container["task_id"] = id
                }
            default:
                break
            }

            #warning("Todo: list_positions, task_positions, subtask_positions, folder")

            newArray.append(request)
        }
        array = newArray
    }
}
