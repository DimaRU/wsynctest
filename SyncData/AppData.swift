////
///  AppData.swift
//

import Foundation

typealias TaskId = Int
typealias ListId = Int

class AppData {
    
    public struct WObjectSetDictionary<T: WObject> {
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
        
        public mutating func load(parentId: Int) {
            dictionary[parentId] = diskStore?.load(Set<T>.self, parentId: parentId)
        }

        public var set: Set<T> {
            return dictionary.reduce([], { $0.union($1.value) })
        }

        public func getObject(by id: Int) -> T? {
            for (_, set) in dictionary {
                if let object = set[id] { return object }
            }
            return nil
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
    
    
    private static let keyPathSet: [String: PartialKeyPath<AppData>] = [
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

    func keyPath<T: WObject>(_ type: T.Type) -> PartialKeyPath<AppData> {
        switch type {
            case is WUser.Type: return \AppData.users
            case is WFolder.Type: return \AppData.folders
            case is WList.Type: return \AppData.lists
            case is WListPosition.Type: return \AppData.listPositions
            case is WMembership.Type: return \AppData.memberships
            case is WSetting.Type: return \AppData.settings
            case is WTask.Type: return \AppData.tasks
            case is WTaskPosition.Type: return \AppData.taskPositions
            case is WSubtask.Type: return \AppData.subtasks
            case is WSubtaskPosition.Type: return \AppData.subtaskPositions
            case is WNote.Type: return \AppData.notes
            case is WFile.Type: return \AppData.files
            case is WReminder.Type: return \AppData.reminders
            case is WTaskComment.Type: return \AppData.taskComments
        default:
            fatalError()
        }
    }

    init(diskStore: DiskStore? = nil) {
        root              = WRoot()
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
        
         users         = diskStore.load(Set<WUser>.self) ?? []
         folders       = diskStore.load(Set<WFolder>.self) ?? []
         lists         = diskStore.load(Set<WList>.self) ?? []
         listPositions = diskStore.load(Set<WListPosition>.self) ?? []
         settings      = diskStore.load(Set<WSetting>.self) ?? []
         reminders     = diskStore.load(Set<WReminder>.self) ?? []

        // load leafs
        lists.forEach{ loadListLeaf(from: diskStore, listId: $0.id) }
    }
    
    func loadListLeaf(from diskStore: DiskStore, listId: ListId) {
        memberships.load(parentId: listId)
        tasks.load(parentId: listId)
        taskPositions.load(parentId: listId)
        
        tasks[listId].forEach{ loadTaskLeaf(from: diskStore, taskId: $0.id) }
    }
    
    func loadTaskLeaf(from diskStore: DiskStore, taskId: TaskId) {
        subtasks.load(parentId: taskId)
        subtaskPositions.load(parentId: taskId)
        notes.load(parentId: taskId)
        files.load(parentId: taskId)
        taskComments.load(parentId: taskId)
    }
}

extension AppData {
    private func incUserRevision() {
        guard var user = users[root.userId] else { return }
        user.revision += 1
        users.update(with: user)
    }

    private func incRevision<T: WObject>(type: T.Type, id: Int, parentId: Int?) {
        switch type {
        case is WTask.Type:
            var task = tasks[parentId!][id]!
            task.revision += 1
            tasks[parentId!].update(with: task)
        case is WList.Type:
            var list = lists[id]!
            list.revision += 1
            lists.update(with: list)
        case is WMembership.Type:
            var membership = memberships[parentId!][id]!
            membership.revision += 1
            memberships[parentId!].update(with: membership)
        default:
            fatalError()
        }

    }

    func createdRevisionTouch<T: WObject & WCreatable>(wobject: T) {
        switch wobject {
        case is WFile,
             is WNote,
             is WSubtask:
            let taskId = (wobject as! TaskChild).taskId
            let task = tasks.getObject(by: taskId)!
            incRevision(type: WTask.self, id: task.id, parentId: task.listId)
            incRevision(type: WList.self, id: task.listId, parentId: nil)
            root.revision += 1
        case is WFolder:
            root.revision += 1
        case is WList:
            incUserRevision()
            root.revision += 2
        case let reminder as WReminder:
            let task = tasks.getObject(by: reminder.taskId)!
            let listId = task.listId
            var membership = memberships[listId].first(where: { $0.userId == root.userId })!
            membership.revision += 1
            memberships[listId].update(with: membership)
            incUserRevision()
            root.revision += 2
        case let task as WTask:
            incRevision(type: WList.self, id: task.listId, parentId: nil)
            root.revision += 1
        case let taskComment as WTaskComment:
            let task = tasks.getObject(by: taskComment.taskId)!
            let listId = task.listId
            incRevision(type: WTask.self, id: task.id, parentId: task.listId)
            incRevision(type: WList.self, id: task.listId, parentId: nil)
            var membership = memberships[listId].first(where: { $0.userId == root.userId })!
            membership.revision += 1
            memberships[listId].update(with: membership)
            incUserRevision()
            root.revision += 2
        default:
            fatalError()
        }

    }

    func updatedRevisionTouch<T: WObject>(wobject: T) {
        switch wobject {
        case is WFolder.Type,
             is WList.Type,
             is WListPosition.Type:
            root.revision += 1
        case is WNote,
             is WSubtask,
             is WSubtaskPosition:
            let taskId = (wobject as! TaskChild).taskId
            let task = tasks.getObject(by: taskId)!
            incRevision(type: WTask.self, id: task.id, parentId: task.listId)
            incRevision(type: WList.self, id: task.listId, parentId: nil)
            root.revision += 1
        case let reminder as WReminder:
            let task = tasks.getObject(by: reminder.taskId)!
            let listId = task.listId
            var membership = memberships[listId].first(where: { $0.userId == root.userId })!
            membership.revision += 1
            memberships[listId].update(with: membership)
            incUserRevision()
            root.revision += 1
        case is WSetting.Type:
            incUserRevision()
            root.revision += 1
        case let task as WTask:
            incRevision(type: WList.self, id: task.listId, parentId: nil)
            root.revision += 1
        case let taskPosition as WTaskPosition:
            incRevision(type: WList.self, id: taskPosition.listId, parentId: nil)
            root.revision += 1
        default:
            fatalError()
        }
    }

    func deletedRevisionTouch<T: WObject & WCreatable>(wobject: T) {
        switch wobject {
        case is WFile,
             is WNote,
             is WSubtask:
            let taskId = (wobject as! TaskChild).taskId
            let task = tasks.getObject(by: taskId)!
            incRevision(type: WTask.self, id: task.id, parentId: task.listId)
            incRevision(type: WList.self, id: task.listId, parentId: nil)
            root.revision += 1
        case is WFolder:
            root.revision += 1
        case is WList:
            incUserRevision()
            root.revision += 2
        case let reminder as WReminder:
            let task = tasks.getObject(by: reminder.taskId)!
            let listId = task.listId
            var membership = memberships[listId].first(where: { $0.userId == root.userId })!
            membership.revision += 1
            memberships[listId].update(with: membership)
            incUserRevision()
            root.revision += 1
        case let task as WTask:
            incRevision(type: WList.self, id: task.listId, parentId: nil)
            root.revision += 1
        case let taskComment as WTaskComment:
            let task = tasks.getObject(by: taskComment.taskId)!
            let listId = task.listId
            incRevision(type: WTask.self, id: task.id, parentId: task.listId)
            incRevision(type: WList.self, id: task.listId, parentId: nil)
            var membership = memberships[listId].first(where: { $0.userId == root.userId })!
            membership.revision += 2
            memberships[listId].update(with: membership)
            incUserRevision()
            incUserRevision()
            root.revision += 3
        default:
            fatalError()
        }
    }


    func removeTaskLeaf(taskId: TaskId) {
        subtasks[taskId] = []
        subtaskPositions[taskId] = []
        notes[taskId] = []
        files[taskId] = []
        taskComments[taskId] = []

        reminders = reminders.filter{ $0.taskId != taskId }
    }
    
    func removeListLeaf(listId: ListId) {
        tasks[listId].forEach {
            removeTaskLeaf(taskId: $0.id)
        }
        tasks[listId] = []
        taskPositions[listId] = []
        memberships[listId] = []
    }

    func replaceId<T: WObject & WCreatable>(for type: T.Type, fakeId: Int, id: Int, parentId: Int?) {
        if type is WList.Type {
            // task, taskPositions, memberships, listPostitions, folders
            let childTasks: [WTask] = self.tasks[fakeId].map {
                var task = $0
                task.listId = id
                return task
            }
            self.tasks[fakeId] = []
            self.tasks[id] = Set<WTask>(childTasks)

            if let taskPosition = self.taskPositions[fakeId].first {
                let newTaskPosition = WTaskPosition(storedSyncState: .synced,
                                             id: id,
                                             revision: taskPosition.revision,
                                             listId: id,
                                             values: taskPosition.values)
                taskPositions[fakeId] = []
                taskPositions[id].update(with: newTaskPosition)
            }

            if var membership = self.memberships[fakeId].first {
                membership.listId = id
                memberships[fakeId] = []
                memberships[id].update(with: membership)
            }

            if var listPostion = self.listPositions.first {
                listPostion.values = listPostion.values.map{ $0 == fakeId ? id: $0 }
            }

            for folderSrc in folders {
                var folder = folderSrc
                folder.listIds = folderSrc.listIds.map{ $0 == fakeId ? id: $0 }
                folders.update(with: folder)
            }

        }

        if type is WTask.Type {
            if var reminder = self.reminders.first(where: { $0.taskId == fakeId}) {
                reminder.taskId = id
                self.reminders.update(with: reminder)
            }
            
            if var taskPosition = taskPositions[parentId!].first {
                taskPosition.values = taskPosition.values.map{ $0 == fakeId ? id: $0 }
                taskPositions[parentId!].update(with: taskPosition)
            }

            let subtasks: [WSubtask] = self.subtasks[fakeId].map {
                var subtask = $0
                subtask.taskId = id
                return subtask
            }
            self.subtasks[fakeId] = []
            self.subtasks[id] = Set<WSubtask>(subtasks)

            let notes: [WNote] = self.notes[fakeId].map {
                var note = $0
                note.taskId = id
                return note
            }
            self.notes[fakeId] = []
            self.notes[id] = Set<WNote>(notes)

            let taskComments: [WTaskComment] = self.taskComments[fakeId].map {
                var taskComment = $0
                taskComment.taskId = id
                return taskComment
            }
            self.taskComments[fakeId] = []
            self.taskComments[id] = Set<WTaskComment>(taskComments)

            if let subtaskPosition = self.subtaskPositions[fakeId].first {
                let newSubtaskPosition = WSubtaskPosition(storedSyncState: .synced,
                                                          id: id,
                                                          revision: subtaskPosition.revision,
                                                          taskId: id,
                                                          values: subtaskPosition.values)
                self.subtaskPositions[fakeId] = []
                self.subtaskPositions[id].update(with: newSubtaskPosition)
            }
        }

        if type is WSubtask.Type {
            if var subtaskPosition = subtaskPositions[parentId!].first {
                subtaskPosition.values = subtaskPosition.values.map{ $0 == fakeId ? id: $0 }
                subtaskPositions[parentId!].update(with: subtaskPosition)
            }
        }

    }

}

// MARK: Accessors
extension AppData {
    func updateObject<T: WObject>(_ wobject: T){
        switch wobject {
        case let listChild as ListChild:
            let parentId = listChild.listId
            let path = keyPath(T.self) as! ReferenceWritableKeyPath<AppData, WObjectSetDictionary<T>>
            self[keyPath: path][parentId].update(with: wobject)
        case let taskChild as TaskChild:
            let parentId = taskChild.taskId
            let path = keyPath(T.self) as! ReferenceWritableKeyPath<AppData, WObjectSetDictionary<T>>
            self[keyPath: path][parentId].update(with: wobject)
        default:
            let path = keyPath(T.self) as! ReferenceWritableKeyPath<AppData, Set<T>>
            self[keyPath: path].update(with: wobject)
        }
    }

    func getSource<T: WObject>(for wobject: T) -> T? {
        switch wobject {
        case let listChild as ListChild:
            let parentId = listChild.listId
            let path = keyPath(T.self) as! ReferenceWritableKeyPath<AppData, WObjectSetDictionary<T>>
            return self[keyPath: path][parentId][wobject.id]
        case let taskChild as TaskChild:
            let parentId = taskChild.taskId
            let path = keyPath(T.self) as! ReferenceWritableKeyPath<AppData, WObjectSetDictionary<T>>
            return self[keyPath: path][parentId][wobject.id]
        default:
            let path = keyPath(T.self) as! ReferenceWritableKeyPath<AppData, Set<T>>
            return self[keyPath: path][wobject.id]
        }
    }

    func replaceObject<T: WObject>(type: T.Type, id: Int, parentId: Int?, to: T) {
        switch type {
        case is ListChild.Type:
            let path = keyPath(T.self) as! ReferenceWritableKeyPath<AppData, WObjectSetDictionary<T>>
            self[keyPath: path].remove(parentId: parentId!, id: id)
            self[keyPath: path][parentId!].update(with: to)
        case is TaskChild.Type:
            let path = keyPath(T.self) as! ReferenceWritableKeyPath<AppData, WObjectSetDictionary<T>>
            self[keyPath: path].remove(parentId: parentId!, id: id)
            self[keyPath: path][parentId!].update(with: to)
        default:
            let path = keyPath(T.self) as! ReferenceWritableKeyPath<AppData, Set<T>>
            self[keyPath: path].remove(id: id)
            self[keyPath: path].update(with: to)
        }
    }

    func deleteObject<T: WObject>(type: T.Type, id: Int, parentId: Int?) {
        switch type {
        case is WList.Type:
            lists.remove(id: id)
            removeListLeaf(listId: id)
        case is WTask.Type:
            tasks.remove(parentId: parentId!, id: id)
            removeTaskLeaf(taskId: id)
        case is ListChild.Type,
             is TaskChild.Type:
            let path = keyPath(T.self) as! ReferenceWritableKeyPath<AppData, WObjectSetDictionary<T>>
            self[keyPath: path].remove(parentId: parentId!, id: id)
        default:
            let path = keyPath(T.self) as! ReferenceWritableKeyPath<AppData, Set<T>>
            self[keyPath: path].remove(id: id)
        }
    }
}
