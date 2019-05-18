////
///  AppDataPullTests.swift
//


import XCTest
@testable import wsync

class AppDataPullTests: XCTestCase {

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
        let appData = AppData(diskStore: nil)
        let appDataSync = AppDataSync(appData: appData)

        pull(from: "25798-dump", appDataSync: appDataSync)
        pull(from: "25824-dump", appDataSync: appDataSync)
    }

}
