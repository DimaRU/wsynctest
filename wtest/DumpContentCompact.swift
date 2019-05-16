////
///  DumpContent.swift
//

import PromiseKit



class DumpContentComapact {

    var dump = WDump()

    func dumpRoot() -> Promise<Void> {
            return WAPI.getRoot()
            .done { root in
                self.dump.root = root
        }
    }
    
    func dumpUsers() -> Promise<Void> {
        return WAPI.get(WUser.self)
            .done { users in
                self.dump.users = users
        }
    }
    
    func dumpFolders() -> Promise<Void> {
        return WAPI.get(WFolder.self)
            .done { folders in
                self.dump.folders = folders
        }
    }
    
    func dumpReminders() -> Promise<Void> {
        return WAPI.get(WReminder.self)
            .done { reminders in
                self.dump.reminders = reminders
        }
    }
    
    func dumpLists() -> Promise<Void> {
        return WAPI.get(WList.self)
            .then { lists -> Promise<[Void]> in
                self.dump.lists = lists
                return when(fulfilled: (lists.map{ self.dumpTasks($0.id) }).makeIterator(), concurrently: 2)
            }.done { _ in
        }
    }
    
    func dumpTaskLeaf(taskId: Int) -> Promise<Void> {
        return when(fulfilled:
                    WAPI.get(WSubtask.self, taskId: taskId),
                    WAPI.get(WFile.self, taskId: taskId),
                    WAPI.get(WTaskComment.self, taskId: taskId),
                    WAPI.get(WNote.self, taskId: taskId)
            )
            .then { (subtasks, files, comments, notes) -> Promise<(Set<WSubtaskPosition>, Set<WTaskCommentsState>)> in
                self.dump.subtasks.formUnion(subtasks)
                self.dump.files.formUnion(files)
                self.dump.taskComments.formUnion(comments)
                self.dump.notes.formUnion(notes)
                return when(fulfilled:
                    WAPI.get(WSubtaskPosition.self, taskId: taskId),
                    WAPI.get(WTaskCommentsState.self, taskId: taskId))
            }.done { subtaskPositions, commentsStates in
                self.dump.subtaskPositions.formUnion(subtaskPositions)
                self.dump.taskCommentStates.formUnion(commentsStates)
        }
    }
    
    
    func dumpTasks(_ listId: Int) -> Promise<Void> {
        return when(fulfilled:
            WAPI.get(WMembership.self, listId: listId),
            WAPI.get(WTask.self, listId: listId, completed: false),
            WAPI.get(WTask.self, listId: listId, completed: true),
            WAPI.get(WTaskPosition.self, listId: listId))
            .then { (memberships, tasks, tasksCompleted, taskPositions) -> Promise<[Void]> in
                self.dump.memberships.formUnion(memberships)
                let taskAll = tasks.union(tasksCompleted)
                self.dump.tasks.formUnion(taskAll)
                self.dump.taskPositions.formUnion(taskPositions)
                return when(fulfilled: taskAll.map { self.dumpTaskLeaf(taskId: $0.id) }.makeIterator(), concurrently: 1)
            }.done { _ in
        }
    }
    
    func dumpListPositions() -> Promise<Void> {
        return WAPI.get(WListPosition.self)
            .done { listPositions in
                self.dump.listPositions.formUnion(listPositions)
        }
    }
    
    func dumpSettings() -> Promise<Void> {
        return WAPI.get(WSetting.self)
            .done { settings in
                self.dump.settings.formUnion(settings)
        }
    }
    
    public func all() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Date.iso8601FullFormatter)
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        Disk.customEncoder = encoder

        firstly {
                self.dumpRoot()
            }.then {
                self.dumpUsers()
            }.then {
                self.dumpSettings()
            }.then {
                self.dumpFolders()
            }.then {
                self.dumpReminders()
            }.then {
                self.dumpListPositions()
            }.then {
                self.dumpLists()
            }.done {
                let root = self.dump.root
                let userId = root.userId
                let user = self.dump.users.first(where: { $0.id == userId})!
                let directory = "logs/dump/"
                let fileName = "\(directory)\(user.email)/\(root.revision)-dump.json"
                try Disk.save(self.dump, to: Disk.Directory.developer, as: fileName)
            }.catch { error in
                print(error)
        }
    }
}
