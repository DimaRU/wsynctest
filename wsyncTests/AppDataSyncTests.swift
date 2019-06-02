////
///  AppDataSyncTests.swift
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

    func testDiff() {
        let appData = AppData()
        let appDataSync = AppDataSync(appData: appData)
        let (removed, changed) = appDataSync.diffWobjectSets(old: local, new: remote)
        XCTAssertEqual(removed, [1], "Incorrect removed ids")
        XCTAssertEqual(changed, [3,4], "Incorrect changed ids")
    }


}
