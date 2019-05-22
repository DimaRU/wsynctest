//
//  AppDataSyncPush.swift
//  wsync
//
//  Created by Dmitriy Borovikov on 29.06.2018.
//  Copyright © 2018 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: External accessors
extension AppDataSync {
    public func update<T: WObject>(modified wobject: T){
        guard let source = appData.getSource(for: wobject) else {
            assertionFailure("No source for modified wobject \(wobject)")
            return
        }
        var modified = wobject
        modified.storedSyncState = .modified
        appData.updateObject(modified)
        let request = WRequest.modify(object: source, modified: modified)
        requestQueue.enqueue(request)
    }

    public func delete<T: WObject>(_ wobject: T) {
        var deleted = wobject
        deleted.storedSyncState = .deleted
        appData.updateObject(deleted)
        let request = WRequest.delete(object: deleted)
        requestQueue.enqueue(request)
    }

    public func add<T: WObject>(created wobject: T) {
        var created = wobject
        created.storedSyncState = .created
        appData.updateObject(created)
        let request = WRequest.create(object: created)
        requestQueue.enqueue(request)
    }


    // Push
    public func push() {
        self.syncState = .push

        guard let request = requestQueue.front else {
            syncState = .idle
            log("Push sync completed")
            return
        }

    }
}
