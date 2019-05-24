////
///  AppDataSyncPush.swift
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
        let uuid = UUID().uuidString.lowercased()
        let request = WRequest.modify(uuid: uuid, object: source, modified: modified)
        requestQueue.enqueue(request)
    }

    public func delete<T: WObject>(_ wobject: T) {
        var deleted = wobject
        deleted.storedSyncState = .deleted
        appData.updateObject(deleted)
        let uuid = UUID().uuidString.lowercased()
        let request = WRequest.delete(uuid: uuid, object: deleted)
        requestQueue.enqueue(request)
    }

    public func add<T: WObject>(created wobject: T) {
        var created = wobject
        created.storedSyncState = .created
        appData.updateObject(created)
        let uuid = UUID().uuidString.lowercased()
        let request = WRequest.create(uuid: uuid, object: created)
        requestQueue.enqueue(request)
    }


    // Push
    public func pushNext(completion: (() -> Void)? = nil) {
        func create(_ object: Revisionable, uuid: String) {
            switch object.self {
            case let object as WFolder: sendCreateReques(object, uuid: uuid)
            case let object as WList: sendCreateReques(object, uuid: uuid)
            case let object as WTask: sendCreateReques(object, uuid: uuid)
            case let object as WMembership: sendCreateReques(object, uuid: uuid)
            case let object as WNote: sendCreateReques(object, uuid: uuid)
            case let object as WReminder: sendCreateReques(object, uuid: uuid)
            case let object as WSubtask: sendCreateReques(object, uuid: uuid)
            case let object as WTaskComment: sendCreateReques(object, uuid: uuid)
            default:
                fatalError()
            }
        }

        func modify(object: Revisionable, modified: Revisionable) {
            switch object.self {
            case let object as WFile: sendUpdateReques(object: object, modified: modified as! WFile)
            case let object as WFolder: sendUpdateReques(object: object, modified: modified as! WFolder)
            case let object as WList: sendUpdateReques(object: object, modified: modified as! WList)
            case let object as WTask: sendUpdateReques(object: object, modified: modified as! WTask)
            case let object as WMembership: sendUpdateReques(object: object, modified: modified as! WMembership)
            case let object as WNote: sendUpdateReques(object: object, modified: modified as! WNote)
            case let object as WReminder: sendUpdateReques(object: object, modified: modified as! WReminder)
            case let object as WSetting: sendUpdateReques(object: object, modified: modified as! WSetting)
            case let object as WSubtask: sendUpdateReques(object: object, modified: modified as! WSubtask)
            case let object as WTaskComment: sendUpdateReques(object: object, modified: modified as! WTaskComment)
            case let object as WTaskCommentsState: sendUpdateReques(object: object, modified: modified as! WTaskCommentsState)
            case let object as WListPosition: sendUpdateReques(object: object, modified: modified as! WListPosition)
            case let object as WTaskPosition: sendUpdateReques(object: object, modified: modified as! WTaskPosition)
            case let object as WSubtaskPosition: sendUpdateReques(object: object, modified: modified as! WSubtaskPosition)
            case let object as WUser: sendUpdateReques(object: object, modified: modified as! WUser)
            default:
                fatalError()
            }
        }

        func delete(_ object: Revisionable) {
            switch object.self {
            case let object as WFile: sendDeleteRequest(object)
            case let object as WFolder: sendDeleteRequest(object)
            case let object as WList: sendDeleteRequest(object)
            case let object as WTask: sendDeleteRequest(object)
            case let object as WMembership: sendDeleteRequest(object)
            case let object as WNote: sendDeleteRequest(object)
            case let object as WReminder: sendDeleteRequest(object)
            case let object as WSetting: sendDeleteRequest(object)
            case let object as WSubtask: sendDeleteRequest(object)
            case let object as WTaskComment: sendDeleteRequest(object)
            case let object as WTaskCommentsState: sendDeleteRequest(object)
            case let object as WListPosition: sendDeleteRequest(object)
            case let object as WTaskPosition: sendDeleteRequest(object)
            case let object as WSubtaskPosition: sendDeleteRequest(object)
            case let object as WUser: sendDeleteRequest(object)
            default:
                fatalError()
            }
        }

        func sendCreateReques<T: WObject & WCreatable>(_ wobject: T, uuid: String) {
            let params = wobject.createParams()

            WAPI.create(T.self, params: params, requestId: uuid)
                .done { created in
                    self.appData.replaceObject(wobject: wobject, to: created)
                    self.requestQueue.dequeue()
                    switch created {
                    case let task as WTask:
                        let subtaskPosition = WSubtaskPosition(storedSyncState: nil, id: task.id, revision: 0, taskId: task.id, values: [])
                        print(subtaskPosition)
                        self.appData.subtaskPositions[task.id].update(with: subtaskPosition)
                    default:
                        break
                    }
                }.ensure {
                    completion?()
                }.catch { error in
                    print(error)
            }
        }

        func sendUpdateReques<T: WObject>(object: T, modified: T) {
            let params = modified.updateParams(from: object)

            WAPI.update(T.self, id: object.id, params: params)
                .done { updated in
                    self.appData.updateObject(updated)
                    self.requestQueue.dequeue()
                }.ensure {
                    completion?()
                }.catch { error in
                    print(error)
            }
        }

        func sendDeleteRequest<T: WObject>(_ object: T) {
            WAPI.delete(object.type.revisionableClass, id: object.id, revision: object.revision)
                .done {
                    self.appData.deleteObject(wobject: object)
                    self.requestQueue.dequeue()
                }.ensure {
                    completion?()
                }.catch { error in
                    print(error)
            }
        }

        // MARK: Body

        self.syncState = .push

        guard let request = requestQueue.front else {
            syncState = .idle
            log("Push sync completed")
            return
        }

        switch request {
        case .create(let uuid, let object):
            create(object, uuid: uuid)
        case .delete(_, let object):
            delete(object)
        case .modify(_, let object, let modified):
            modify(object: object, modified: modified)
        }
    }
}
