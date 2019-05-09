//
//  AppDataSyncTests.swift
//  wsyncTests
//
//  Created by Dmitriy Borovikov on 28.05.2018.
//  Copyright © 2018 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import wsync

class AppDataSyncTests: XCTestCase {
    let local: Set<WListPosition> = [
        WListPosition(storedSyncState: .synced, id: 1, revision: 1, userId: 1, values: []),
        WListPosition(storedSyncState: .synced, id: 2, revision: 1, userId: 1, values: []),
        WListPosition(storedSyncState: .synced, id: 3, revision: 1, userId: 1, values: [])
    ]

    let remote: Set<WListPosition> = [
        WListPosition(storedSyncState: .synced, id: 2, revision: 1, userId: 1, values: []),
        WListPosition(storedSyncState: .synced, id: 3, revision: 2, userId: 1, values: []),
        WListPosition(storedSyncState: .synced, id: 4, revision: 1, userId: 1, values: [])
    ]


    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDiff() {
        let appData = AppData()
        let appDataSync = AppDataSync(appData: appData)
        let (removed, changed) = appDataSync.diffWobjectSets(old: local, new: remote)
        XCTAssertEqual(removed, [1], "Incorrect removed ids")
        XCTAssertEqual(changed, [3,4], "Incorrect changed ids")
    }


}
