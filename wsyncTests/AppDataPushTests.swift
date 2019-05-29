////
///  AppDataPushTests.swift
//


import XCTest
@testable import wsync

class AppDataPushTests: XCTestCase {
    var appDataSync = AppDataSync(appData: AppData(diskStore: nil))

    override func setUp() {
        super.setUp()
        let appData = AppData(diskStore: nil)
        appDataSync = AppDataSync(appData: appData)
    }

    func pull(from dump: String, appDataSync: AppDataSync) {
        let bundle = Bundle(for: type(of: self))
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

    func testPush() {
        pull(from: "25927-dump", appDataSync: appDataSync)
        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")

        appDataSync.add(created: appDataSync.makeWList(title: "Create test list"))
        push(appDataSync: appDataSync)
        guard let list = appDataSync.appData.lists[395139509] else {
            XCTFail("WList object not exist")
            return
        }

        appDataSync.add(created: appDataSync.makeWTask(listId: list.id, title: "Create test task"))
        push(appDataSync: appDataSync)
        guard let task = appDataSync.appData.tasks[list.id][5063637365] else {
            XCTFail("WTask object not exist")
            return
        }

        var taskPosition = appDataSync.appData.taskPositions[list.id].first!
        taskPosition.values = [task.id]
        appDataSync.update(updated: taskPosition)
        push(appDataSync: appDataSync)

        let subtask = appDataSync.makeWSubtask(taskId: task.id, title: "Create test subtask")
        appDataSync.add(created: subtask)
        push(appDataSync: appDataSync)

        var subtaskPosition = appDataSync.appData.subtaskPositions[task.id].first!
        subtaskPosition.values = [subtask.id]
        appDataSync.update(updated: subtaskPosition)
        push(appDataSync: appDataSync)

        let taskComment = appDataSync.makeWTaskComment(taskId: task.id, text: "Create test comment")
        appDataSync.add(created: taskComment)
        push(appDataSync: appDataSync)

        let date = "2019-05-28T21:03:34.249Z".dateFromISO8601!
        let reminder = appDataSync.makeWReminder(taskId: task.id, date: date)
        appDataSync.add(created: reminder)
        push(appDataSync: appDataSync)

        let folder = appDataSync.makeWFolder(title: "Test create folder", listIds: [list.id])
        appDataSync.add(created: folder)
        push(appDataSync: appDataSync)

        var updatedList = appDataSync.appData.lists[list.id]!
        updatedList.title = "Test create list updated title"
        appDataSync.update(updated: updatedList)
        push(appDataSync: appDataSync)

        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")

        pull(from: "25936-dump", appDataSync: appDataSync)
    }

    func testPushLocal() {
        pull(from: "25927-dump", appDataSync: appDataSync)

        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")

        let list = appDataSync.makeWList(title: "Create test list")
        appDataSync.add(created: list)

        let task = appDataSync.makeWTask(listId: list.id, title: "Create test task", starred: false)
        appDataSync.add(created: task)

        var taskPosition = appDataSync.appData.taskPositions[list.id].first!
        taskPosition.values = [task.id]
        appDataSync.update(updated: taskPosition)

        let subtask = appDataSync.makeWSubtask(taskId: task.id, title: "Create test subtask")
        appDataSync.add(created: subtask)

        var subtaskPosition = appDataSync.appData.subtaskPositions[task.id].first!
        subtaskPosition.values = [subtask.id]
        appDataSync.update(updated: subtaskPosition)

        let taskComment = appDataSync.makeWTaskComment(taskId: task.id, text: "Create test comment")
        appDataSync.add(created: taskComment)

        let date = "2019-05-28T21:03:34.249Z".dateFromISO8601!
        let reminder = appDataSync.makeWReminder(taskId: task.id, date: date)
        appDataSync.add(created: reminder)

        let folder = appDataSync.makeWFolder(title: "Test create folder", listIds: [list.id])
        appDataSync.add(created: folder)

//        var updatedList = appDataSync.appData.lists[list.id]!
//        updatedList.title = "Test create list updated title"
//        appDataSync.update(updated: updatedList)

        XCTAssertEqual(appDataSync.requestQueue.count, 8, "Wrong queue length")
        for i in 1...8 {
            print(i)
            push(appDataSync: appDataSync)
        }
        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")

        pull(from: "25936-dump", appDataSync: appDataSync)
    }
}
