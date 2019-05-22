////
///  WRequestTests.swift
//

import XCTest
@testable import wsync

class WRequestTests: XCTestCase {
    var wdump: WDump!
    var diskStore: DiskStore!

    override func setUp() {
        wdump = loadDump(for: type(of: self), resource: "25830-dump")
        diskStore = DiskStore(filePath: "logs/testStore/", directory: .developer)
    }

    func testModify() {
        let task = wdump.tasks.first!

        let request = WRequest.modify(object: task, modified: task)
        let encoder = WJSONAbleCoders.encoder
        let decoder = WJSONAbleCoders.decoder
        do {
            let data = try encoder.encode(request)
            print(String(data: data, encoding: .utf8)!)
            let _ = try decoder.decode(WRequest.self, from: data)
        } catch {
            XCTFail("WRequest encode/decode fail: \(error)")
        }
    }

    func testCreate() {
        let list = wdump.lists.first!

        let request = WRequest.create(object: list)
        let encoder = WJSONAbleCoders.encoder
        let decoder = WJSONAbleCoders.decoder
        do {
            let data = try encoder.encode(request)
            print(String(data: data, encoding: .utf8)!)
            let _ = try decoder.decode(WRequest.self, from: data)
        } catch {
            XCTFail("WRequest encode/decode fail: \(error)")
        }
    }

    func testDelete() {
        let subtask = wdump.subtasks.first!

        let request = WRequest.delete(object: subtask)
        let encoder = WJSONAbleCoders.encoder
        let decoder = WJSONAbleCoders.decoder
        do {
            let data = try encoder.encode(request)
            print(String(data: data, encoding: .utf8)!)
            let _ = try decoder.decode(WRequest.self, from: data)
        } catch {
            XCTFail("WRequest encode/decode fail: \(error)")
        }
    }

    func testQueue() {
        try? diskStore.delete(WRequest.self)
        var queue: Queue<WRequest>? = Queue<WRequest>(diskStore)
        let subtask = wdump.subtasks.first!
        let requestDelete = WRequest.delete(object: subtask)
        queue!.enqueue(requestDelete)
        let task = wdump.tasks.first!
        let requestModify = WRequest.modify(object: task, modified: task)
        queue!.enqueue(requestModify)
        diskStore.persistQueue.sync(flags: .barrier) {}
        XCTAssertTrue(diskStore.exists(WRequest.self), "Request queue file must exist")
        XCTAssertEqual(queue!.count, 2, "Queue length must be 2")
        queue = nil

        var restoredQueue = Queue<WRequest>(diskStore)
        XCTAssertEqual(restoredQueue.count, 2, "Restored queue length must be 2")
        guard let restoredDelete = restoredQueue.dequeue() else {
            XCTFail("Queue is empty")
            return
        }
        if case WRequest.delete(let restoredSubtask) = restoredDelete {
            XCTAssertTrue(subtask ==== (restoredSubtask as! WSubtask), "Restored subtask corrupted")
        } else {
            XCTFail("\(restoredDelete) not .delete")
        }

        guard let restoredModify = restoredQueue.dequeue() else {
            XCTFail("Queue is empty")
            return
        }
        if case WRequest.modify(let task1, let task2) = restoredModify {
            XCTAssertTrue(task ==== (task1 as! WTask), "Restored task corrupted")
            XCTAssertTrue(task ==== (task2 as! WTask), "Restored modified task corrupted")
        } else {
            XCTFail("\(restoredDelete) not .delete")
        }

        XCTAssertEqual(restoredQueue.count, 0, "Restored queue must be empty")

        diskStore.persistQueue.sync(flags: .barrier) {}
        try? diskStore.delete(WRequest.self)
    }
}
