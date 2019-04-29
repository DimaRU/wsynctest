////
///  PrintContent.swift
//

import PromiseKit

struct PrintContent {

    let queue = DispatchQueue(label: "wtest", qos: .background, attributes: [.concurrent])
    
    func printRoot() {
        do {
            let root = try WAPI.getRoot().wait()
            PrintContent.wprint(root)
        } catch {
            log("printRoot error:")
            log(error: error)
        }
    }
    
    func printUser() {
        do {
            let user = try WAPI.getUser().wait()
            PrintContent.wprint(user)
        } catch {
            log("printUser error:")
            log(error: error)
        }
    }
    
    func printUsers() {
        do  {
            let users = try WAPI.get(WUser.self).wait()
            log("Users:")
            users.forEach { PrintContent.wprint($0) }
        } catch {
            log("printUsers error:")
            log(error: error)
        }
    }
    
    func printFolders() {
        do {
            let folders = try WAPI.get(WFolder.self).wait()
            log("Folders:")
            folders.forEach{ PrintContent.wprint($0) }
        } catch {
            log("printFolders error:")
            log(error: error)
        }
    }
    
    func printLists() {
        do {
            let lists = try WAPI.get(WList.self).wait()
            log("Lists + tasks")
            for list in lists {
                let memberships = try WAPI.get(WMembership.self, listId: list.id).wait()
                PrintContent.wprint(list)
                PrintContent.wprint(memberships)
                self.printTasks(list)
                self.printTasks(list, completed: true)
            }
        } catch {
            log("printLists error:")
            log(error: error)
        }
    }
    
    func printTasks(_ list: WList, completed: Bool = false) {
        do {
            let (tasks, subtasks, subtaskPositions, files) = try when(fulfilled:
                WAPI.get(WTask.self, listId: list.id, completed: completed),
                WAPI.get(WSubtask.self, listId: list.id, completed: completed),
                WAPI.get(WSubtaskPosition.self, listId: list.id, completed: completed),
                WAPI.get(WFile.self, listId: list.id, completed: completed)
            ).wait()
            
            let (reminders, notes, comments, commentsStates) = try when(fulfilled:
                WAPI.get(WReminder.self, listId: list.id, completed: completed),
                WAPI.get(WNote.self, listId: list.id, completed: completed),
                WAPI.get(WTaskComment.self, listId: list.id, completed: completed),
                WAPI.get(WTaskCommentsState.self, listId: list.id, completed: completed)
            ).wait()

            for task in tasks {
                PrintContent.wprint(task)
                PrintContent.wprint(subtaskPositions, for: task.id)
                PrintContent.wprint(subtasks, for: task.id)
                PrintContent.wprint(files, for: task.id)
                PrintContent.wprint(notes, for: task.id)
                PrintContent.wprint(reminders, for: task.id)
                PrintContent.wprint(comments, commentsStates, for: task.id)
            }
        } catch {
            log("printTasks error:")
            log(error: error)
        }
    }
    
    func printListPositions() {
        do {
            let listPositions = try WAPI.get(WListPosition.self).wait()
            listPositions.forEach{ listPosition in
                var s = "List positions: "
                print("\(listPosition.id):\(listPosition.revision) ", listPosition.values, terminator: "", to: &s)
                log(s)
            }
        } catch {
            log("printListPositions error:")
            log(error: error)
        }
    }
    
    func printSettings() {
        do {
            let settings = try WAPI.get(WSetting.self).wait()
            log("Settings:\t\(settings.count)")
            settings.forEach { log("\($0.id):\($0.revision)\t\($0.key) = \($0.value)") }
        } catch {
            log("printSettings error:")
            log(error: error)
        }
    }
    
    func printFeatures() {
        do {
            let features = try WAPI.get(WFeature.self).wait()
            log("Features:\t\(features.count)")
        } catch {
            log("printFeatures error:")
            log(error: error)
        }
    }
    
