////
///  DumpContent.swift
//

import PromiseKit

class DumpContent {
    
    let queue = DispatchQueue(label: "wtest", qos: .background, attributes: [.concurrent])
    var directory: String

    init() {
        directory = "logs/dump/"
    }
    
    func dumpRoot() {
        let semaphore = DispatchSemaphore(value: 0)
            WAPI.getRoot()
            .then(on: self.queue) { root in
                WAPI.getUser().map { ($0, root) }
            }.done(on: self.queue) { user, root in
                self.directory += "\(user.email)/\(root.revision)/"
                self.dumpContent(root)
            }.ensure(on: self.queue) {
                    semaphore.signal()
            }.catch(on: self.queue) { (error) in
                log(error: error)
        }
        semaphore.wait()
    }
    
    func dumpUsers() {
        firstly {
            WAPI.get(WUser.self)
            }.done(on: self.queue) { users in
                self.dumpContent(users)
            }.catch(on: self.queue) { (error) in
                log(error: error)
        }
    }
    
    func dumpFolders() {
        WAPI.get(WFolder.self)
            .done(on: self.queue) { folders in
                self.dumpContent(folders)
            }.catch(on: self.queue) { (error) in
                log(error: error)
        }
    }
    
    func dumpReminders() {
        WAPI.get(WReminder.self)
            .done(on: self.queue) { reminders in
                self.dumpContent(reminders)
            }.catch(on: self.queue) { (error) in
                log(error: error)
        }
    }
    
    func dumpLists() {
        WAPI.get(WList.self)
            .done(on: self.queue) { lists in
                self.dumpContent(lists)
                for list in lists {
                    self.dumpTasks(list.id)
                }
            }.catch(on: self.queue) { (error) in
                log(error: error)
        }
    }
    
    func dumpTaskLeaf(taskId: Int) {
        when(fulfilled:
            WAPI.get(WSubtask.self, taskId: taskId),
             WAPI.get(WFile.self, taskId: taskId),
             WAPI.get(WTaskComment.self, taskId: taskId),
             WAPI.get(WNote.self, taskId: taskId)
            )
            .then(on: self.queue) { (subtasks, files, comments, notes) -> Promise<(Set<WSubtaskPosition>, Set<WTaskCommentsState>)> in
                self.dumpContent(subtasks)
                self.dumpContent(files)
                self.dumpContent(comments)
                self.dumpContent(notes)
                return when(fulfilled: WAPI.get(WSubtaskPosition.self, taskId: taskId),
                            WAPI.get(WTaskCommentsState.self, taskId: taskId))
            }.done(on: self.queue) { subtaskPositions, commentsStates in
                self.dumpContent(subtaskPositions)
                self.dumpContent(commentsStates)
            }
            .catch(on: self.queue) { (error) in
                log(error: error)
        }
    }
    
    
    func dumpTasks(_ listId: Int) {
        when(fulfilled:
            WAPI.get(WMembership.self, listId: listId),
            WAPI.get(WTask.self, listId: listId, completed: false),
            WAPI.get(WTask.self, listId: listId, completed: true))
            .then(on: self.queue) { (memberships, tasks, tasksCompleted) -> Promise<Set<WTaskPosition>> in
                self.dumpContent(memberships)
                let taskAll = tasks.union(tasksCompleted)
                self.dumpContent(taskAll)
                for task in taskAll {
                    self.dumpTaskLeaf(taskId: task.id)
                }
                return WAPI.get(WTaskPosition.self, listId: listId)
            }.done(on: self.queue) { taskPositions in
                self.dumpContent(taskPositions)
            }.catch(on: self.queue) { (error) in
                log(error: error)
        }
    }
    
    func dumpListPositions() {
        firstly {
            WAPI.get(WListPosition.self)
            }.done(on: self.queue) { listPositions in
                self.dumpContent(listPositions)
            }.catch(on: self.queue) { (error) in
                log(error: error)
        }
    }
    
    func dumpSettings() {
        firstly {
            WAPI.get(WSetting.self)
            }.done(on: self.queue) { settings in
                self.dumpContent(settings)
            }.catch(on: self.queue) { (error) in
                log(error: error)
        }
    }
    
    public func all() {
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Date.iso8601FullFormatter)
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .prettyPrinted
        Disk.customEncoder = encoder

        self.queue.async {

            self.dumpRoot()
            self.dumpUsers()
            self.dumpSettings()
            self.dumpFolders()
            self.dumpReminders()
            self.dumpListPositions()
            self.dumpLists()
            
        }
    }
    
    func dumpContent<T: WObject>(_ wobject: Set<T>) {
        guard !wobject.isEmpty else {
            return
        }
        
        let wobjStripped: [T] = wobject.map {
            var stripped = $0
            stripped.storedSyncState = nil
            return stripped
        }
        let obj = wobject.first!
        let fileName: String
        switch obj {
        case is ListChild:
            let parentId = (obj as! ListChild).listId
            fileName = "\(directory)\(obj.type.rawValue)-\(parentId).json"
        case is TaskChild:
            let parentId = (obj as! TaskChild).taskId
            fileName = "\(directory)\(obj.type.rawValue)-\(parentId).json"
        default:
            fileName = "\(directory)\(obj.type.rawValue).json"
        }
        try! Disk.save(wobjStripped, to: Disk.Directory.developer, as: fileName)
    }
    
    func dumpContent<T: WObject>(_ wobject: T) {
        var wobjStripped = wobject
        wobjStripped.storedSyncState = nil
        let fileName = "\(directory)\(wobject.type.rawValue).json"
        try! Disk.save(wobjStripped, to: Disk.Directory.developer, as: fileName)
    }
}
