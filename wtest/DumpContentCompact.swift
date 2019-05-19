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
    
    func dumpTaskLeaf(listId: Int, completed: Bool) -> Promise<Void> {
        return when(fulfilled:
                    WAPI.get(WTask.self, listId: listId, completed: completed),
                    WAPI.get(WSubtask.self, listId: listId, completed: completed),
                    WAPI.get(WSubtaskPosition.self, listId: listId, completed: completed),
                    WAPI.get(WFile.self, listId: listId, completed: completed))
            .done { tasks, subtasks, subtaskPositions, files in
                self.dump.tasks.formUnion(tasks)
                self.dump.subtasks.formUnion(subtasks)
                self.dump.subtaskPositions.formUnion(subtaskPositions)
                self.dump.files.formUnion(files)
            }.then {
                when(fulfilled:
                    WAPI.get(WNote.self, listId: listId, completed: completed),
                    WAPI.get(WTaskComment.self, listId: listId, completed: completed),
                    WAPI.get(WTaskCommentsState.self, listId: listId, completed: completed))
            }.done { notes, comments, commentsStates in
                self.dump.taskComments.formUnion(comments)
                self.dump.notes.formUnion(notes)
                self.dump.taskCommentStates.formUnion(commentsStates)
       }
    }

    func dumpTasks(_ listId: Int) -> Promise<Void> {
        return when(fulfilled:
            WAPI.get(WMembership.self, listId: listId),
            WAPI.get(WTaskPosition.self, listId: listId))
            .done { memberships, taskPositions in
                self.dump.memberships.formUnion(memberships)
                self.dump.taskPositions.formUnion(taskPositions)
            }.then {
                self.dumpTaskLeaf(listId: listId, completed: false)
            }.then {
                self.dumpTaskLeaf(listId: listId, completed: true)
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
