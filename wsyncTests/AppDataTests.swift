//
//  AppDataTests.swift
//  wsyncTests
//
//  Created by Dmitriy Borovikov on 19.05.2018.
//  Copyright © 2018 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import wsync

class AppDataTests: XCTestCase {

    var wdump: WDump!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "25830-dump", withExtension: "json") else {
            XCTFail("Missing file: 25830-dump.json")
            return
        }

        let json = try! Data(contentsOf: url)
        let decoder = WJSONAbleCoders.decoder

        wdump = try! decoder.decode(WDump.self, from: json)

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEquatable() {
        let root1 = WRoot(id: 1000, revision: 1111)
        let root2 = WRoot(id: 1000, revision: 1111)
        XCTAssertTrue(root1 ==== root2)
    }
    
    func testJsonLoaded() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(wdump.root.userId, 41027896)
        XCTAssertEqual(wdump.lists.count, 4)
    }
    
    func testSetGetLists() {
        let appData = AppData()
        let lists = Set<WList>(wdump.lists)
        
        appData.lists = lists
        XCTAssertEqual(appData.lists.count, 4, "bad appData list count")
        let listsNew = appData.lists
        XCTAssertEqual(lists, listsNew, "Lists not equal afet get/set")
        appData.lists = []
        XCTAssertEqual(appData.lists.count, 0, "Lists not removed")
    }
    
    func testSetGetTasks() {
        let appData = AppData()
        let tasks = Set<WTask>(wdump.tasks)
        
        appData.tasks[1] = tasks
        let tasksNew = appData.tasks[1]
        XCTAssertEqual(tasks, tasksNew, "tasks not equal afer get/set")
        appData.tasks[1] = []
        XCTAssertEqual(appData.tasks.dictionary.count, 0, "Tasks not removed")
    }
    
    func testUpdateNewWObjectSet() {
        let appData = AppData()
        let tasks = Set<WTask>(wdump.tasks)

        let updatedTask = tasks.first!
        let parentId = updatedTask.listId
        appData.tasks[parentId].update(with: updatedTask)
        let task = appData.tasks[parentId][updatedTask.id]!
        XCTAssertEqual(task, updatedTask, "tasks not equal after mutation")
    }

    func testUpdateWObjectSet() {
        let appData = AppData()
        let tasks = Set<WTask>(wdump.tasks)

        var updatedTask = tasks.first!
        let parentId = updatedTask.listId
        appData.tasks[parentId] = tasks
        let title = "Mutated tite"
        updatedTask.title = title
        appData.tasks[parentId].update(with: updatedTask)
        let task = appData.tasks[parentId][updatedTask.id]!
        XCTAssertEqual(task, updatedTask, "tasks not equal after mutation")
        XCTAssertEqual(task.title, title, "Title not modified")
    }
}
