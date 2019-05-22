////
///  WAPI.swift
//

import Foundation
import PromiseKit

struct WAPI {
    
    private init() {}
    
    static func getRoot() -> Promise<WRoot> {
        return WProvider.shared.request(WunderAPI.root)
    }
    static func getUser() -> Promise<WUser> {
        return WProvider.shared.request(WunderAPI.user)
    }
    static func getUnreadActivityCounts() -> Promise<WUnreadActivityCount> {
        return  WProvider.shared.request(WunderAPI.unreadActivityCounts)
    }
    
    static func get<T: WObject>(_ type: T.Type, id: Int) -> Promise<T> {
        return WProvider.shared.request(WunderAPI.loadWObjectById(type: type, id: id))
    }
    
    static func get<T: WObject>(_ type: T.Type) -> Promise<Set<T>> {
        return WProvider.shared.request(WunderAPI.loadWObject(type: type))
    }
    
    static func get<T: WObject>(_ type: T.Type, listId: Int, completed: Bool = false) -> Promise<Set<T>> {
        return WProvider.shared.request(WunderAPI.loadWObjectByListId(type: type, listId: listId, completed: completed))
    }
    
    static func get<T: WObject>(_ type: T.Type, taskId: Int) -> Promise<Set<T>> {
        return WProvider.shared.request(WunderAPI.loadWObjectByTaskId(type: type, taskId: taskId))
    }

    static func getRevision<T: WObject>(_ type: T.Type) -> Promise<Set<WRevision>> {
        return WProvider.shared.request(WunderAPI.loadRevisions(type: type))
    }
    
    static func getRevision<T: WObject>(_ type: T.Type, listId: Int, completed: Bool = false) -> Promise<Set<WRevision>> {
        return WProvider.shared.request(WunderAPI.loadRevisionsByListId(type: type, listId: listId, completed: completed))
    }
    
    static func getRevision<T: WObject>(_ type: T.Type, taskId: Int) -> Promise<Set<WRevision>> {
        return WProvider.shared.request(WunderAPI.loadRevisionsByTaskId(type: type, taskId: taskId))
    }
    
    static func create<T: WObject>(_ type: T.Type, params: [String:Any], requestId: String) -> Promise<T> {
        return WProvider.shared.request(WunderAPI.createWObject(type: type, params: params, requestId: requestId))
    }
    
    static func update<T: WObject>(_ type: T.Type, id: Int, params: [String:Any]) -> Promise<T> {
        return WProvider.shared.request(WunderAPI.updateWObject(type: type, id: id, params: params))
    }
    
    static func delete(_ type: Revisionable.Type, id: Int, revision: Int) -> Promise<Void> {
        return WProvider.shared.request(WunderAPI.deleteWObject(type: type, id: id, revision: revision))
    }
}
