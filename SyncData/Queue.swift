////
///  Queue.swift
//


public struct Queue<T: Codable> {
    fileprivate var array = [T]() {
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
