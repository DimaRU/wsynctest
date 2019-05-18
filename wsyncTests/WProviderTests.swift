////
///  WProviderTests.swift
//

import XCTest
@testable import wsync

class WProviderTests: XCTestCase {
    func loadDump(resource: String) -> WDump {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "\(resource)", withExtension: "json") else {
            fatalError("Missing file: \(resource).json")
        }
        let json = try! Data(contentsOf: url)
        let decoder = WJSONAbleCoders.decoder
        do {
            return try decoder.decode(WDump.self, from: json)
        } catch {
            XCTFail(error.localizedDescription)
            return WDump()
        }
    }


    func testWProviderLoad() {
        let wdump = loadDump(resource: "25798-dump")
        WProvider.moya = WProvider.WDumpProvider(wdump: wdump)
        let expectation = XCTestExpectation(description: "Fetch root")
        WAPI.getRoot()
            .done { root in
                XCTAssertEqual(root.revision, 25798, "Revision not equal 25798, \(root)")
            }.ensure {
                expectation.fulfill()
            }.catch { error in
                XCTFail("Root download error \(error)")
        }
    }

    func testWProviderPull() {
        let wdump = loadDump(resource: "25798-dump")

        WProvider.moya = WProvider.WDumpProvider(wdump: wdump)
        let appData = AppData(diskStore: nil)
        let appDataSync = AppDataSync(appData: appData)
        let expectation = XCTestExpectation(description: "Sync pull")
        appDataSync.pull() {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        let expectation1 = XCTestExpectation(description: "Load test dump data")

        CheckAppStore.checkDataConsistency(appStore: appData, expectation: expectation1)
        wait(for: [expectation1], timeout: 5)
    }
}
