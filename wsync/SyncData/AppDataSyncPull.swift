//
//  AppDataSyncPull.swift
//  wsync
//
//  Created by Dmitriy Borovikov on 29.06.2018.
//  Copyright © 2018 Dmitriy Borovikov. All rights reserved.
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
                var (removedId, changedId) = self.diffWobjectSets(old: self.appData.subtasks[taskId], new: subtasks)
                if !removedId.isEmpty || !changedId.isEmpty { self.appData.subtasks[taskId] = subtasks }
                
                (removedId, changedId) = self.diffWobjectSets(old: self.appData.subtaskPositions[taskId], new: subtaskPositions)
                if !removedId.isEmpty || !changedId.isEmpty { self.appData.subtaskPositions[taskId] = subtaskPositions }
                
                (removedId, changedId) = self.diffWobjectSets(old: self.appData.notes[taskId], new: notes)
                if !removedId.isEmpty || !changedId.isEmpty { self.appData.notes[taskId] = notes }
                
                (removedId, changedId) = self.diffWobjectSets(old: self.appData.files[taskId], new: files)
                if !removedId.isEmpty || !changedId.isEmpty { self.appData.files[taskId] = files }
                
                (removedId, changedId) = self.diffWobjectSets(old: self.appData.taskComments[taskId], new: taskComments)
                if !removedId.isEmpty || !changedId.isEmpty { self.appData.taskComments[taskId] = taskComments }
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
                removedId.forEach { self.appData.removeTaskLeaf(listId: listId, taskId: $0) }
                switch changedId.count {
                case 0:
                    return .value(())
                case 1:
                    return self.get(WTask.self, id: changedId.first!)
                        .then { task in
                            self.pullTaskLeaf(taskId: task.id).map { task }
                        }.done { task in
                            self.appData.tasks[listId].update(with: task)
                    }
                default:
                    return when(fulfilled: self.get(WTask.self, listId: listId, completed: false),
                                           self.get(WTask.self, listId: listId, completed: true))
                        .then { tasksUncompleted, tasksCompleted in
                            when(fulfilled: changedId.map{ self.pullTaskLeaf(taskId: $0) }).map { tasksUncompleted.union(tasksCompleted) }
                        }.done { tasks in
                            self.appData.tasks[listId] = tasks
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
                var (removedId, changedId) = self.diffWobjectSets(old: self.appData.memberships[listId], new: memberships)
                if !removedId.isEmpty || !changedId.isEmpty { self.appData.memberships[listId] = memberships }
                
                (removedId, changedId) = self.diffWobjectSets(old: self.appData.taskPositions[listId], new: taskPositions)
                if !removedId.isEmpty || !changedId.isEmpty { self.appData.taskPositions[listId] = taskPositions }
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
                            self.appData.update(list)
                    }
                default:
                    return self.get(WList.self)
                        .then { lists in
                            when(fulfilled: changedId.map{ self.pullListLeaf(listId: $0) }).map { lists }
                        }.done { lists in
                            self.appData.lists = lists
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
                            self.appData.settings.update(with: setting)
                    }
                default:
                    return self.get(WSetting.self)
                        .done { settings in
                            self.appData.settings = settings
                    }
                }
        }
    }
    
    /// Pull leafs of user.
    ///
    /// - Returns: Promise<Void>
    private func pullUserLeaf() -> Promise<Void> {
        return pullSettings()
    }
    
    
    
    /// Pull leafs of root.
    ///
    /// - Returns: Promise<Void>
    private func pullRootLeaf() -> Promise<Void> {
        return pullLists()
            .then { _ in
                when(fulfilled:
                     self.get(WListPosition.self),
                     self.get(WReminder.self),
                     self.get(WFolder.self))
            }.done { listPositions, reminders, folders in
                var (removedId, changedId) = self.diffWobjectSets(old: self.appData.folders, new: folders)
                if !removedId.isEmpty || !changedId.isEmpty { self.appData.folders = folders }
                
                (removedId, changedId) = self.diffWobjectSets(old: self.appData.listPositions, new: listPositions)
                if !removedId.isEmpty || !changedId.isEmpty { self.appData.listPositions = listPositions }
                
                (removedId, changedId) = self.diffWobjectSets(old: self.appData.reminders, new: reminders)
                if !removedId.isEmpty || !changedId.isEmpty { self.appData.reminders = reminders }
        }
    }
    
    
    public func pull() {
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
            }.then {(_) -> Promise<Set<WUser>> in
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
            }.catch { (error) -> Void in
                log("Sync error", color: .red)
                log(error: error)
        }
    }
}
