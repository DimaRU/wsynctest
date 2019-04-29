////
///  DeleteContentService.swift
//

import PromiseKit

struct DeleteContentService {
    
    func deleteFolders() {
        firstly {
            WAPI.get(WFolder.self)
            }.then { folders in
                when(fulfilled: folders.map { WAPI.delete(WFolder.self, id: $0.id, revision: $0.revision) } )
            }.done { _ in
                log("All folders deleted")
            }.catch { (error) in
                log(error: error)
        }
    }

    func deleteLists() {
        firstly {
            WAPI.get(WList.self)
            }.then { (lists: Set<WList>) -> Promise<(Set<WTask>, Set<WTask>, Void)> in
                let inbox = lists.first(where: { $0.listType == "inbox" })!
                let inboxPromise = WAPI.get(WTask.self, listId: inbox.id, completed: false)
                let inboxPromiseCompleted = WAPI.get(WTask.self, listId: inbox.id, completed: true)
                let deletePomise = when(fulfilled: lists.filter({$0.listType != "inbox"}).map {
                    WAPI.delete(WList.self, id: $0.id, revision: $0.revision) })
                return when(fulfilled: inboxPromise, inboxPromiseCompleted, deletePomise)
            }.then { (tasksUncompleted, taskCompleted, _) -> Promise<Void> in
                log("All lists deleted")
                let tasks = tasksUncompleted.union(taskCompleted)
                return when(fulfilled: tasks.map{ WAPI.delete(WTask.self, id: $0.id, revision: $0.revision) })
            }.done { _ in
                log("All tasks in inbox deleted")
            }.catch { (error) in
                log(error: error)
        }
    }

    // Delete folders, lists
    func all() {
        deleteFolders()
        deleteLists()
    }
}
