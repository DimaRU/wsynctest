////
///  CreateTest.swift
//

import Foundation
import PromiseKit

class CreateTest {
    private var directory: String
    private let dumpContent: DumpContentComapact
    private var dump = WDump()

    enum DumpType {
        case create, update
    }

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

    private func dumpWObject<T: WObject>(dumpType: DumpType, object: T) {
        let fileName: String
        switch dumpType {
        case .create:
            fileName = "\(directory)create\(String(describing: T.self)).json"
        case .update:
            fileName = "\(directory)update\(String(describing: T.self))-\(object.id)-\(object.revision).json"
        }
        try! Disk.save(object, to: Disk.Directory.developer, as: fileName)
    }

    private func dumpAll(comment: String) -> Promise<Void> {
        return after(seconds: 1.1)
            .then {
                self.dumpContent.dumpPromise(comment: comment)
            }.done { dump in
                self.dump = dump
        }
    }

    func runTest() {
        var listId = -1
        var taskId = -1

            self.dumpAll(comment: "Before create test")
            .then { _ -> Promise<WList> in
                self.create(from: WList(id: -1, title: "Create test list"))
            }.then { list -> Promise<Void> in
                listId = list.id
                self.dumpWObject(dumpType: .create, object: list)
                return self.dumpAll(comment: "list created")
            }.then {
                self.create(from: WTask(id: -1, listId: listId, title: "Create test task"))
            }.then { task -> Promise<Void> in
                taskId = task.id
                self.dumpWObject(dumpType: .create, object: task)
                return self.dumpAll(comment: "task created")
            }.then {
                self.create(from: WSubtask(id: -1, taskId: taskId, title: "Create test subtask"))
            }.then { subtask -> Promise<Void> in
                self.dumpWObject(dumpType: .create, object: subtask)
                return self.dumpAll(comment: "subtask created")
            }.then {
                self.create(from: WTaskComment(id: -1, taskId: taskId, text: "Create test comment"))
            }.then { taskComment -> Promise<Void> in
                self.dumpWObject(dumpType: .create, object: taskComment)
                return self.dumpAll(comment: "task comment created")
            }.then {
                self.create(from: WReminder(id: -1, taskId: taskId, date: Date()))
            }.then { reminder -> Promise<Void> in
                self.dumpWObject(dumpType: .create, object: reminder)
                return self.dumpAll(comment: "reminder created")
            }.then {
                self.create(from: WNote(id: -1, taskId: taskId, content: "Create test note"))
            }.then { note -> Promise<Void> in
                self.dumpWObject(dumpType: .create, object: note)
                return self.dumpAll(comment: "note created")
            }.then {
                self.create(from: WFolder(id: -1, title: "Test create folder", listIds: [listId]))
            }.then { folder -> Promise<Void> in
                self.dumpWObject(dumpType: .create, object: folder)
                return self.dumpAll(comment: "folder created")
            }.then { _ -> Promise<Void> in
                let list = self.dump.lists[listId]!
                return WAPI.delete(WList.self, id: list.id, revision: list.revision)
            }.then {
                self.dumpAll(comment: "list deleted")
            }.catch{ error in
                log(error: error)
        }
    }
}
