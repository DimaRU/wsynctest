////
///  WrequestTests.swift
//


import XCTest
@testable import wsync

class WrequestTests: XCTestCase {
    var wdump: WDump!

    override func setUp() {
        wdump = loadDump(for: type(of: self), resource: "25830-dump")
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

}
