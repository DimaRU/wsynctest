//
//  KeychainService.swift
//  wutest
//
//  Created by Dmitriy Borovikov on 08.07.17.
//  Copyright © 2017 Dmitriy Borovikov. All rights reserved.
//

import Cocoa
import KeychainAccess

class KeychainService {
    
    public enum KeychainKeys: String {
        case token
        case backupFile
    }

    let keychain: Keychain
    let sharedKeychain: Keychain
    
    static let shared = KeychainService()
    
    init() {
        // Init keychain access
        let bundle = Bundle.main
        let bundleId = bundle.bundleIdentifier!
        keychain = Keychain(service: bundleId)
        sharedKeychain = Keychain(service: "in.ioshack.wsynctest", accessGroup: "9BEQ8V4XH9.in.ioshack.wsynctest").synchronizable(true)
    }
    
    subscript(key: KeychainKeys) -> String? {
        get {
            switch key {
            case .token,
                 .backupFile:
                return sharedKeychain[key.rawValue]
            }
        }
        
        set {
            switch key {
            case .token,
                 .backupFile:
                sharedKeychain[key.rawValue] = newValue
            }
        }
    }
    
}
