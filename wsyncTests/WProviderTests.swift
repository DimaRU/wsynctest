////
///  WProviderTests.swift
//

import XCTest
@testable import wsync

class WProviderTests: XCTestCase {
    func testWProviderLoad() {
        let wdump = loadDump(bundle: Bundle(for: type(of: self)), resource: "25830-dump")
        WProvider.moya = WProvider.WDumpProvider(wdump: wdump, bundle: Bundle(for: type(of: self)))
        let expectation = XCTestExpectation(description: "Fetch root")
        WAPI.getRoot()
            .done { root in
                XCTAssertEqual(root.revision, 25830, "Revision not equal 25830, \(root)")
            }.then {
                WAPI.get(WList.self)
            }.done { lists in
                XCTAssertEqual(lists.count, 4, "List count must be 4")
            }.then {
                WAPI.get(WTask.self, id: 3858184298)
            }.done { task in
                XCTAssertTrue(task ==== wdump.tasks[3858184298]!, "Tasks must be equal")
            }.ensure {
                expectation.fulfill()
            }.catch { error in
                XCTFail("Root download error \(error)")
        }
    }

}
