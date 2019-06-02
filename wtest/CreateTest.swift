////
///  CreateTest.swift
//

import Foundation
import PromiseKit

struct CreateTest {
    private var directory: String
    private let dumpContent: DumpContentComapact

    init(directory: String) {
        self.directory = directory
        self.dumpContent = DumpContentComapact(directory: directory)
    }

    private func update<T: WObject>(from: T, to: T) -> Promise<T> {
        assert(from.id == to.id, "Update object id is't equal")
        let params = to.updateParams(from: from)
        return WAPI.update(T.self, id: from.id, params: params, requestId: UUID().uuidString.lowercased())
    }

    private func create<T: WObject & WCreatable>(from wobject: T) -> Promise<T> {
        let params = wobject.createParams()
        return WAPI.create(T.self, params: params, requestId: UUID().uuidString.lowercased())
    }

    private func dumpWObject<T: WObject>(prefix: String, object: T) {
        let fileName = "\(directory)\(prefix)\(String(describing: T.self))-\(object.id).json"
        try! Disk.save(object, to: Disk.Directory.developer, as: fileName)

    }

    func runTest() {
        var listId = -1
        var taskId = -1

            self.dumpContent.dumpPromise(comment: "Before create test")
            .then { _ -> Promise<WList> in
                let newlist = WList(id: -1, title: "Create test list")
                return self.create(from: newlist)
            }.then { list -> Promise<WTask> in
                listId = list.id
                self.dumpWObject(prefix: "create", object: list)
                let newTask = WTask(id: -1, listId: list.id, title: "Create test task")
                return self.dumpContent.dumpPromise(comment: "list created")
                    .then { self.create(from: newTask)
                }
            }.then { task -> Promise<WTaskPosition> in
                taskId = task.id
                self.dumpWObject(prefix: "create", object: task)
                let srcTaskPosition = WTaskPosition(storedSyncState: nil, id: listId, revision: 0, listId: listId, values: [])
                let taskPosition = WTaskPosition(storedSyncState: nil, id: listId, revision: 1, listId: listId, values: [task.id])
                return self.dumpContent.dumpPromise(comment: "task created")
                    .then { self.update(from: srcTaskPosition, to: taskPosition)
                }
            }.then { taskPosition -> Promise<WSubtask> in
                self.dumpWObject(prefix: "update", object: taskPosition)
                let subtask = WSubtask(id: -1, taskId: taskId, title: "Create test subtask")
                return self.dumpContent.dumpPromise(comment: "taskPostition updated")
                    .then { self.create(from: subtask)
                }
            }.then { subtask -> Promise<WSubtaskPosition> in
                self.dumpWObject(prefix: "create", object: subtask)
                let srcsubtaskPosition = WSubtaskPosition(storedSyncState: nil, id: taskId, revision: 0, taskId: taskId, values: [])
                let subtaskPosition = WSubtaskPosition(storedSyncState: nil, id: taskId, revision: 0, taskId: taskId, values: [subtask.id])
                return self.dumpContent.dumpPromise(comment: "subtask created")
                    .then { self.update(from: srcsubtaskPosition, to: subtaskPosition)
                }
            }.then { subtaskPosition -> Promise<WTaskComment> in
                self.dumpWObject(prefix: "update", object: subtaskPosition)
                let taskComment = WTaskComment(id: -1, taskId: taskId, text: "Create test comment")
                return self.dumpContent.dumpPromise(comment: "subtaskPostition updated")
                    .then { self.create(from: taskComment)
                }
            }.then { taskComment -> Promise<WReminder> in
                self.dumpWObject(prefix: "create", object: taskComment)
                let reminder = WReminder(id: -1, taskId: taskId, date: Date())
                return self.dumpContent.dumpPromise(comment: "task comment created")
                    .then { self.create(from: reminder)
                }
            }.then { reminder -> Promise<WFolder> in
                self.dumpWObject(prefix: "create", object: reminder)
                let folder = WFolder(id: -1, title: "Test create folder", listIds: [listId])
                return self.dumpContent.dumpPromise(comment: "reminder created")
                    .then { self.create(from: folder)
                }
            }.then { folder -> Promise<Void> in
                self.dumpWObject(prefix: "create", object: folder)
                return self.dumpContent.dumpPromise(comment: "folder created")
            }.then {
                WAPI.get(WList.self, id: listId)
            }.then { list -> Promise<WList> in
                var updatedList = list
                updatedList.title = "Test create list updated title"
                return self.update(from: list, to: updatedList)
            }.then { list -> Promise<Void> in
                self.dumpWObject(prefix: "update", object: list)
                return self.dumpContent.dumpPromise(comment: "list updated")
                    .then { WAPI.delete(WList.self, id: list.id, revision: list.revision)
                }
            }.then {
                self.dumpContent.dumpPromise(comment: "list deleted")
            }.catch{ error in
                log(error: error)
        }
    }
}