    func printMemberships() {
        do {
            let memberships = try WAPI.get(WMembership.self).wait()
            log("Memberships:\t\(memberships.count)")
            memberships.forEach{ log("\($0.id):\($0.revision)\t\($0.listId)\t\($0.userId)\t\($0.state)") }
        } catch {
            log("printMemberships error:")
            log(error: error)
        }
    }

    
    public func all(_ printSettings: Bool) {
        self.queue.async {
            self.printRoot()
            self.printUser()
            self.printUsers()
            self.printMemberships()
            if printSettings {
                self.printSettings()
                self.printFeatures()
            }
            self.printFolders()
            self.printListPositions()
            self.printLists()
        }
    }
}


extension PrintContent {
    // Mark: log WModel
    
    public static func wprint(_ root: WRoot) {
        log("Root: \(root.id):\(root.revision)\tUser Id:\(root.userId) ")
    }
    
    public static func wprint(_ memberships: Set<WMembership>) {
        memberships.forEach {
            let muted = ($0.muted ?? false) ? "muted" : ""
            let owner = $0.owner ? "owner" : ""
            log("\tMember: \($0.userId), \(owner) \(muted)")
        }
    }
    
    public static func wprint(_ files: Set<WFile>, for taskId: Int) {
        files.filter({ $0.taskId == taskId }).forEach {
            log("\t\tFile: \($0.id):\($0.revision) \($0.fileName): \($0.contentType) - \($0.fileSize)")
        }
    }
    
    public static func wprint(_ comments: Set<WTaskComment>, _ commentsStates: Set<WTaskCommentsState> , for taskId: Int) {
        comments.filter({ $0.taskId == taskId }).forEach {
            log("\t\tComment: \($0.text), author: \($0.author.name)")
        }
        commentsStates.filter({ $0.taskId == taskId }).forEach {
            log("\t\tComments unread: \($0.unreadCount), last read: \($0.lastReadId ?? -1)")
        }
    }
    
    public static func wprint(_ notes: Set<WNote>, for taskId: Int) {
        notes.filter({ $0.taskId == taskId }).forEach {
            log("\t\tNote: \($0.content)")
        }
    }
    
    public static func wprint(_ subtasks: Set<WSubtask>, for taskId: Int) {
        let subtasksFiltered = subtasks.filter({ $0.taskId == taskId })
        if subtasksFiltered.isEmpty { return }
        subtasksFiltered.forEach{ log("\t\t\($0.completed ? "☑︎" : "☐") \($0.title) \($0.id):\($0.revision)") }
    }

    public static func wprint(_ subtaskPositions: Set<WSubtaskPosition>, for taskId: Int) {
        let subtaskPositionsFiltered = subtaskPositions.filter({ $0.taskId == taskId })
        guard let subtaskPosition = subtaskPositionsFiltered.first, !subtaskPosition.values.isEmpty else { return }
        
        log("\t\tPositions: \(subtaskPositionsFiltered.first!.values)")
    }

    public static func wprint(_ reminders: Set<WReminder>, for taskId: Int) {
        reminders.filter({ $0.taskId == taskId }).forEach {
            log("\t\tReminder: \($0.date)")
        }
    }

    public static func wprint(_ task: WTask) {
        let dueString = task.dueDate == nil ? "" : "\tdue \(task.dueDate!)"
        var recurrenceString = task.recurrenceType != nil ? "\t\(task.recurrenceType!)" : ""
        recurrenceString += task.recurrenceCount != nil ? "/\(task.recurrenceCount!)" : ""
        log("\t\(task.completed ? "☑︎" : "☐") \(task.starred ? "★" : "☆")\t\(task.id):\(task.revision)\t\(task.title)\(dueString)\(recurrenceString)")
    }
    
    public static func wprint(_ list: WList) {
        log("\(list.id):\(list.revision)\t\(list.title)")
    }
    
    public static func wprint(_ folder: WFolder) {
        var s = ""
        print("\(folder.id):\(folder.revision)\t\(folder.title): ", folder.listIds, terminator: "", to: &s)
        log(s)
    }

    public static func wprint(_ user: WUser) {
        log("User: \(user.id):\(user.revision)\t\(user.name)\t\(user.email)")
    }
}
