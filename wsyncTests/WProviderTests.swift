////
///  WProviderTests.swift
//

import XCTest
@testable import wsync

class WProviderTests: XCTestCase {
    func testWProviderLoad() {
        let wdump = loadDump(for: type(of: self), resource: "25830-dump")
        WProvider.moya = WProvider.WDumpProvider(wdump: wdump)
        let expectation = XCTestExpectation(description: "Fetch root")
        WAPI.getRoot()
            .done { root in
                XCTAssertEqual(root.revision, 25830, "Revision not equal 25830, \(root)")
            }.ensure {
                expectation.fulfill()
            }.catch { error in
                XCTFail("Root download error \(error)")
        }
    }

}
