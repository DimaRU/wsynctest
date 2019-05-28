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
        pull(from: "25866-dump", appDataSync: appDataSync)

        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")

        let newTask = appDataSync.makeWTask(listId: 286646344, title: "Test create task", starred: false)
        appDataSync.add(created: newTask)
        push(appDataSync: appDataSync)

        let newSubtask = appDataSync.makeWSubtask(taskId: 5051112471, title: "Test create task")
        appDataSync.add(created: newSubtask)
        push(appDataSync: appDataSync)

        guard var preModifiedTask = appDataSync.appData.tasks[286646344][5051112471] else {
            XCTFail("Task 5051112471 not exist")
            return
        }
        preModifiedTask.title = "Test create task modified"
        appDataSync.update(updated: preModifiedTask)
        push(appDataSync: appDataSync)

        guard let modifiedTask = appDataSync.appData.tasks[286646344][5051112471] else {
            XCTFail("Task 5051112471 not exist")
            return
        }
        appDataSync.delete(modifiedTask)
        push(appDataSync: appDataSync)

        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")
        pull(from: "25871-dump", appDataSync: appDataSync)
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

        var updatedList = appDataSync.appData.lists[list.id]!
        updatedList.title = "Test create list updated title"
        appDataSync.update(updated: updatedList)

        XCTAssertEqual(appDataSync.requestQueue.count, 9, "Queue length must be 9")
        for _ in 1...9 {
            push(appDataSync: appDataSync)
        }
        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")

        pull(from: "25936-dump", appDataSync: appDataSync)
    }
}
