//
//  WObjectTests.swift
//  wsyncTests
//
//  Created by Dmitriy Borovikov on 11/05/2019.
//  Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import wsync

class WObjectTests: XCTestCase {

    func testwobjectDiff() {
        let folder = WFolder(storedSyncState: nil,
                             id: 1,
                             revision: 2,
                             createdByRequestId: nil,
                             title: "Title",
                             listIds: [],
                             userId: 1,
                             createdAt: nil,
                             createdById: nil,
                             updatedAt: nil)
        var folder1 = folder
        let diff = folder1.updateParams(from: folder)
        XCTAssertTrue(diff.isEmpty, "Wobjects not equal:, \(diff)")

        folder1.title = "TitleNew"
        let params = folder1.updateParams(from: folder)
        XCTAssertEqual(params.count, 2, "Invalid params: \(params)")
        XCTAssertTrue(params["revision"] as! Int == 2, "Invalid params: \(params)")
        XCTAssertTrue(params["title"] as! String == "TitleNew", "Invalid params: \(params)")

    }

    func testWCreate() {
        let folder = WFolder(storedSyncState: nil,
                             id: 1,
                             revision: 2,
                             createdByRequestId: nil,
                             title: "Title",
                             listIds: [1,2],
                             userId: 1,
                             createdAt: nil,
                             createdById: nil,
                             updatedAt: nil)

        let params = folder.createParams()
        XCTAssertEqual(params.count, 2, "Invalid params: \(params)")
        XCTAssertTrue(params["list_ids"] as! Array<Int> == [1,2], "Invalid params: \(params)")
        XCTAssertTrue(params["title"] as! String == "Title", "Invalid params: \(params)")
    }
}
