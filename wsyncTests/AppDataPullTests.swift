////
///  AppDataPullTests.swift
//


import XCTest
@testable import wsync

class AppDataPullTests: XCTestCase {
    var appDataSync = AppDataSync(appData: AppData(diskStore: nil))

    override func setUp() {
        super.setUp()
        let appData = AppData(diskStore: nil)
        appDataSync = AppDataSync(appData: appData)
    }


    func pull(from dump: String, appDataSync: AppDataSync) {
        let wdump = loadDump(for: type(of: self), resource: dump)
        WProvider.moya = WProvider.WDumpProvider(wdump: wdump)

        let expectation = XCTestExpectation(description: "Sync pull \(dump)")
        appDataSync.pull() {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        CheckAppStore.compareAppData(appData: appDataSync.appData, wdump: wdump)
    }

    func testPull1() {
        pull(from: "25830-dump", appDataSync: appDataSync)
    }
    func testPull2() {
        pull(from: "25833-dump", appDataSync: appDataSync)
    }
    func testPull3() {
        pull(from: "25835-dump", appDataSync: appDataSync)
    }
    func testPull4() {
        pull(from: "25837-dump", appDataSync: appDataSync)
    }

    func testPullByStep() {
        pull(from: "25830-dump", appDataSync: appDataSync)
        pull(from: "25833-dump", appDataSync: appDataSync)
        pull(from: "25835-dump", appDataSync: appDataSync)
        pull(from: "25837-dump", appDataSync: appDataSync)
    }

    func testPullThru() {
        pull(from: "25830-dump", appDataSync: appDataSync)
        pull(from: "25837-dump", appDataSync: appDataSync)
    }
}
