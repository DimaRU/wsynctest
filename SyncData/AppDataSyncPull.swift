////
///  AppDataSyncPull.swift
//

import Foundation
import PromiseKit

// MARK: - Pull data
extension AppDataSync {
    
    /// Search differences between local and remote
    ///
    /// - Parameters:
    ///   - local: local array of WObjects
    ///   - remote: remote array of WObjects
    /// - Returns: tuple (removedIds: [Int], changedIds: [Int]) where:
    ///         removedIds - no more exist ids, must be removed
    ///         changedIds = changed and new ids
    func diffWobjectSets<T: WObject, K: WObject>(old: Set<T>?, new: Set<K>) -> (removedIds: Set<Int>, changedIds: Set<Int>) {
        var removedIds = Set<Int>()
        var changedIds = Set<Int>(new.map {$0.id})
        for oldObject in old ?? [] {
            guard let newObject = new[oldObject.id] else {
                removedIds.insert(oldObject.id)       // no remote with that id, removed
                continue
            }
            if newObject.revision == oldObject.revision {
                changedIds.remove(oldObject.id)       // not changed or new
            }
        }
        print("Diff:", T.self, "removed:", removedIds, "changed:", changedIds)
        return (removedIds: removedIds, changedIds: changedIds)
    }
    
    func syncWObjectSets<T: WObject>(new: Set<T>, parentId: Int) {
        let path = appData.keyPath(T.self) as! ReferenceWritableKeyPath<AppData, AppData.WObjectSetDictionary<T>>
        let (removedId, changedId) = diffWobjectSets(old: appData[keyPath: path][parentId], new: new)
        if !removedId.isEmpty || !changedId.isEmpty {
            appData.self[keyPath: path][parentId] = new
        }
    }
    
    func syncWObjectSets<T: WObject>(new: Set<T>) {
        let path = appData.keyPath(T.self) as! ReferenceWritableKeyPath<AppData, Set<T>>
        let (removedId, changedId) = diffWobjectSets(old: appData[keyPath: path], new: new)
        if !removedId.isEmpty || !changedId.isEmpty {
            appData.self[keyPath: path] = new
        }
    }

    func syncWObjects<T: WObject>(new: T, parentId: Int) {
        let path = appData.keyPath(T.self) as! ReferenceWritableKeyPath<AppData, AppData.WObjectSetDictionary<T>>
        appData.self[keyPath: path][parentId].update(with: new)
    }

    func syncWObjects<T: WObject>(new: T) {
        let path = appData.keyPath(T.self) as! ReferenceWritableKeyPath<AppData, Set<T>>
        appData.self[keyPath: path].update(with: new)
    }

    /// Pull leafs of task.
    ///
    /// - Returns: Promise<Void>
    private func pullTaskLeaf(taskId: TaskId) -> Promise<Void> {
        return when(fulfilled:
            self.get(WSubtask.self, taskId: taskId),
            self.get(WSubtaskPosition.self, taskId: taskId),
            self.get(WFile.self, taskId: taskId),
            self.get(WNote.self, taskId: taskId),
            self.get(WTaskComment.self, taskId: taskId))
            .done { subtasks, subtaskPositions, files, notes, taskComments in
                self.syncWObjectSets(new: subtasks, parentId: taskId)
                self.syncWObjectSets(new: subtaskPositions, parentId: taskId)
                self.syncWObjectSets(new: files, parentId: taskId)
                self.syncWObjectSets(new: notes, parentId: taskId)
                self.syncWObjectSets(new: taskComments, parentId: taskId)
        }
    }
    
    /// Pull task.
    ///
    /// - Returns: Promise<Void>
    private func pullTasks(listId: ListId) -> Promise<Void> {
        return when(fulfilled: WAPI.getRevision(WTask.self, listId: listId, completed: false),
                    WAPI.getRevision(WTask.self, listId: listId, completed: true))
            .then { taskURevisions, taskCRevisions -> Promise<Void> in
                let taskRevisions = taskURevisions.union(taskCRevisions)
                let (removedId, changedId) = self.diffWobjectSets(old: self.appData.tasks[listId], new: taskRevisions)
                removedId.forEach { self.appData.removeTaskLeaf(taskId: $0) }
                switch changedId.count {
                case 0:
                    return .value(())
                case 1:
                    return self.get(WTask.self, id: changedId.first!)
                        .then { task in
                            self.pullTaskLeaf(taskId: task.id).map { task }
                        }.done { task in
                            self.syncWObjects(new: task, parentId: listId)
                    }
                default:
                    return when(fulfilled: self.get(WTask.self, listId: listId, completed: false),
                                           self.get(WTask.self, listId: listId, completed: true))
                        .then { tasksUncompleted, tasksCompleted in
                            when(fulfilled: changedId.map{ self.pullTaskLeaf(taskId: $0) }).map { tasksUncompleted.union(tasksCompleted) }
                        }.done { tasks in
                            self.syncWObjectSets(new: tasks, parentId: listId)
                    }
                }
        }
    }
    
