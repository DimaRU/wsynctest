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

    func testCreate() {
        pull(from: "25852-dump", appDataSync: appDataSync)

        let newTask = WTask(listId: 286646344, title: "Test create task", starred: false)
        appDataSync.add(created: newTask)
        XCTAssertEqual(appDataSync.requestQueue.count, 1, "Queue length must be 1")
        let expectation = XCTestExpectation(description: "Sync push")
        appDataSync.pushNext {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5000)
        XCTAssertEqual(appDataSync.requestQueue.count, 0, "Queue length must be 0")
        appDataSync.syncState = .idle
        pull(from: "25853-dump", appDataSync: appDataSync)
    }

}
