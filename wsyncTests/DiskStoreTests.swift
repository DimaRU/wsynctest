//
//  DiskStoreTests.swift
//  wsyncTests
//
//  Created by Dmitriy Borovikov on 06.06.2018.
//  Copyright © 2018 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import wsync

class DiskStoreTests: XCTestCase {
    var wbackup: WBackup!
    var diskStore: DiskStore!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "TestBackup", withExtension: "json") else {
            XCTFail("Missing file: TestBackup")
            return
        }
        
        let json = try! Data(contentsOf: url)
        let decoder = WJSONAbleCoders.decoder

        wbackup = try! decoder.decode(WBackup.self, from: json)
        diskStore = DiskStore(filePath: "logs/testStore/", directory: .developer)

    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testJsonLoaded() {
        XCTAssertEqual(wbackup.user, 41027896)
        XCTAssertEqual(wbackup.data.lists.count, 4)
    }

    func testPersistSingle() {
        let root = WRoot(id: 1000, revision: 1111)
        diskStore.persist(root)
        diskStore.persistQueue.sync(flags: .barrier) {}
        if let rootNew: WRoot = diskStore.load(WRoot.self) {
            XCTAssertTrue(root ==== rootNew, "Retrived wobject is not valid")
        } else {
            XCTFail("Error load wobject")
        }
        
        XCTAssertTrue(diskStore.exists(WRoot.self), "wobject must exist")
        try? diskStore.delete(WRoot.self)
        XCTAssertFalse(diskStore.exists(WRoot.self), "wobject must deleted")
    }

    func testPersistSet() {
        let lists = Set<WList>(wbackup.data.lists)
        
        diskStore.persist(lists)
        diskStore.persistQueue.sync(flags: .barrier) {}
        let listsNew = diskStore.load([WList].self) ?? []
        XCTAssertTrue(lists ==== listsNew, "Retrived wobject is not valid")

        XCTAssertTrue(diskStore.exists(WList.self), "wobject must exist")
        try? diskStore.delete(WList.self)
        XCTAssertFalse(diskStore.exists(WList.self), "wobject must deleted")
    }

    func testPersistChildSet() {
        let tasks = Set<WTask>(wbackup.data.tasks)
        let parentId = tasks.first!.listId
        
        diskStore.persist(tasks, parentId: parentId)
        diskStore.persistQueue.sync(flags: .barrier) {}
        let tasksNew = diskStore.load([WTask].self, parentId: parentId) ?? []
        XCTAssertTrue(tasks ==== tasksNew, "Retrived wobject is not valid")
        
        XCTAssertTrue(diskStore.exists([WTask].self, parentId: parentId), "wobject must exist")
        try? diskStore.delete([WTask].self, parentId: parentId)
        XCTAssertFalse(diskStore.exists([WTask].self, parentId: parentId), "wobject must deleted")

    }
}
