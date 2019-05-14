//
//  ViewController.swift
//  wutest
//
//  Created by Dmitriy Borovikov on 22.06.17.
//  Copyright © 2017 Dmitriy Borovikov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var token: NSTextField!
    @IBOutlet weak var clientId: NSTextField!
    @IBOutlet weak var clientSecret: NSTextField!
    @IBOutlet weak var avatarImageView: NSImageView!
    
    
    let diskStore = DiskStore.init(filePath: "logs/wstore/", directory: .developer)
    var appDataStore: AppData!
    
    private func isTesting() -> Bool {
        return NSClassFromString("XCTest") != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isTesting() {
            loadDefaults()
            setAvatarImage()
        }
    }
    
    override func viewWillDisappear() {
        saveDefaults()
    }

    /// Load default text field values from keychain
    func loadDefaults() {
        clientId.stringValue     = APIKeys.shared.clientId
        clientSecret.stringValue = APIKeys.shared.clientSecret
        token.stringValue        = KeychainService.shared[.token] ?? ""
    }
    
    /// Save text fiels values to keychain
    func saveDefaults() {
        guard KeychainService.shared[.token] != token.stringValue else { return }
        KeychainService.shared[.token]  = token.stringValue
        setAvatarImage()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
//        guard let textField = obj.object as? NSTextField else { return }
//        print(textField.stringValue)
        saveDefaults()
    }
    

    @IBAction func CheckDiskStoreButtonPress(_ sender: NSButton) {
        if appDataStore == nil { return }
        log("Check DiskStore file consistence")
        let checkStore = CheckDiskStore()
        checkStore.checkFileConsistency(appStore: appDataStore)
    }

    @IBAction func CheckDataStoreButtonPress(_ sender: NSButton) {
        if appDataStore == nil { return }
        log("Check DataStore consistence")
        let checkStore = CheckDataStore()
        checkStore.checkDataConsistency(appStore: appDataStore)
    }

    @IBAction func StartSyncButtonPress(_ sender: NSButton) {
        log("Init and start sync")
        appDataStore = AppData(diskStore: diskStore)
    }

    @IBAction func StopSyncButtonPress(_ sender: NSButton) {
        log("Stop sync, clear store")
        appDataStore = nil
    }

    
    @IBAction func pullTestButtonPress(_ sender: NSButton) {
        guard appDataStore != nil else { return }
        log("Start pull data")
        let appDataSync = AppDataSync(appData: appDataStore)
        appDataSync.pull()
    }

    @IBAction func clearStoreButtonPress(_ sender: NSButton) {
        let alert = NSAlert()
        alert.informativeText = "Are you sure?"
        alert.messageText = "Clear disk store directory"
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        let responce = alert.runModal()
        if responce != .alertFirstButtonReturn {
            return
        }
        do {
            try Disk.clear(path: diskStore.filePath, directory: diskStore.directory)
            log("Disk store cleared")
        } catch {
            print(error)
        }
    }

    func ShowNetwork(error: Swift.Error) {
        let printableError = error as CustomStringConvertible
        let alert = NSAlert()
        alert.messageText = "Network error"
        alert.informativeText = printableError.description
        alert.runModal()
    }
    
    func setAvatarImage() {
        guard !token.stringValue.isEmpty else {
            return
        }
        WAvatar.loadCurrent { image in
            self.avatarImageView.image = image
            log("Download avatar ok")
            WuWSSProvider.websocketInit()
        }
    }
}



