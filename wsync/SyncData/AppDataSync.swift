//
//  AppDataSync.swift
//  wsync
//
//  Created by Dmitriy Borovikov on 12.05.2018.
//  Copyright © 2018 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import PromiseKit

class AppDataSync {

    enum SyncState {
        case idle
        case push
        case pull
    }
    
    internal var appData: AppData
    internal var syncState = SyncState.idle

    init(appData: AppData) {
        self.appData = appData
    }
    
    func get<T: WObject>(_ type: T.Type, id: Int) -> Promise<T> {
        guard syncState == .pull else { return Promise(error: PMKError.cancelled) }
        return WAPI.get(type, id: id)
    }

    func get<T: WObject>(_ type: T.Type) -> Promise<Set<T>> {
        guard syncState == .pull else { return Promise(error: PMKError.cancelled) }
        return WAPI.get(type)
    }
    
    func get<T: WObject>(_ type: T.Type, listId: Int, completed: Bool = false) -> Promise<Set<T>> {
        guard syncState == .pull else { return Promise(error: PMKError.cancelled) }
        return WAPI.get(type, listId: listId, completed: completed)
    }
    
    func get<T: WObject>(_ type: T.Type, taskId: Int) -> Promise<Set<T>> {
        guard syncState == .pull else { return Promise(error: PMKError.cancelled) }
        return WAPI.get(type, taskId: taskId)
    }
}
