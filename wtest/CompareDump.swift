////
///  CompareDump.swift
//


import Foundation

struct CompareDump {

    /// Search differences between local and remote
    ///
    /// - Parameters:
    ///   - local: local array of WObjects
    ///   - remote: remote array of WObjects
    /// - Returns: tuple (removedIds: [Int], changedIds: [Int]) where:
    ///         removedIds - no more exist ids, must be removed
    ///         changedIds = changed and new ids
    static func diffWobjectSets<T: WObject>(old: Set<T>, new: Set<T>) {
        var removedIds = Set<Int>()
        var changedIds = Set<Int>(new.map {$0.id})
        var newIds = Set<Int>()
        for oldObject in old {
            guard let newObject = new[oldObject.id] else {
                removedIds.insert(oldObject.id)       // no remote with that id, removed
                continue
            }
            if newObject.revision == oldObject.revision {
                changedIds.remove(oldObject.id)       // not changed or new
            }
        }
        for newObject in new {
            if old[newObject.id] == nil {
                let id = newObject.id
                newIds.insert(id)
                changedIds.remove(id)
            }
        }

        if newIds.isEmpty, removedIds.isEmpty, changedIds.isEmpty {
            return
        }
        
        let changedString: String = changedIds.reduce(into: "") { (result, id) in
            result += " \(id):\(old[id]!.revision)->\(new[id]!.revision)"
        }

        var string = "\(T.typeName())"
        if !changedIds.isEmpty {
            string += " changed:\(changedString)"
        }
        if !newIds.isEmpty {
            string += " new: \(newIds)"
        }
        if !removedIds.isEmpty {
            string += " removed: \(removedIds)"
        }

        log(string)
    }

    static func compareDump(dump1: WDump, dump2: WDump) {
        guard dump1.root.revision != dump2.root.revision else {
            log("root revisions are equal: \(dump1.root.revision)")
            return
        }

        let from: WDump
        let to: WDump
        if dump1.root.revision < dump2.root.revision {
            from = dump1
            to = dump2
        } else {
            from = dump2
            to = dump1
        }

        log("\nCompare: \(from.comment ?? "-") -> \(to.comment ?? "-")")
        log("root: \(from.root.revision) -> \(to.root.revision)")

        diffWobjectSets(old: from.users, new: to.users)

        diffWobjectSets(old: from.folders, new: to.folders)
        diffWobjectSets(old: from.lists, new: to.lists)
        diffWobjectSets(old: from.listPositions, new: to.listPositions)
        diffWobjectSets(old: from.settings, new: to.settings)
        diffWobjectSets(old: from.reminders, new: to.reminders)
        diffWobjectSets(old: from.memberships, new: to.memberships)
        diffWobjectSets(old: from.tasks, new: to.tasks)
        diffWobjectSets(old: from.taskPositions, new: to.taskPositions)
        diffWobjectSets(old: from.subtasks, new: to.subtasks)
        diffWobjectSets(old: from.subtaskPositions, new: to.subtaskPositions)
        diffWobjectSets(old: from.notes, new: to.notes)
        diffWobjectSets(old: from.files, new: to.files)
        diffWobjectSets(old: from.taskComments, new: to.taskComments)
        diffWobjectSets(old: from.taskCommentStates, new: to.taskCommentStates)
    }
}
