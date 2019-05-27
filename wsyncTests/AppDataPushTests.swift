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

        XCTAssertEqual(appDataSync.requestQueue.count, 0, "Queue length must be 0")

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

        XCTAssertEqual(appDataSync.requestQueue.count, 0, "Queue length must be 0")
        pull(from: "25871-dump", appDataSync: appDataSync)
    }

    func testPushLocal() {
        pull(from: "25866-dump", appDataSync: appDataSync)

        XCTAssertEqual(appDataSync.requestQueue.count, 0, "Queue length must be 0")

        let newTask = appDataSync.makeWTask(listId: 286646344, title: "Test create task", starred: false)
        appDataSync.add(created: newTask)

        let newSubtask = appDataSync.makeWSubtask(taskId: newTask.id, title: "Test create task")
        appDataSync.add(created: newSubtask)

        var modifiedTask = newTask
        modifiedTask.title = "Test create task modified"
        appDataSync.update(updated: modifiedTask)

        push(appDataSync: appDataSync)
        push(appDataSync: appDataSync)
        push(appDataSync: appDataSync)

        XCTAssertEqual(appDataSync.requestQueue.count, 0, "Queue length must be 0")
        pull(from: "25869-dump", appDataSync: appDataSync)
    }
}
