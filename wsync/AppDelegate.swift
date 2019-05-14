//
//  AppDelegate.swift
//  wutest
//
//  Created by Dmitriy Borovikov on 22.06.17.
//  Copyright © 2017 Dmitriy Borovikov. All rights reserved.
//

import Cocoa

//@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        _ = StreamLog.init(directory: .developerDirectory, filePath: "logs/wsync-wss.log")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        StreamLog.shared = nil
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

