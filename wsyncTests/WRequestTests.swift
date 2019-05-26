////
///  WRequestTests.swift
//

import XCTest
@testable import wsync

class WRequestTests: XCTestCase {
    var wdump: WDump!
    var diskStore: DiskStore!

    override func setUp() {
        wdump = loadDump(bundle: Bundle(for: type(of: self)), resource: "25830-dump")
        diskStore = DiskStore(filePath: "logs/testStore/", directory: .developer)
    }

    func testUpdate() {
        guard let task = wdump.tasks.first(where: { $0.dueDate != nil} ) else {
            XCTFail("No task with due date")
            return
        }
        var updatedTask = task
        updatedTask.title = "Modified task title"
        updatedTask.dueDate = nil
        let request = WRequest.update(wobject: task, updated: updatedTask)
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

        let request = WRequest.create(wobject: list)
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

        let request = WRequest.delete(wobject: subtask)
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
        let requestDelete = WRequest.delete(wobject: subtask)
        queue!.enqueue(requestDelete)

        guard let task = wdump.tasks.first(where: { $0.dueDate != nil} ) else {
            XCTFail("No task with due date")
            return
        }
        var updatedTask = task
        updatedTask.title = "Modified task title"
        updatedTask.dueDate = nil
        let requestModify = WRequest.update(wobject: task, updated: updatedTask)
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
        XCTAssertTrue(requestDelete.id == restoredDelete.id, "Restored delete request corrupted")

        guard let restoredModify = restoredQueue.dequeue() else {
            XCTFail("Queue is empty")
            return
        }
        XCTAssertTrue(requestModify.id == restoredModify.id, "Restored update request corrupted")
        XCTAssertTrue(requestModify.requestType == restoredModify.requestType, "Restored update request corrupted")

        XCTAssertEqual(restoredQueue.count, 0, "Restored queue must be empty")

        diskStore.persistQueue.sync(flags: .barrier) {}
        try? diskStore.delete(WRequest.self)
    }
}
