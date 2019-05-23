////
///  LoadDump.swift
//

import XCTest
@testable import wsync

func loadDump(bundle: Bundle, resource: String) -> WDump {
    guard let url = bundle.url(forResource: "\(resource)", withExtension: "json") else {
        XCTFail("Missing file: \(resource).json")
        return WDump()
    }
    let json = try! Data(contentsOf: url)
    let decoder = WJSONAbleCoders.decoder
    do {
        return try decoder.decode(WDump.self, from: json)
    } catch {
        XCTFail(error.localizedDescription)
        return WDump()
    }
}
