////
///  CheckAppStore.swift
//

import XCTest
@testable import wsync

struct CheckAppStore {
    static private func diffWobjectSets<T: WObject>(exist: Set<T>, must: Set<T>) {
        if exist != must {
            let revisionsExist = exist.sorted{ $0.id < $1.id }.map { ($0.id, $0.revision)}
            let revisionsMust = must.sorted{ $0.id < $1.id }.map { ($0.id, $0.revision)}
            print("\(T.self):")
            print("Revisions exist:", revisionsExist)
            print("Revisions must:", revisionsMust)
        }
        XCTAssertEqual(exist, must, "Not equal: \(T.self), difference elements: \(exist.symmetricDifference(must))")
        XCTAssertTrue(exist ==== must, "Contents not equal")
        exist.forEach { XCTAssertTrue($0.syncState == .synced, "Not .synced state: \($0)") }
    }

    public static func compareAppData(appData: AppData, wdump: WDump) {

        XCTAssertEqual(wdump.root, appData.root, "root is not equal: \(wdump.root), \(appData.root)")
        CheckAppStore.diffWobjectSets(exist: appData.users, must: wdump.users)
        CheckAppStore.diffWobjectSets(exist: appData.folders, must: wdump.folders)
        CheckAppStore.diffWobjectSets(exist: appData.lists, must: wdump.lists)
        CheckAppStore.diffWobjectSets(exist: appData.listPositions, must: wdump.listPositions)
        CheckAppStore.diffWobjectSets(exist: appData.settings, must: wdump.settings)
        CheckAppStore.diffWobjectSets(exist: appData.reminders, must: wdump.reminders)
        CheckAppStore.diffWobjectSets(exist: appData.memberships.set, must: wdump.memberships)
        CheckAppStore.diffWobjectSets(exist: appData.tasks.set, must: wdump.tasks)
        CheckAppStore.diffWobjectSets(exist: appData.taskPositions.set, must: wdump.taskPositions)
        CheckAppStore.diffWobjectSets(exist: appData.subtasks.set, must: wdump.subtasks)
        CheckAppStore.diffWobjectSets(exist: appData.subtaskPositions.set, must: wdump.subtaskPositions)
        CheckAppStore.diffWobjectSets(exist: appData.notes.set, must: wdump.notes)
        CheckAppStore.diffWobjectSets(exist: appData.files.set, must: wdump.files)
        CheckAppStore.diffWobjectSets(exist: appData.taskComments.set, must: wdump.taskComments)
    }
}
