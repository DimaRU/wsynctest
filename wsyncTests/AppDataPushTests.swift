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

    func testPushCreate() {
        pull(from: "26359-dump", appDataSync: appDataSync)
        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")

        let bundle = Bundle(for: type(of: self))
        let wdump = loadDump(bundle: bundle, resource: "26361-dump")
        WProvider.moya = WProvider.WDumpProvider(wdump: wdump, bundle: bundle)

        appDataSync.add(created: appDataSync.makeWList(title: "Create test list"))
        push(appDataSync: appDataSync)
        guard let list = appDataSync.appData.lists[396217427] else {
            XCTFail("WList object not exist")
            return
        }

        appDataSync.add(created: appDataSync.makeWTask(listId: list.id, title: "Create test task"))
        push(appDataSync: appDataSync)
        guard let task = appDataSync.appData.tasks[list.id][5101339791] else {
            XCTFail("WTask object not exist")
            return
        }

        let subtask = appDataSync.makeWSubtask(taskId: task.id, title: "Create test subtask")
        appDataSync.add(created: subtask)
        push(appDataSync: appDataSync)

        let taskComment = appDataSync.makeWTaskComment(taskId: task.id, text: "Create test comment")
        appDataSync.add(created: taskComment)
        push(appDataSync: appDataSync)

        let date = "2019-06-09T21:10:08.537Z".dateFromISO8601!
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

        let wdump1 = loadDump(bundle: bundle, resource: "26369-dump")
        CheckAppStore.compareAppData(appData: appDataSync.appData, wdump: wdump1)
    }

    func testPushLocal() {
        pull(from: "26359-dump", appDataSync: appDataSync)

        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue length must be empty")

        let list = appDataSync.makeWList(title: "Create test list")
        appDataSync.add(created: list)

        let task = appDataSync.makeWTask(listId: list.id, title: "Create test task", starred: false)
        appDataSync.add(created: task)

        let subtask = appDataSync.makeWSubtask(taskId: task.id, title: "Create test subtask")
        appDataSync.add(created: subtask)

        let taskComment = appDataSync.makeWTaskComment(taskId: task.id, text: "Create test comment")
        appDataSync.add(created: taskComment)

        let date = "2019-06-09T21:10:08.537Z".dateFromISO8601!
        let reminder = appDataSync.makeWReminder(taskId: task.id, date: date)
        appDataSync.add(created: reminder)

        let note = appDataSync.makeWNote(taskId: task.id, content: "Create test note")
        appDataSync.add(created: note)

        let folder = appDataSync.makeWFolder(title: "Test create folder", listIds: [list.id])
        appDataSync.add(created: folder)

        let bundle = Bundle(for: type(of: self))
        let wdump = loadDump(bundle: bundle, resource: "26361-dump")
        WProvider.moya = WProvider.WDumpProvider(wdump: wdump, bundle: bundle)

        XCTAssertEqual(appDataSync.requestQueue.count, 7, "Wrong queue length")
        for _ in 1...7 {
            push(appDataSync: appDataSync)
        }

        XCTAssertTrue(appDataSync.requestQueue.isEmpty, "Queue must be empty")

        let wdump1 = loadDump(bundle: bundle, resource: "26369-dump")
        CheckAppStore.compareAppData(appData: appDataSync.appData, wdump: wdump1)
    }
}
