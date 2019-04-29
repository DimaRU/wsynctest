////
///  CheckStore.swift
//

import Foundation

struct CheckDiskStore {
    func fileFrom<T>(_ type: T.Type, parentId: Int? = nil) -> String where T : WObject {
        let fileId = parentId == nil ? T.fileId() : T.fileId(parentId: parentId!)
        return fileId + ".json"
    }

    /// Check disk store file consistncy
    ///
    /// - Parameter appStore: AppData initialised with diskStore
    func checkFileConsistency(appStore: AppData) {
        guard let diskStore = appStore.diskStore else {
            return
        }
        guard var fileList = try? Disk.list(for: diskStore.filePath, in: diskStore.directory) else {
            log("Disk store \(diskStore.filePath) not exist")
            return
        }
        guard !fileList.isEmpty else {
            log("Disk store \(diskStore.filePath) is empty")
            return
        }
        
        var fileSet = Set<String>(fileList)
        func checkConsistency(_ fileName: String) {
            if !fileSet.contains(fileName) {
                log("File not exist: \(fileName)")
            } else {
                fileSet.remove(fileName)
            }
        }
        
        // check
        checkConsistency(fileFrom(WRoot.self))
        checkConsistency(fileFrom(WUser.self))
        checkConsistency(fileFrom(WFolder.self))
        checkConsistency(fileFrom(WList.self))
        checkConsistency(fileFrom(WListPosition.self))
        checkConsistency(fileFrom(WReminder.self))
        checkConsistency(fileFrom(WSetting.self))

        appStore.memberships.dictionary.forEach{ checkConsistency(fileFrom(WMembership.self, parentId: $0.key)) }
        appStore.tasks.dictionary.forEach{ checkConsistency(fileFrom(WTask.self, parentId: $0.key)) }
        appStore.taskPositions.dictionary.forEach{ checkConsistency(fileFrom(WTaskPosition.self, parentId: $0.key)) }
        appStore.subtasks.dictionary.forEach{ checkConsistency(fileFrom(WSubtask.self, parentId: $0.key)) }
        appStore.subtaskPositions.dictionary.forEach{ checkConsistency(fileFrom(WSubtaskPosition.self, parentId: $0.key)) }
        appStore.notes.dictionary.forEach{ checkConsistency(fileFrom(WNote.self, parentId: $0.key)) }
        appStore.files.dictionary.forEach{ checkConsistency(fileFrom(WFile.self, parentId: $0.key)) }
        appStore.taskComments.dictionary.forEach{ checkConsistency(fileFrom(WTaskComment.self, parentId: $0.key)) }
        
        if fileSet.isEmpty {
            log("Check OK!")
        } else {
            var s: String = ""
            print("Unnecessary files:", fileSet, to: &s)
            log(s)
        }
    }
    
    func checkDataConsistency(appStore: AppData) {
        
    }
    
}
