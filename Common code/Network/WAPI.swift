////
///  WAPI.swift
//

import Foundation
import PromiseKit

struct WAPI {
    
    private init() {}
    
    static func getRoot() -> Promise<WRoot> {
        return WuProvider.moya.request(WunderAPI.root)
    }
    static func getUser() -> Promise<WUser> {
        return WuProvider.moya.request(WunderAPI.user)
    }
    static func getUnreadActivityCounts() -> Promise<WUnreadActivityCount> {
        return  WuProvider.moya.request(WunderAPI.unreadActivityCounts)
    }
    
    static func get<T: WObject>(_ type: T.Type, id: Int) -> Promise<T> {
        return WuProvider.moya.request(WunderAPI.loadWObjectById(type: type, id: id))
    }
    
    static func get<T: WObject>(_ type: T.Type) -> Promise<Set<T>> {
        return WuProvider.moya.request(WunderAPI.loadWObject(type: type))
    }
    
    static func get<T: WObject>(_ type: T.Type, listId: Int, completed: Bool = false) -> Promise<Set<T>> {
        return WuProvider.moya.request(WunderAPI.loadWObjectByListId(type: type, listId: listId, completed: completed))
    }
    
    static func get<T: WObject>(_ type: T.Type, taskId: Int) -> Promise<Set<T>> {
        return WuProvider.moya.request(WunderAPI.loadWObjectByTaskId(type: type, taskId: taskId))
    }

    static func getRevision<T: WObject>(_ type: T.Type) -> Promise<Set<WRevision>> {
        return WuProvider.moya.request(WunderAPI.loadRevisions(type: type))
    }
    
    static func getRevision<T: WObject>(_ type: T.Type, listId: Int, completed: Bool = false) -> Promise<Set<WRevision>> {
        return WuProvider.moya.request(WunderAPI.loadRevisionsListId(type: type, listId: listId, completed: completed))
    }
    
    static func getRevision<T: WObject>(_ type: T.Type, taskId: Int) -> Promise<Set<WRevision>> {
        return WuProvider.moya.request(WunderAPI.loadRevisionsTaskId(type: type, taskId: taskId))
    }
    
    static func create<T: WObject>(_ type: T.Type, params: [String:Any]) -> Promise<T> {
        return WuProvider.moya.request(WunderAPI.createWObject(type: type, params: params))
    }
    
    static func update<T: WObject>(_ type: T.Type, id: Int, params: [String:Any]) -> Promise<T> {
        return WuProvider.moya.request(WunderAPI.updateWObject(type: type, id: id, params: params))
    }
    
    static func delete<T: WObject>(_ type: T.Type, id: Int, revision: Int) -> Promise<Void> {
        return WuProvider.moya.request(WunderAPI.deleteWObject(type: type, id: id, revision: revision))
    }
    
    static func update<T: WObject>(from: T, to: T) -> Promise<T> {
        assert(from.id == to.id, "Update object id is't equal")
        let params = wobjectDiff(from: from, to: to)
        log("Update \(T.typeName()), id: \(from.id) revision: \(from.revision) params: \(params)")
        return WAPI.update(T.self, id: from.id, params: params)
    }

    static func create<T: WObject>(from wobject: T) throws -> Promise<T> {
        let params = wobjectCreateParams(from: wobject)
        let newObjbect = WAPI.create(T.self, params: params)
        
        log("\(T.typeName()) created")
        return newObjbect
    }

    
}
