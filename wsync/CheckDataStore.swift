////
///  CheckDataStore.swift
//

import Foundation
import PromiseKit

struct CheckDataStore {
    func fileFrom<T>(_ type: T.Type, parentId: Int? = nil) -> String where T : WObject {
        let fileId = parentId == nil ? T.fileId() : T.fileId(parentId: parentId!)
        return fileId + ".json"
    }

    func compareWobjectSets<T: WObject>(setA: Set<T>, setB: Set<T>?, parentId: Int? = nil) {
        let fileName = fileFrom(T.self, parentId: parentId)
        log("Check \(fileName)")
        if setA != (setB ?? []) {
            let diff = setA.symmetricDifference(setB ?? [])
            log("Error: Not equal: \(T.self), difference elements: \(diff.count)")
            diff.forEach{ log("\($0)") }
        }
    }
    
    
    /// Compare all leafs of task.
    ///
    /// - Returns: Promise<Void>
    private func checkTaskConsistency(taskId: TaskId, appStore: AppData) -> Promise<Void> {
        return WAPI.get(WSubtask.self, taskId: taskId)
            .then { subtasks -> Promise<Set<WSubtaskPosition>> in
                self.compareWobjectSets(setA: subtasks, setB: appStore.subtasks[taskId], parentId: taskId)
                return WAPI.get(WSubtaskPosition.self, taskId: taskId)
            }.then { subtaskPositions -> Promise<Set<WFile>> in
                self.compareWobjectSets(setA: subtaskPositions, setB: appStore.subtaskPositions[taskId], parentId: taskId)
                return WAPI.get(WFile.self, taskId: taskId)
            }.then { files -> Promise<Set<WNote>> in
                self.compareWobjectSets(setA: files, setB: appStore.files[taskId], parentId: taskId)
                return WAPI.get(WNote.self, taskId: taskId)
            }.then { notes -> Promise<Set<WTaskComment>> in
                self.compareWobjectSets(setA: notes, setB: appStore.notes[taskId], parentId: taskId)
                return WAPI.get(WTaskComment.self, taskId: taskId)
            }.done { (taskComments: Set<WTaskComment>) -> Void in
                self.compareWobjectSets(setA: taskComments, setB: appStore.taskComments[taskId], parentId: taskId)
        }
    }
        
    private func checkListConsistency(listId: ListId, appStore: AppData) -> Promise<Void> {
        return when(fulfilled:
                    WAPI.get(WMembership.self, listId: listId),
                    WAPI.get(WTask.self, listId: listId, completed: false),
                    WAPI.get(WTask.self, listId: listId, completed: true))
            .then { memberships, tasksUncompleted, tasksCompleted -> Promise<Void> in
                self.compareWobjectSets(setA: memberships, setB: appStore.memberships[listId], parentId: listId)

                let tasks = tasksUncompleted.union(tasksCompleted)
                self.compareWobjectSets(setA: tasks, setB: appStore.tasks[listId], parentId: listId)
                let taskPromises = tasks.map { self.checkTaskConsistency(taskId: $0.id, appStore: appStore) }
                return when(fulfilled: taskPromises)
            }.then { _ in
                WAPI.get(WTaskPosition.self, listId: listId)
            }.done { taskPositions in
                self.compareWobjectSets(setA: taskPositions, setB: appStore.taskPositions[listId], parentId: listId)
        }
    }
    
    public func checkDataConsistency(appStore: AppData) {
        WAPI.getRoot()
            .then { (root: WRoot) -> Promise<Set<WUser>> in
                if root != appStore.root {
                    log("root is not equal: \(root), \(appStore.root)")
                }
                return WAPI.get(WUser.self)
            }.then { (users: Set<WUser>) -> Promise<Set<WList>> in
                self.compareWobjectSets(setA: users, setB: appStore.users)
                return WAPI.get(WList.self)
            }.then { (lists: Set<WList>) -> Promise<Void> in
                self.compareWobjectSets(setA: lists, setB: appStore.lists)
                let listPromises = lists.map { self.checkListConsistency(listId: $0.id, appStore: appStore)}
                return when(fulfilled: listPromises)
            }.then { (_) -> Promise<Set<WListPosition>> in
                return WAPI.get(WListPosition.self)
            }.then { (listPositions: Set<WListPosition>) -> Promise<Set<WReminder>> in
                self.compareWobjectSets(setA: listPositions, setB: appStore.listPositions)
                return WAPI.get(WReminder.self)
            }.then { (reminders: Set<WReminder>) -> Promise<Set<WFolder>> in
                self.compareWobjectSets(setA: reminders, setB: appStore.reminders)
                return WAPI.get(WFolder.self)
            }.then { (folders: Set<WFolder>) -> Promise<Set<WSetting>> in
                self.compareWobjectSets(setA: folders, setB: appStore.folders)
                return WAPI.get(WSetting.self)
            }.done { (settings: Set<WSetting>) -> Void in
                self.compareWobjectSets(setA: settings, setB: appStore.settings)
            }.ensure {
                log("End check")
            }.catch { (error) in
                log(error: error)
        }
    }
    
}
