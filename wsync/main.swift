////
///  main.swift
//

import Cocoa

private func isTestRun() -> Bool {
    return NSClassFromString("XCTestCase") != nil
}

if isTestRun() {
    // This skips setting up the app delegate
    NSApplication.shared.run()
} else {
    // For some magical reason, the AppDelegate is setup when
    // initialized this way
    _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
}
