////
///  AppDataSyncPush.swift
//

import Foundation
import PromiseKit

// MARK: External accessors
extension AppDataSync {
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

        let request = WRequest.create(wobject: created)
        requestQueue.enqueue(request)
    }


    // Push
    public func pushNext(completion: (() -> Void)? = nil) {

        func create(request: WRequest) {
            switch request.type.revisionableClass.self {
            case let type as WFolder.Type: sendCreateRequest(type, request: request)
            case let type as WList.Type: sendCreateRequest(type, request: request)
            case let type as WTask.Type: sendCreateRequest(type, request: request)
            case let type as WMembership.Type: sendCreateRequest(type, request: request)
            case let type as WNote.Type: sendCreateRequest(type, request: request)
            case let type as WReminder.Type: sendCreateRequest(type, request: request)
            case let type as WSubtask.Type: sendCreateRequest(type, request: request)
            case let type as WTaskComment.Type: sendCreateRequest(type, request: request)
            default:
                fatalError()
            }
        }

        func update(request: WRequest) {
            switch request.type.revisionableClass.self {
            case let type as WFile.Type: sendUpdateRequest(type, request: request)
            case let type as WFolder.Type: sendUpdateRequest(type, request: request)
            case let type as WList.Type: sendUpdateRequest(type, request: request)
            case let type as WTask.Type: sendUpdateRequest(type, request: request)
            case let type as WMembership.Type: sendUpdateRequest(type, request: request)
            case let type as WNote.Type: sendUpdateRequest(type, request: request)
            case let type as WReminder.Type: sendUpdateRequest(type, request: request)
            case let type as WSetting.Type: sendUpdateRequest(type, request: request)
            case let type as WSubtask.Type: sendUpdateRequest(type, request: request)
            case let type as WTaskComment.Type: sendUpdateRequest(type, request: request)
            case let type as WTaskCommentsState.Type: sendUpdateRequest(type, request: request)
            case let type as WListPosition.Type: sendUpdateRequest(type, request: request)
            case let type as WTaskPosition.Type: sendUpdateRequest(type, request: request)
            case let type as WSubtaskPosition.Type: sendUpdateRequest(type, request: request)
            case let type as WUser.Type: sendUpdateRequest(type, request: request)
            default:
                fatalError()
            }
        }

        func delete(request: WRequest) {
            switch request.type.revisionableClass.self {
            case let type as WFile.Type: sendDeleteRequest(type, request: request)
            case let type as WFolder.Type: sendDeleteRequest(type, request: request)
            case let type as WList.Type: sendDeleteRequest(type, request: request)
            case let type as WTask.Type: sendDeleteRequest(type, request: request)
            case let type as WMembership.Type: sendDeleteRequest(type, request: request)
            case let type as WNote.Type: sendDeleteRequest(type, request: request)
            case let type as WReminder.Type: sendDeleteRequest(type, request: request)
            case let type as WSetting.Type: sendDeleteRequest(type, request: request)
            case let type as WSubtask.Type: sendDeleteRequest(type, request: request)
            case let type as WTaskComment.Type: sendDeleteRequest(type, request: request)
            case let type as WTaskCommentsState.Type: sendDeleteRequest(type, request: request)
            case let type as WListPosition.Type: sendDeleteRequest(type, request: request)
            case let type as WTaskPosition.Type: sendDeleteRequest(type, request: request)
            case let type as WSubtaskPosition.Type: sendDeleteRequest(type, request: request)
            case let type as WUser.Type: sendDeleteRequest(type, request: request)
            default:
                fatalError()
            }
        }

        func sendCreateRequest<T: WObject & WCreatable>(_ type: T.Type, request: WRequest) {
            let params = request.params.container

            WAPI.create(T.self, params: params, requestId: request.uuid)
                .done { created in
                    self.appData.replaceObject(type: type, id: request.id, parentId: request.parentId, to: created)
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

        func sendUpdateRequest<T: WObject>(_ type: T.Type, request: WRequest) {
            let params = request.params.container

            WAPI.update(type, id: request.id, params: params, requestId: request.uuid)
                .done { updated in
                    self.appData.updateObject(updated)
                    self.requestQueue.dequeue()
                }.ensure {
                    completion?()
                }.catch { error in
                    print(error)
            }
        }

        func sendDeleteRequest<T: WObject>(_ type: T.Type, request: WRequest) {
            WAPI.delete(type, id: request.id, revision: request.revision)
                .done {
                    self.appData.deleteObject(type: type, id: request.id, parentId: request.parentId)
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

        switch request.requestType {
        case .create:
            create(request: request)
        case .update:
            update(request: request)
        case .delete:
            delete(request: request)
        }
    }
}
