////
///  ChechAppStore.swift
//

import Foundation
import PromiseKit
import XCTest
@testable import wsync

struct CheckAppStore {
    static private func fileFrom<T>(_ type: T.Type, parentId: Int? = nil) -> String where T : WObject {
        let fileId = parentId == nil ? T.fileId() : T.fileId(parentId: parentId!)
        return fileId + ".json"
    }

    static private func compareWobjectSets<T: WObject>(setA: Set<T>, setB: Set<T>, parentId: Int? = nil) {
        let fileName = CheckAppStore.fileFrom(T.self, parentId: parentId)
        XCTAssertEqual(setA, setB, "Not equal: \(T.self), \(fileName), difference elements: \(setA.symmetricDifference(setB))")
    }


    /// Compare all leafs of task.
    ///
    /// - Returns: Promise<Void>
    private static func checkTaskConsistency(taskId: TaskId, appStore: AppData) -> Promise<Void> {
        return WAPI.get(WSubtask.self, taskId: taskId)
            .then { subtasks -> Promise<Set<WSubtaskPosition>> in
                CheckAppStore.compareWobjectSets(setA: subtasks, setB: appStore.subtasks[taskId], parentId: taskId)
                return WAPI.get(WSubtaskPosition.self, taskId: taskId)
            }.then { subtaskPositions -> Promise<Set<WFile>> in
                CheckAppStore.compareWobjectSets(setA: subtaskPositions, setB: appStore.subtaskPositions[taskId], parentId: taskId)
                return WAPI.get(WFile.self, taskId: taskId)
            }.then { files -> Promise<Set<WNote>> in
                CheckAppStore.compareWobjectSets(setA: files, setB: appStore.files[taskId], parentId: taskId)
                return WAPI.get(WNote.self, taskId: taskId)
            }.then { notes -> Promise<Set<WTaskComment>> in
                CheckAppStore.compareWobjectSets(setA: notes, setB: appStore.notes[taskId], parentId: taskId)
                return WAPI.get(WTaskComment.self, taskId: taskId)
            }.done { (taskComments: Set<WTaskComment>) -> Void in
                CheckAppStore.compareWobjectSets(setA: taskComments, setB: appStore.taskComments[taskId], parentId: taskId)
        }
    }

    private static func checkListConsistency(listId: ListId, appStore: AppData) -> Promise<Void> {
        return when(fulfilled:
            WAPI.get(WMembership.self, listId: listId),
                    WAPI.get(WTask.self, listId: listId, completed: false),
                    WAPI.get(WTask.self, listId: listId, completed: true))
            .then { memberships, tasksUncompleted, tasksCompleted -> Promise<Void> in
                CheckAppStore.compareWobjectSets(setA: memberships, setB: appStore.memberships[listId], parentId: listId)

                let tasks = tasksUncompleted.union(tasksCompleted)
                CheckAppStore.compareWobjectSets(setA: tasks, setB: appStore.tasks[listId], parentId: listId)
                let taskPromises = tasks.map { CheckAppStore.checkTaskConsistency(taskId: $0.id, appStore: appStore) }
                return when(fulfilled: taskPromises)
            }.then { _ in
                WAPI.get(WTaskPosition.self, listId: listId)
            }.done { taskPositions in
                CheckAppStore.compareWobjectSets(setA: taskPositions, setB: appStore.taskPositions[listId], parentId: listId)
        }
    }

    static func checkDataConsistency(appStore: AppData) {
        let expectation = XCTestExpectation(description: "Load test dump data")

        WAPI.getRoot()
            .then { (root: WRoot) -> Promise<Set<WUser>> in
                XCTAssertEqual(root, appStore.root, "root is not equal: \(root), \(appStore.root)")
                return WAPI.get(WUser.self)
            }.then { (users: Set<WUser>) -> Promise<Set<WList>> in
                CheckAppStore.compareWobjectSets(setA: users, setB: appStore.users)
                return WAPI.get(WList.self)
            }.then { (lists: Set<WList>) -> Promise<Void> in
                CheckAppStore.compareWobjectSets(setA: lists, setB: appStore.lists)
                let listPromises = lists.map { CheckAppStore.checkListConsistency(listId: $0.id, appStore: appStore)}
                return when(fulfilled: listPromises)
            }.then { (_) -> Promise<Set<WListPosition>> in
                return WAPI.get(WListPosition.self)
            }.then { (listPositions: Set<WListPosition>) -> Promise<Set<WReminder>> in
                CheckAppStore.compareWobjectSets(setA: listPositions, setB: appStore.listPositions)
                return WAPI.get(WReminder.self)
            }.then { (reminders: Set<WReminder>) -> Promise<Set<WFolder>> in
                CheckAppStore.compareWobjectSets(setA: reminders, setB: appStore.reminders)
                return WAPI.get(WFolder.self)
            }.then { (folders: Set<WFolder>) -> Promise<Set<WSetting>> in
                CheckAppStore.compareWobjectSets(setA: folders, setB: appStore.folders)
                return WAPI.get(WSetting.self)
            }.done { (settings: Set<WSetting>) -> Void in
                CheckAppStore.compareWobjectSets(setA: settings, setB: appStore.settings)
            }.ensure {
                expectation.fulfill()
            }.catch { error in
                XCTFail("Dump load error: \(error)")
        }
    }

}
