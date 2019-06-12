////
///  AppDataSyncPush.swift
//

import Foundation
import PromiseKit

// MARK: External accessors
extension AppDataSync {

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
            case let type as WFolder.Type: sendUpdateRequest(type, request: request)
            case let type as WList.Type: sendUpdateRequest(type, request: request)
            case let type as WTask.Type: sendUpdateRequest(type, request: request)
            case let type as WMembership.Type: sendUpdateRequest(type, request: request)
            case let type as WNote.Type: sendUpdateRequest(type, request: request)
            case let type as WReminder.Type: sendUpdateRequest(type, request: request)
            case let type as WSetting.Type: sendUpdateRequest(type, request: request)
            case let type as WSubtask.Type: sendUpdateRequest(type, request: request)
            case let type as WTaskComment.Type: sendUpdateRequest(type, request: request)
            case let type as WListPosition.Type: sendUpdateRequest(type, request: request)
            case let type as WTaskPosition.Type: sendUpdateRequest(type, request: request)
            case let type as WSubtaskPosition.Type: sendUpdateRequest(type, request: request)
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
            case let type as WListPosition.Type: sendDeleteRequest(type, request: request)
            case let type as WTaskPosition.Type: sendDeleteRequest(type, request: request)
            case let type as WSubtaskPosition.Type: sendDeleteRequest(type, request: request)
            default:
                fatalError()
            }
        }

        func pullMembership(listId: Int) -> Promise<Void> {
            return WAPI.get(WMembership.self, listId: listId)
                .done { memberships in
                    self.appData.memberships[listId] = memberships
            }
        }

        func sendCreateRequest<T: WObject & WCreatable>(_ type: T.Type, request: WRequest) {
            guard let wobject = appData.getSource(type: type, id: request.id, parentId: request.parentId) else {
                assertionFailure("No object for create \(type):\(request.id)")
                return
            }
            let params = wobject.createParams()
            WAPI.create(T.self, params: params, requestId: request.uuid)
                .then { created -> Promise<Void> in
                    self.appData.replaceObject(type: type, id: request.id, parentId: request.parentId, to: created)
                    self.appData.replaceId(for: type, fakeId: request.id, id: created.id, parentId: request.parentId)
                    self.requestQueue.replaceId(for: type, fakeId: request.id, id: created.id, parentId: request.parentId)
                    self.appData.createdRevisionTouch(wobject: created)
                    self.requestQueue.dequeue()
                    if let list = created as? WList {
                        return pullMembership(listId: list.id)
                    } else {
                        return Promise.value(())
                    }
                }.ensure {
                    completion?()
                }.catch { error in
                    print(error)
            }
        }

        func sendUpdateRequest<T: WObject>(_ type: T.Type, request: WRequest) {
            guard let wobject = appData.getSource(type: type, id: request.id, parentId: request.parentId) else {
                assertionFailure("No object for update \(type):\(request.id)")
                return
            }
            let sourceParams = request.params.container
            let params = wobject.updateParams(from: sourceParams)

            WAPI.update(type, id: request.id, params: params, requestId: request.uuid)
                .done { updated in
                    self.appData.updateObject(updated)
                    self.appData.updatedRevisionTouch(wobject: updated)
                    self.requestQueue.dequeue()
                }.ensure {
                    completion?()
                }.catch { error in
                    print(error)
            }
        }

        func sendDeleteRequest<T: WObject>(_ type: T.Type, request: WRequest) {
            guard let wobject = appData.getSource(type: type, id: request.id, parentId: request.parentId) else {
                assertionFailure("No object for delete \(type):\(request.id)")
                return
            }
            WAPI.delete(type, id: wobject.id, revision: wobject.revision)
                .done {
                    self.appData.deleteObject(type: type, id: request.id, parentId: request.parentId)
                    self.appData.deletedRevisionTouch(type: type, id: request.id, parentId: request.parentId)
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
