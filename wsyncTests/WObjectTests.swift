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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


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
        let diff = wobjectDiff(from: folder, to: folder1)
        XCTAssertTrue(diff.isEmpty, "Wobjects not equal:, \(diff)")

        folder1.title = "TitleNew"
        let diff1 = wobjectDiff(from: folder, to: folder1)
        XCTAssertFalse(diff1.isEmpty, "wobjectDiff must return difference")
        print(diff1)

    }

}
