////
///  CreateTest.swift
//


import Foundation
import PromiseKit

struct createTest {

    let dumpContent = DumpContentComapact()

    func update<T: WObject>(from: T, to: T) -> Promise<T> {
        assert(from.id == to.id, "Update object id is't equal")
        let params = to.updateParams(from: from)
        return WAPI.update(T.self, id: from.id, params: params, requestId: UUID().uuidString.lowercased())
    }

    func create<T: WObject & WCreatable>(from wobject: T) -> Promise<T> {
        let params = wobject.createParams()
        return WAPI.create(T.self, params: params, requestId: UUID().uuidString.lowercased())
    }

    func dumpWObject<T: WObject>(prefix: String, object: T) {

    }

    func test() {
        var listId = -1
        var taskId = -1
        var createdList: WList?

        let newlist = WList(id: -1, title: "Create test list")
        create(from: newlist)
            .then { list -> Promise<WTask> in
                createdList = list
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
            }.then { folder -> Promise<WList> in
                self.dumpWObject(prefix: "create", object: folder)
                var updatedList = createdList!
                updatedList.title = "Test create list updated title"
                return self.dumpContent.dumpPromise(comment: "folder created")
                    .then { self.update(from: createdList!, to: updatedList)
                }
            }.then { updatedList -> Promise<Void> in
                self.dumpWObject(prefix: "update", object: updatedList)
                return self.dumpContent.dumpPromise(comment: "list updated")
                    .then { WAPI.delete(WList.self, id: updatedList.id, revision: updatedList.revision)
                }
            }.catch{
                print($0)
        }
    }
}
