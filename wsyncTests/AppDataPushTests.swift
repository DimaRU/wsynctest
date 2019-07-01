////
///  AppDataPushTests.swift
//

import XCTest
@testable import wsync

class AppDataPushTests: XCTestCase {
    let bundle = Bundle(for: AppDataPushTests.self)
    var appDataSync = AppDataSync(appData: AppData(diskStore: nil))

    override func setUp() {
        super.setUp()
        let appData = AppData(diskStore: nil)
        appDataSync = AppDataSync(appData: appData)
    }

    func pull(from dump: String, appDataSync: AppDataSync) {
        let wdump = loadDump(bundle: bundle, resource: dump)
        WProvider.moya = WProvider.WDumpProvider(wdump: wdump, bundle: bundle)

        let expectation = XCTestExpectation(description: "Sync push \(dump)")
        appDataSync.pull() {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5000)
        CheckAppStore.compareAppData(appData: appDataSync.appData, wdump: wdump)
    }

    func push(appDataSync: AppDataSync) {
        let queueCount = appDataSync.requestQueue.count
        let expectation = XCTestExpectation(description: "Sync push")
        appDataSync.pushNext {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5000)
        appDataSync.syncState = .idle
        XCTAssertEqual(appDataSync.requestQueue.count, queueCount - 1, "Queue length must be \(queueCount - 1) ")
    }

    func testPushCreate() {
        pull(from: "26439-dump", appDataSync: appDataSync)
        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")

        let wdump = loadDump(bundle: bundle, resource: "26441-dump")
        WProvider.moya = WProvider.WDumpProvider(wdump: wdump, bundle: bundle)

        appDataSync.add(created: appDataSync.makeWList(title: "Create test list"))
        push(appDataSync: appDataSync)
        guard let list = appDataSync.appData.lists[396563172] else {
            XCTFail("WList object not exist")
            return
        }

        appDataSync.add(created: appDataSync.makeWTask(listId: list.id, title: "Create test task"))
        push(appDataSync: appDataSync)
        guard let task = appDataSync.appData.tasks[list.id][5112132519] else {
            XCTFail("WTask object not exist")
            return
        }

        let subtask = appDataSync.makeWSubtask(taskId: task.id, title: "Create test subtask")
        appDataSync.add(created: subtask)
        push(appDataSync: appDataSync)

        let taskComment = appDataSync.makeWTaskComment(taskId: task.id, text: "Create test comment")
        appDataSync.add(created: taskComment)
        push(appDataSync: appDataSync)

        let date = "2019-06-13T09:58:58.019Z".dateFromISO8601!
        let reminder = appDataSync.makeWReminder(taskId: task.id, date: date)
        appDataSync.add(created: reminder)
        push(appDataSync: appDataSync)

        let note = appDataSync.makeWNote(taskId: task.id, content: "Create test note")
        appDataSync.add(created: note)
        push(appDataSync: appDataSync)

        let folder = appDataSync.makeWFolder(title: "Test create folder", listIds: [list.id])
        appDataSync.add(created: folder)
        push(appDataSync: appDataSync)

        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue must be empty")

        let wdump1 = loadDump(bundle: bundle, resource: "26449-dump")
        CheckAppStore.compareAppData(appData: appDataSync.appData, wdump: wdump1)
    }

