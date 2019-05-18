////
///  CheckAppStore.swift
//

import XCTest
@testable import wsync

struct CheckAppStore {
    static private func diffWobjectSets<T: WObject>(setA: Set<T>, setB: Set<T>) {
        XCTAssertEqual(setA, setB, "Not equal: \(T.self), difference elements: \(setA.symmetricDifference(setB))")
        XCTAssertTrue(setA ==== setB, "Contents not equal")
        setB.forEach { XCTAssertTrue($0.syncState == .synced, "Not .synced state: \($0)") }
    }

    public static func compareAppData(appData: AppData, wdump: WDump) {

        XCTAssertEqual(wdump.root, appData.root, "root is not equal: \(wdump.root), \(appData.root)")
        CheckAppStore.diffWobjectSets(setA: wdump.users, setB: appData.users)
        CheckAppStore.diffWobjectSets(setA: wdump.folders, setB: appData.folders)
        CheckAppStore.diffWobjectSets(setA: wdump.lists, setB: appData.lists)
        CheckAppStore.diffWobjectSets(setA: wdump.listPositions, setB: appData.listPositions)
        CheckAppStore.diffWobjectSets(setA: wdump.settings, setB: appData.settings)
        CheckAppStore.diffWobjectSets(setA: wdump.reminders, setB: appData.reminders)

        CheckAppStore.diffWobjectSets(setA: wdump.memberships, setB: appData.memberships.set)
        CheckAppStore.diffWobjectSets(setA: wdump.tasks, setB: appData.tasks.set)
        CheckAppStore.diffWobjectSets(setA: wdump.taskPositions, setB: appData.taskPositions.set)
        CheckAppStore.diffWobjectSets(setA: wdump.subtasks, setB: appData.subtasks.set)
        CheckAppStore.diffWobjectSets(setA: wdump.subtaskPositions, setB: appData.subtaskPositions.set)
        CheckAppStore.diffWobjectSets(setA: wdump.notes, setB: appData.notes.set)
        CheckAppStore.diffWobjectSets(setA: wdump.files, setB: appData.files.set)
        CheckAppStore.diffWobjectSets(setA: wdump.taskComments, setB: appData.taskComments.set)
    }
}
