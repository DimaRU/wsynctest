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

    struct AppStore: Codable {
        let version: Int = 1 // Store version
        var localId: Int
    }
    
    var appData: AppData
    var diskStore: DiskStore?
    var syncState = SyncState.idle
    var requestQueue: Queue<WRequest>
    var appStore: AppStore {
        didSet {
            diskStore?.persist(appStore)
        }
    }

    init(appData: AppData) {
        self.appData = appData
        self.diskStore = appData.diskStore
        self.requestQueue = Queue<WRequest>(diskStore)
        if let appStore = diskStore?.load(AppStore.self) {
            self.appStore = appStore
        } else {
            self.appStore = AppStore(localId: -1000)
        }
    }

    var fakeId: Int {
        appStore.localId -= 1
        return appStore.localId
    }
    // MARK: Push accessors
    public func update<T: WObject>(updated wobject: T){
        guard let source = appData.getSource(for: wobject) else {
            assertionFailure("No source for modified wobject \(wobject)")
            return
        }
        var updated = wobject
        updated.storedSyncState = .modified
        appData.updateObject(updated)
        let request = WRequest.update(wobject: source, updated: updated)
        requestQueue.enqueue(request)
    }

    public func delete<T: WObject>(_ wobject: T) {
        var deleted = wobject
        deleted.storedSyncState = .deleted
        appData.updateObject(deleted)

        let request = WRequest.delete(wobject: wobject)
        requestQueue.enqueue(request)
    }

    public func add<T: WObject & WCreatable>(created wobject: T) {
        var created = wobject
        created.storedSyncState = .created
        appData.updateObject(created)
        if let task = created as? WTask {
            let subtaskPosition = WSubtaskPosition(storedSyncState: .created, id: task.id, revision: 0, taskId: task.id, values: [])
            self.appData.subtaskPositions[task.id].update(with: subtaskPosition)
        }

        let request = WRequest.create(wobject: created)
        requestQueue.enqueue(request)
    }

    public func makeWList(title: String) -> WList {
        return WList(id: fakeId, title: title)
    }
    public func makeWTask(listId: Int, title: String, starred: Bool = false) -> WTask {
        return WTask(id: fakeId, listId: listId, title: title, starred: starred)
    }
    public func makeWSubtask(taskId: Int, title: String) -> WSubtask {
        return WSubtask(id: fakeId, taskId: taskId, title: title)
    }
    public func makeWNote(taskId: Int, content: String) -> WNote {
        return WNote(id: fakeId, taskId: taskId, content: content)
    }
    public func makeWTaskComment(taskId: Int, text: String) -> WTaskComment {
        return WTaskComment(id: fakeId, taskId: taskId, text: text)
    }
    public func makeWFolder(title: String, listIds: [Int]) -> WFolder {
        return WFolder(id: fakeId, title: title, listIds: listIds)
    }

}
