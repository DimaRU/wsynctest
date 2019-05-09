////
///  AppData.swift
//


import Cocoa

typealias TaskId = Int
typealias ListId = Int

class AppData {
    
    struct WObjectSetDictionary<T: WObject> {
        var dictionary: [Int:Set<T>]
        private weak var diskStore: DiskStore?

        subscript(index: Int) -> Set<T> {
            get {
                return dictionary[index, default: []]
            }
            set(newValue) {
                if newValue.isEmpty {
                    guard dictionary[index] != nil else { return }
                    dictionary[index] = nil
                } else {
                    dictionary[index] = newValue
                }
                diskStore?.persist(dictionary[index], parentId: index)
            }
        }
        
        mutating func remove(parentId: Int, id: Int) {
            if let member = dictionary[parentId]?[id] {
                dictionary[parentId]?.remove(member)
                diskStore?.persist(dictionary[parentId], parentId: parentId)
            }
        }
        
        public init(_ diskStore: DiskStore?) {
            self.dictionary = [:]
            self.diskStore = diskStore
        }
        
    }
    
    var diskStore: DiskStore?
    
    var root: WRoot {
        didSet { diskStore?.persist(root) }
    }
    var users: Set<WUser> = [] {
        didSet { diskStore?.persist(users) }
    }
    var folders: Set<WFolder> = [] {
        didSet { diskStore?.persist(folders) }
    }
    var lists: Set<WList> = [] {
        didSet { diskStore?.persist(lists) }
    }
    var listPositions: Set<WListPosition> = [] {
        didSet { diskStore?.persist(listPositions) }
    }
    var settings: Set<WSetting> = [] {
        didSet { diskStore?.persist(settings) }
    }
    var reminders: Set<WReminder> = [] {
        didSet { diskStore?.persist(reminders) }
    }

    var memberships: WObjectSetDictionary<WMembership>
    var tasks: WObjectSetDictionary<WTask>
    var taskPositions: WObjectSetDictionary<WTaskPosition>
    
     var subtasks: WObjectSetDictionary<WSubtask>
     var subtaskPositions: WObjectSetDictionary<WSubtaskPosition>
     var notes: WObjectSetDictionary<WNote>
     var files: WObjectSetDictionary<WFile>
     var taskComments: WObjectSetDictionary<WTaskComment>
    
    
    static let keyPathSet: [String: PartialKeyPath<AppData>] = [
        WUser.typeName(): \AppData.users,
        WFolder.typeName(): \AppData.folders,
        WList.typeName(): \AppData.lists,
        WListPosition.typeName(): \AppData.listPositions,
        WMembership.typeName(): \AppData.memberships,
        WSetting.typeName(): \AppData.settings,
        WTask.typeName(): \AppData.tasks,
        WTaskPosition.typeName(): \AppData.taskPositions,
        WSubtask.typeName(): \AppData.subtasks,
        WSubtaskPosition.typeName(): \AppData.subtaskPositions,
        WNote.typeName(): \AppData.notes,
        WFile.typeName(): \AppData.files,
        WReminder.typeName(): \AppData.reminders,
        WTaskComment.typeName(): \AppData.taskComments
    ]


    init(diskStore: DiskStore? = nil) {
        root              = WRoot(id : 0, revision : 0)
        memberships       = WObjectSetDictionary<WMembership>(diskStore)
        tasks             = WObjectSetDictionary<WTask>(diskStore)
        taskPositions     = WObjectSetDictionary<WTaskPosition>(diskStore)
         subtasks         = WObjectSetDictionary<WSubtask>(diskStore)
         subtaskPositions = WObjectSetDictionary<WSubtaskPosition>(diskStore)
         notes            = WObjectSetDictionary<WNote>(diskStore)
         files            = WObjectSetDictionary<WFile>(diskStore)
         taskComments     = WObjectSetDictionary<WTaskComment>(diskStore)
        
        if diskStore != nil {
            loadAll(from: diskStore!)
            self.diskStore = diskStore
        }
    }
}

extension AppData {
    /// Load all data from diskStore
    // Todo: move in backgroud queue
    func loadAll(from diskStore: DiskStore) {
        
        guard let root = diskStore.load(WRoot.self) else { return }
        self.root = root
        
         users         = diskStore.load([WUser].self) ?? []
         folders       = diskStore.load([WFolder].self) ?? []
         lists         = diskStore.load([WList].self) ?? []
         listPositions = diskStore.load([WListPosition].self) ?? []
         settings      = diskStore.load([WSetting].self) ?? []
         reminders     = diskStore.load([WReminder].self) ?? []

        // load leafs
        lists.forEach{ loadListLeaf(from: diskStore, listId: $0.id) }
    }
    
    func loadListLeaf(from diskStore: DiskStore, listId: ListId) {
        memberships.dictionary[listId] = diskStore.load([WMembership].self, parentId: listId)
        tasks.dictionary[listId] = diskStore.load([WTask].self, parentId: listId)
        taskPositions.dictionary[listId] = diskStore.load([WTaskPosition].self, parentId: listId)
        
        tasks[listId].forEach{ loadTaskLeaf(from: diskStore, taskId: $0.id) }
    }
    
    func loadTaskLeaf(from diskStore: DiskStore, taskId: TaskId) {
        subtasks.dictionary[taskId] = diskStore.load([WSubtask].self, parentId: taskId)
        subtaskPositions.dictionary[taskId] = diskStore.load([WSubtaskPosition].self, parentId: taskId)
        notes.dictionary[taskId] = diskStore.load([WNote].self, parentId: taskId)
        files.dictionary[taskId] = diskStore.load([WFile].self, parentId: taskId)
        taskComments.dictionary[taskId] = diskStore.load([WTaskComment].self, parentId: taskId)
    }
}

extension AppData {
    func removeTaskLeaf(listId: ListId, taskId: TaskId) {
        subtasks[taskId] = []
        subtaskPositions[taskId] = []
        notes[taskId] = []
        files[taskId] = []
        taskComments[taskId] = []

        reminders = reminders.filter{ $0.taskId != taskId }
    }
    
    func removeListLeaf(listId: ListId) {
        tasks[listId].forEach {
            removeTaskLeaf(listId: listId, taskId: $0.id)
        }
        tasks[listId] = []
        taskPositions[listId] = []
        memberships[listId] = []
    }
}

extension AppData {
    func update<T>(_ wobject: T) where T : WObject {
        var markedObj = wobject
        markedObj.storedSyncState = .modified

        switch markedObj {
        case is ListChild:
            let parentId = (markedObj as! ListChild).listId
            let path = AppData.keyPathSet[T.typeName()]! as! ReferenceWritableKeyPath<AppData, WObjectSetDictionary<T>>
            self[keyPath: path][parentId].update(with: markedObj)
        case is TaskChild:
            let parentId = (markedObj as! TaskChild).taskId
            let path = AppData.keyPathSet[T.typeName()]! as! ReferenceWritableKeyPath<AppData, WObjectSetDictionary<T>>
            self[keyPath: path][parentId].update(with: markedObj)
        default:
            let path = AppData.keyPathSet[T.typeName()]! as! ReferenceWritableKeyPath<AppData, Set<T>>
            self[keyPath: path].update(with: markedObj)
        }
    }
}