    func testPushLocal() {
        pull(from: "26439-dump", appDataSync: appDataSync)

        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")

        let list = appDataSync.makeWList(title: "Create test list")
        appDataSync.add(created: list)

        let task = appDataSync.makeWTask(listId: list.id, title: "Create test task", starred: false)
        appDataSync.add(created: task)

        let subtask = appDataSync.makeWSubtask(taskId: task.id, title: "Create test subtask")
        appDataSync.add(created: subtask)

        let taskComment = appDataSync.makeWTaskComment(taskId: task.id, text: "Create test comment")
        appDataSync.add(created: taskComment)

        let date = "2019-06-13T09:58:58.019Z".dateFromISO8601!
        let reminder = appDataSync.makeWReminder(taskId: task.id, date: date)
        appDataSync.add(created: reminder)

        let note = appDataSync.makeWNote(taskId: task.id, content: "Create test note")
        appDataSync.add(created: note)

        let folder = appDataSync.makeWFolder(title: "Test create folder", listIds: [list.id])
        appDataSync.add(created: folder)

        let wdump = loadDump(bundle: bundle, resource: "26441-dump")
        WProvider.moya = WProvider.WDumpProvider(wdump: wdump, bundle: bundle)

        XCTAssertEqual(appDataSync.requestQueue.count, 7, "Wrong queue length")
        for _ in 1...7 {
            push(appDataSync: appDataSync)
        }

        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue must be empty")

        let wdump1 = loadDump(bundle: bundle, resource: "26449-dump")
        CheckAppStore.compareAppData(appData: appDataSync.appData, wdump: wdump1)
    }

    func testPushUpdateLocal() {
        pull(from: "26449-dump", appDataSync: appDataSync)
        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")

        let listId = 396563172
        let taskId = 5112132519
        let folderId = 13781081

        var folder = appDataSync.appData.folders[folderId]!
        folder.title = "Test create folder updated"
        appDataSync.update(updated: folder)

        var list = appDataSync.appData.lists[listId]!
        list.title = "Test create list updated title"
        appDataSync.update(updated: list)

        var listPosition = appDataSync.appData.listPositions.first!
        var values = listPosition.values.filter{ $0 != listId}
        values.insert(listId, at: 0)
        listPosition.values = values
        appDataSync.update(updated: listPosition)

        var task = appDataSync.appData.tasks[listId][taskId]!
        task.title = "Test create task modified"
        appDataSync.update(updated: task)

        var taskPosition = appDataSync.appData.taskPositions[listId].first!
        taskPosition.values = [taskId]
        appDataSync.update(updated: taskPosition)

        var note = appDataSync.appData.notes[taskId].first!
        note.content = "Modified task note"
        appDataSync.update(updated: note)

        var reminder = appDataSync.appData.reminders.first(where: { $0.taskId == taskId })!
        let date = "2019-06-13T09:59:43.385Z".dateFromISO8601!
        reminder.date = date
        appDataSync.update(updated: reminder)

        var subtask = appDataSync.appData.subtasks[taskId].first!
        subtask.title = "Subtask title updated"
        appDataSync.update(updated: subtask)

        var subtaskPosition = appDataSync.appData.subtaskPositions[taskId].first!
        subtaskPosition.values = [subtask.id]
        appDataSync.update(updated: subtaskPosition)

        var setting = appDataSync.appData.settings.first(where: { $0.key == .soundCheckoffEnabled })!
        setting.value = setting.value == "true" ? "false" : "true"
        appDataSync.update(updated: setting)

        XCTAssertEqual(appDataSync.requestQueue.count, 10, "Wrong queue length")
        for _ in 1...10 {
            push(appDataSync: appDataSync)
        }

        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue must be empty")

        let wdump1 = loadDump(bundle: bundle, resource: "26460-dump")
        CheckAppStore.compareAppData(appData: appDataSync.appData, wdump: wdump1)
    }

    func testPushDeleteLocal() {
        pull(from: "26460-dump", appDataSync: appDataSync)
        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")

        let listId = 396563172
        let taskId = 5112132519
        let folderId = 13781081

        let taskComment = appDataSync.appData.taskComments[taskId].first!
        appDataSync.delete(taskComment)

        let note = appDataSync.appData.notes[taskId].first!
        appDataSync.delete(note)

        let reminder = appDataSync.appData.reminders.first(where: { $0.taskId == taskId })!
        appDataSync.delete(reminder)

        let subtask = appDataSync.appData.subtasks[taskId].first!
        appDataSync.delete(subtask)

        let task = appDataSync.appData.tasks[listId][taskId]!
        appDataSync.delete(task)

        let folder = appDataSync.appData.folders[folderId]!
        appDataSync.delete(folder)

        let list = appDataSync.appData.lists[listId]!
        appDataSync.delete(list)

        XCTAssertEqual(appDataSync.requestQueue.count, 7, "Wrong queue length")
        for _ in 1...7 {
            push(appDataSync: appDataSync)
        }

        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue must be empty")

        let wdump1 = loadDump(bundle: bundle, resource: "26470-dump")
        CheckAppStore.compareAppData(appData: appDataSync.appData, wdump: wdump1)
    }

