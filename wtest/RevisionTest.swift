////
///  CreateTest.swift
//

import Foundation
import PromiseKit

class RevisionTest {
    private var directory: String = "logs/"
    private var dumpContent: DumpContentComapact!
    private var dump = WDump()

    enum DumpType {
        case create, update
    }

    init() {
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

    private func delete<T: WObject>(_ wobject: T) -> Promise<Void> {
        return WAPI.delete(T.self, id: wobject.id, revision: wobject.revision)
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

    func runCreateTest() -> Promise<(folderId: Int, listId: Int, taskId: Int)> {
        var listId = -1
        var taskId = -1
        var folderId = -1

            return self.dumpAll(comment: "Before create test")
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
            }.then { _ -> Promise<WFile> in
                let uploadService = WUploadService()
                let data = "Test content".data(using: .utf8)!
                return uploadService.upload(data, filename: "TestFile.txt", for: taskId)
            }.then { file -> Promise<Void> in
                self.dumpWObject(dumpType: .create, object: file)
                return self.dumpAll(comment: "file created")
            }.then {
                self.create(from: WFolder(id: -1, title: "Test create folder", listIds: [listId]))
            }.then { folder -> Promise<Void> in
                folderId = folder.id
                self.dumpWObject(dumpType: .create, object: folder)
                return self.dumpAll(comment: "folder created")
            }.then {
                return Promise.value((folderId, listId, taskId))
        }
    }

    func runUpdateTest(folderId: Int, listId: Int, taskId: Int) -> Promise<Void> {

        return self.dumpAll(comment: "Before update test")
            .then { _ -> Promise<WFolder> in
                let folder = self.dump.folders[folderId]!
                var newFolder = folder
                newFolder.title = "Test create folder updated"
                return self.update(from: folder, to: newFolder)
            }.then { object -> Promise<Void> in
                self.dumpWObject(dumpType: .update, object: object)
                return self.dumpAll(comment: "Folder updated")
            }.then { _ -> Promise<WList> in
                let list = self.dump.lists[listId]!
                var updatedList = list
                updatedList.title = "Test create list updated title"
                return self.update(from: list, to: updatedList)
            }.then { object -> Promise<Void> in
                self.dumpWObject(dumpType: .update, object: object)
                return self.dumpAll(comment: "list updated")
            }.then { _ -> Promise<WListPosition> in
                let listPosition = self.dump.listPositions.first!
                var newListPosition = listPosition
                var values = listPosition.values.filter{ $0 != listId}
                values.insert(listId, at: 0)
                newListPosition.values = values
                return self.update(from: listPosition, to: newListPosition)
            }.then { object -> Promise<Void> in
                self.dumpWObject(dumpType: .update, object: object)
                return self.dumpAll(comment: "list position updated")
            }.then { _ -> Promise<WTask> in
                let task = self.dump.tasks[taskId]!
                var newTask = task
                newTask.title = "Test create task modified"
                return self.update(from: task, to: newTask)
            }.then { object -> Promise<Void> in
                self.dumpWObject(dumpType: .update, object: object)
                return self.dumpAll(comment: "task title updated")
            }.then { _ -> Promise<WTaskPosition> in
                var taskPosition = self.dump.taskPositions[listId]!
                var newTaskPosition = taskPosition
                taskPosition.values = []
                newTaskPosition.values  = [taskId]
                return self.update(from: taskPosition, to: newTaskPosition)
            }.then { object -> Promise<Void> in
                self.dumpWObject(dumpType: .update, object: object)
                return self.dumpAll(comment: "task position updated")
            }.then { _ -> Promise<WNote> in
                let note = self.dump.notes.first(where: { $0.taskId == taskId})!
                var newNote = note
                newNote.content = "Modified task note"
                return self.update(from: note, to: newNote)
            }.then { object -> Promise<Void> in
                self.dumpWObject(dumpType: .update, object: object)
                return self.dumpAll(comment: "task note updated")
            }.then { _ -> Promise<WReminder> in
                let reminder = self.dump.reminders.first(where: { $0.taskId == taskId })!
                var newReminder = reminder
                newReminder.date = Date()
                return self.update(from: reminder, to: newReminder)
            }.then { object -> Promise<Void> in
                self.dumpWObject(dumpType: .update, object: object)
                return self.dumpAll(comment: "reminder updated")
            }.then { _ -> Promise<WSubtask> in
                let subtask = self.dump.subtasks.first(where: { $0.taskId == taskId })!
                var newSubtask = subtask
                newSubtask.title = "Subtask title updated"
                return self.update(from: subtask, to: newSubtask)
            }.then { object -> Promise<Void> in
                self.dumpWObject(dumpType: .update, object: object)
                return self.dumpAll(comment: "subtask updated")
            }.then { _ -> Promise<WSubtaskPosition> in
                var subtaskPosition = self.dump.subtaskPositions[taskId]!
                var newSubtaskPosition = subtaskPosition
                subtaskPosition.values = []
                let subtask = self.dump.subtasks.first(where: { $0.taskId == taskId })!
                newSubtaskPosition.values = [subtask.id]
                return self.update(from: subtaskPosition, to: newSubtaskPosition)
            }.then { object -> Promise<Void> in
                self.dumpWObject(dumpType: .update, object: object)
                return self.dumpAll(comment: "subtask position updated")
            }.then { _ -> Promise<WSetting> in
                let setting = self.dump.settings.first(where: { $0.key == .soundCheckoffEnabled })!
                var newSetting = setting
                newSetting.value = newSetting.value == "true" ? "false" : "true"
                return self.update(from: setting, to: newSetting)
            }.then { object -> Promise<Void> in
                self.dumpWObject(dumpType: .update, object: object)
                return self.dumpAll(comment: "setting updated")
//            }.then { _ -> Promise<Void> in
//                let list = self.dump.lists[listId]!
//                return WAPI.delete(WList.self, id: list.id, revision: list.revision)
//            }.then {
//                self.dumpAll(comment: "list deleted")
        }
    }

    func runDeleteTest(folderId: Int, listId: Int, taskId: Int) -> Promise<Void>  {

        return self.dumpAll(comment: "Before delete test")
            .then {
                self.delete(self.dump.taskComments.first(where: { $0.taskId == taskId })!)
            }.then {
                return self.dumpAll(comment: "Task comment deleted")
            }.then {
                self.delete(self.dump.reminders.first(where: { $0.taskId == taskId })!)
            }.then {
                return self.dumpAll(comment: "Reminder deleted")
            }.then {
                self.delete(self.dump.notes.first(where: { $0.taskId == taskId })!)
            }.then {
                return self.dumpAll(comment: "Note deleted")
            }.then {
                self.delete(self.dump.files.first(where: { $0.taskId == taskId })!)
            }.then {
                return self.dumpAll(comment: "File deleted")
            }.then {
                self.delete(self.dump.subtasks.first(where: { $0.taskId == taskId })!)
            }.then {
                return self.dumpAll(comment: "Subtask deleted")
            }.then {
                self.delete(self.dump.tasks[taskId]!)
            }.then {
                return self.dumpAll(comment: "Task deleted")
            }.then {
                self.delete(self.dump.folders[folderId]!)
            }.then {
                return self.dumpAll(comment: "Folder deleted")
            }.then {
                self.delete(self.dump.lists[listId]!)
            }.then {
                return self.dumpAll(comment: "List deleted")
        }
    }


    func runTests(directory: String) {
        var ids: (folderId: Int, listId: Int, taskId: Int) = (-1, -1, -1)
        self.directory = directory + "create/"
        log("\nCreate test\n")
        dumpContent = DumpContentComapact(directory: self.directory)
        runCreateTest()
            .then { (folderId, listId, taskId) -> Promise<Void> in
                ids = (folderId, listId, taskId)
                log("\nUpdate test\n")
                self.directory = directory + "update/"
                self.dumpContent = DumpContentComapact(directory: self.directory)
                return self.runUpdateTest(folderId: folderId, listId: listId, taskId: taskId)
            }.then { _ -> Promise<Void> in
                log("\nDelete test\n")
                self.directory = directory + "delete/"
                self.dumpContent = DumpContentComapact(directory: self.directory)
                return self.runDeleteTest(folderId: ids.folderId, listId: ids.listId, taskId: ids.taskId)
            }.catch { error in
                log(error: error)
        }
    }
}
