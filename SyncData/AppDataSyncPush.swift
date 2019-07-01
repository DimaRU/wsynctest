////
///  AppDataSyncPush.swift
//

import Foundation
import PromiseKit

// MARK: External accessors
extension AppDataSync {

    // Push
    public func pushNext(completion: (() -> Void)? = nil) {

        func create(request: WRequest) -> Promise<Void> {
            switch request.type.revisionableClass.self {
            case let type as WFolder.Type: return sendCreateRequest(type, request: request)
            case let type as WList.Type: return sendCreateRequest(type, request: request)
            case let type as WTask.Type: return sendCreateRequest(type, request: request)
            case let type as WNote.Type: return sendCreateRequest(type, request: request)
            case let type as WReminder.Type: return sendCreateRequest(type, request: request)
            case let type as WSubtask.Type: return sendCreateRequest(type, request: request)
            case let type as WTaskComment.Type: return sendCreateRequest(type, request: request)
            default:
                fatalError()
            }
        }

        func update(request: WRequest) -> Promise<Void> {
            switch request.type.revisionableClass.self {
            case let type as WFolder.Type: return sendUpdateRequest(type, request: request)
            case let type as WList.Type: return sendUpdateRequest(type, request: request)
            case let type as WTask.Type: return sendUpdateRequest(type, request: request)
            case let type as WMembership.Type: return sendUpdateRequest(type, request: request)
            case let type as WNote.Type: return sendUpdateRequest(type, request: request)
            case let type as WReminder.Type: return sendUpdateRequest(type, request: request)
            case let type as WSetting.Type: return sendUpdateRequest(type, request: request)
            case let type as WSubtask.Type: return sendUpdateRequest(type, request: request)
            case let type as WTaskComment.Type: return sendUpdateRequest(type, request: request)
            case let type as WListPosition.Type: return sendUpdateRequest(type, request: request)
            case let type as WTaskPosition.Type: return sendUpdateRequest(type, request: request)
            case let type as WSubtaskPosition.Type: return sendUpdateRequest(type, request: request)
            default:
                fatalError()
            }
        }

        func delete(request: WRequest) -> Promise<Void> {
            switch request.type.revisionableClass.self {
            case let type as WFile.Type: return sendDeleteRequest(type, request: request)
            case let type as WFolder.Type: return sendDeleteRequest(type, request: request)
            case let type as WList.Type: return sendDeleteRequest(type, request: request)
            case let type as WTask.Type: return sendDeleteRequest(type, request: request)
            case let type as WNote.Type: return sendDeleteRequest(type, request: request)
            case let type as WReminder.Type: return sendDeleteRequest(type, request: request)
            case let type as WSubtask.Type: return sendDeleteRequest(type, request: request)
            case let type as WTaskComment.Type: return sendDeleteRequest(type, request: request)
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

        func recoveryCreatedId<T: WObject & WCreatable>(_ type: T.Type, request: WRequest) -> Promise<T> {
            let promise: Promise<Set<T>>
            switch type {
            case is WFolder.Type,
                 is WList.Type,
                 is WReminder.Type:
                promise = WAPI.get(type)
            case is WTask.Type:
                promise = WAPI.get(type, listId: request.parentId!)
            case is WNote.Type,
                 is WSubtask.Type,
                 is WTaskComment.Type:
                promise = WAPI.get(type, taskId: request.parentId!)
            default:
                fatalError()
            }

            return promise
                .then { wobjects -> Promise<T> in
                    if let wobject = wobjects.first(where: { $0.createdByRequestId?.UUIDstring == request.uuid }) {
                        return Promise.value(wobject)
                    } else {
                        return Promise(error: PMKError.cancelled)
                    }
            }
        }

        func sendCreateRequest<T: WObject & WCreatable>(_ type: T.Type, request: WRequest) -> Promise<Void> {
            guard let wobject = appData.getSource(type: type, id: request.id, parentId: request.parentId) else {
                assertionFailure("No object for create \(type):\(request.id)")
                return Promise(error: PMKError.cancelled)
            }

            let params = wobject.createParams()
            return WAPI.create(T.self, params: params, requestId: request.uuid)
                .recover { error -> Promise<T> in
                    if case WNetworkError.unprocessable = error {
                        // Already created
                        return recoveryCreatedId(type, request: request)
                    } else {
                        throw error
                    }
                }.then { created -> Promise<Void> in
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
            }
        }

        func recoveryUpdate<T: WObject>(_ type: T.Type, request: WRequest, params:  [String : Any]) -> Promise<T> {
            return WAPI.get(type, id: request.id)
                .then { wobject -> Promise<T> in
                    var params = params
                    params["revision"] = wobject.revision
                    return WAPI.update(type, id: request.id, params: params, requestId: request.uuid)
            }
        }

        func sendUpdateRequest<T: WObject>(_ type: T.Type, request: WRequest) -> Promise<Void> {
            guard let wobject = appData.getSource(type: type, id: request.id, parentId: request.parentId) else {
                assertionFailure("No object for update \(type):\(request.id)")
                return Promise(error: PMKError.cancelled)
            }
            let sourceParams = request.params.container
            let params = wobject.updateParams(from: sourceParams)

            return WAPI.update(type, id: request.id, params: params, requestId: request.uuid)
                .recover { error -> Promise<T> in
                    if case WNetworkError.conflict = error {
                        return recoveryUpdate(type, request: request, params: params)
                            .then { _ -> Promise<T> in
                            self.requestQueue.dequeue()
                            throw PMKError.cancelled
                        }
                    } else {
                        throw error
                    }
                }.done { updated in
                    self.appData.updateObject(updated)
                    self.appData.updatedRevisionTouch(wobject: updated)
                    self.requestQueue.dequeue()
            }
        }

        func recoveryDelete<T: WObject>(_ type: T.Type, request: WRequest) -> Promise<Void> {
            return WAPI.get(type, id: request.id)
                .then { wobject in
                    WAPI.delete(type, id: wobject.id, revision: wobject.revision)
            }
        }

        func sendDeleteRequest<T: WObject>(_ type: T.Type, request: WRequest) -> Promise<Void> {
            guard let wobject = appData.getSource(type: type, id: request.id, parentId: request.parentId) else {
                assertionFailure("No object for delete \(type):\(request.id)")
                return Promise(error: PMKError.cancelled)
            }
            return WAPI.delete(type, id: wobject.id, revision: wobject.revision)
                .recover { error -> Promise<Void> in
                    if case WNetworkError.conflict = error {
                        return recoveryDelete(type, request: request)
                    } else {
                        throw error
                    }
                }.done {
                    self.appData.deleteObject(type: type, id: request.id, parentId: request.parentId)
                    self.appData.deletedRevisionTouch(wobject: wobject)
                    self.requestQueue.dequeue()
            }
        }

        // MARK: Body

        self.syncState = .push

        guard let request = requestQueue.front else {
            syncState = .idle
            log("Push sync completed")
            return
        }

        let promise: Promise<Void>
        switch request.requestType {
        case .create:
            promise = create(request: request)
        case .update:
            promise = update(request: request)
        case .delete:
            promise = delete(request: request)
        }

        promise.ensure {
            completion?()
            }.catch { error in
                print(error)
        }
    }
}