    func testPushRecoveryCreate() {
        let uuidDict: [MappingType: String] = [
            MappingType.List: "58a950a2-1197-481c-9870-60e35ffc8495",
            MappingType.Task: "51901f58-04ab-48c6-8e59-c3eb4cc41cc1",
            MappingType.Subtask: "380e1703-6434-4baf-96c1-7bccbc10d944",
            MappingType.TaskComment: "1d442427-0dbd-4c5f-b1ef-59f60a50c23d",
            MappingType.Reminder: "668019c6-1890-403f-8359-0d2c2f894340",
            MappingType.Note: "cd44a505-96da-4081-846b-10a7c5572942",
            MappingType.Folder: "ed25bfce-e92b-4b56-8d33-e10ba33a38c0"
        ]

        let dumpDict: [MappingType: String] = [
            MappingType.List: "26441-dump",
            MappingType.Task: "26442-dump",
            MappingType.Subtask: "26443-dump",
            MappingType.TaskComment: "26445-dump",
            MappingType.Reminder: "26447-dump",
            MappingType.Note: "26448-dump",
            MappingType.Folder: "26449-dump"
        ]

        pull(from: "26439-dump", appDataSync: appDataSync)

        let list = appDataSync.makeWList(title: "Create test list")
        appDataSync.add(created: list)

        let task = appDataSync.makeWTask(listId: list.id, title: "Create test task", starred: false)
        appDataSync.add(created: task)

        let subtask = appDataSync.makeWSubtask(taskId: task.id, title: "Create test subtask")
        appDataSync.add(created: subtask)

        let taskComment = appDataSync.makeWTaskComment(taskId: task.id, text: "Create test comment")
        appDataSync.add(created: taskComment)

        let date = "2019-06-13T09:58:58.019Z".dateFromISO8601!
        let reminder = appDataSync.makeWReminder(taskId: task.id, date: date)
        appDataSync.add(created: reminder)

        let note = appDataSync.makeWNote(taskId: task.id, content: "Create test note")
        appDataSync.add(created: note)

        let folder = appDataSync.makeWFolder(title: "Test create folder", listIds: [list.id])
        appDataSync.add(created: folder)

        XCTAssertEqual(appDataSync.requestQueue.count, 7, "Wrong queue length")
        for _ in 1...7 {
            var request = appDataSync.requestQueue.front!
            request.uuid = uuidDict[request.type]!
            appDataSync.requestQueue.replaceFirst(request)
            let dumpName = dumpDict[request.type]!
            let wdump = loadDump(bundle: bundle, resource: dumpName)
            WProvider.moya = WProvider.WDumpProvider(wdump: wdump, bundle: bundle, code: 422)

            push(appDataSync: appDataSync)
        }

        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue must be empty")

        let wdump1 = loadDump(bundle: bundle, resource: "26449-dump")
        CheckAppStore.compareAppData(appData: appDataSync.appData, wdump: wdump1)
    }

    func testUpdateCollision() {
        pull(from: "26492-dump", appDataSync: appDataSync)
        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")

        var task = appDataSync.appData.tasks.getObject(by: 5167653628)!
        task.starred = true
        appDataSync.update(updated: task)

        let wdump = loadDump(bundle: bundle, resource: "26493-dump")
        WProvider.moya = WProvider.WDumpProvider(wdump: wdump, bundle: bundle)

        push(appDataSync: appDataSync)

        let wdump1 = loadDump(bundle: bundle, resource: "26494-dump")
        CheckAppStore.compareAppData(appData: appDataSync.appData, wdump: wdump1)

    }
}