    /// Pull leafs of list.
    ///
    /// - Returns: Promise<Void>
    private func pullListLeaf(listId: ListId) -> Promise<Void> {
        return pullTasks(listId: listId)
            .then { _ in
                when(fulfilled:
                    self.get(WMembership.self, listId: listId),
                    self.get(WTaskPosition.self, listId: listId))
            }.done { memberships, taskPositions in
                self.syncWObjectSets(new: memberships, parentId: listId)
                self.syncWObjectSets(new: taskPositions, parentId: listId)
        }
    }
    
    /// Pull lists
    ///
    /// - Returns: Promise<Void>
    private func pullLists() -> Promise<Void> {
        return WAPI.getRevision(WList.self)
            .then { listRevisions -> Promise<Void> in
                let (removedId, changedId) = self.diffWobjectSets(old: self.appData.lists, new: listRevisions)
                removedId.forEach { self.appData.removeListLeaf(listId: $0) }
                switch changedId.count {
                case 0:
                    return .value(())
                case 1:
                    return self.get(WList.self, id: changedId.first!)
                        .then { list in
                            self.pullListLeaf(listId: list.id).map { list }
                        }.done { list in
                            self.syncWObjects(new: list)
                    }
                default:
                    return self.get(WList.self)
                        .then { lists in
                            when(fulfilled: changedId.map{ self.pullListLeaf(listId: $0) }).map { lists }
                        }.done { lists in
                            self.syncWObjectSets(new: lists)
                    }
                    
                }
        }
        
    }
    
    
    /// Pull settings.
    ///
    /// - Returns: Promise<Void>
    private func pullSettings() -> Promise<Void> {
        return WAPI.getRevision(WSetting.self)
            .then { settingResvisions -> Promise<Void> in
                let (removedId, changedId) = self.diffWobjectSets(old: self.appData.settings, new: settingResvisions)
                assert(removedId.isEmpty)
                switch changedId.count {
                case 0:
                    return .value(())
                case 1:
                    return self.get(WSetting.self, id: changedId.first!)
                        .done { setting in
                            self.syncWObjects(new: setting)
                    }
                default:
                    return self.get(WSetting.self)
                        .done { settings in
                            self.syncWObjectSets(new: settings)
                    }
                }
        }
    }
    
    /// Pull leafs of user.
    ///
    /// - Returns: Promise<Void>
    private func pullUserLeaf() -> Promise<Void> {
        return pullSettings()
            .then {
                self.get(WReminder.self)
            }.done { reminders in
                self.syncWObjectSets(new: reminders)
        }
    }
    
    
    
    /// Pull leafs of root.
    ///
    /// - Returns: Promise<Void>
    private func pullRootLeaf() -> Promise<Void> {
        return pullLists()
            .then {
                when(fulfilled:
                     self.get(WListPosition.self),
                     self.get(WFolder.self))
            }.done { listPositions, folders in
                self.syncWObjectSets(new: listPositions)
                self.syncWObjectSets(new: folders)
        }
    }
    
    
    public func pull(completion: @escaping () -> Void) {
        var newRoot: WRoot!
        firstly {
            WAPI.getRoot()
            }.then { root -> Promise<Void> in
                if root.revision > self.appData.root.revision, self.syncState == .idle {
                    log("Pull root: \(self.appData.root.revision)->\(root.revision)")
                    self.syncState = .pull
                    newRoot = root
                    return self.pullRootLeaf()
                }
                log("Sync cancelled: Nothing changed", color: .green)
                throw PMKError.cancelled
            }.then {
                self.get(WUser.self)
            }.then { users -> Promise<Void> in
                let userId = newRoot.userId
                if (self.appData.users[userId]?.revision ?? 0) != users[userId]!.revision {
                    log("Pull user: \(self.appData.users[userId]?.revision ?? 0)->\(users[userId]!.revision)")
                    return self.pullUserLeaf()
                        .done { _ in
                            self.appData.users = users
                    }
                } else {
                    return .value(())
                }
            }.done { _ in
                self.appData.root = newRoot
                log("Sync ok", color: .green)
            }.ensure {
                if self.syncState == .pull {
                    self.syncState = .idle
                }
                DispatchQueue.main.async {
                    completion()
                }
            }.catch { (error) -> Void in
                log("Sync error", color: .red)
                log(error: error)
        }
    }


    // MARK: Pull network accessors
    private func get<T: WObject>(_ type: T.Type, id: Int) -> Promise<T> {
        guard syncState == .pull else { return Promise(error: PMKError.cancelled) }
        return WAPI.get(type, id: id)
    }

    private func get<T: WObject>(_ type: T.Type) -> Promise<Set<T>> {
        guard syncState == .pull else { return Promise(error: PMKError.cancelled) }
        return WAPI.get(type)
    }

    private func get<T: WObject>(_ type: T.Type, listId: Int, completed: Bool = false) -> Promise<Set<T>> {
        guard syncState == .pull else { return Promise(error: PMKError.cancelled) }
        return WAPI.get(type, listId: listId, completed: completed)
    }

    private func get<T: WObject>(_ type: T.Type, taskId: Int) -> Promise<Set<T>> {
        guard syncState == .pull else { return Promise(error: PMKError.cancelled) }
        return WAPI.get(type, taskId: taskId)
    }

}
