////
///  WDump.swift
//


import Foundation

public struct WDump: Codable {
    var root: WRoot
    var users: Set<WUser>
    var folders: Set<WFolder>
    var lists: Set<WList>
    var listPositions: Set<WListPosition>
    var settings: Set<WSetting>
    var reminders: Set<WReminder>

    var memberships: Set<WMembership>
    var tasks: Set<WTask>
    var taskPositions: Set<WTaskPosition>
    var subtasks: Set<WSubtask>
    var subtaskPositions: Set<WSubtaskPosition>
    var notes: Set<WNote>
    var files: Set<WFile>
    var taskComments: Set<WTaskComment>
    var taskCommentStates: Set<WTaskCommentsState>

    init() {
        root = WRoot()
        users = []
        folders = []
        lists = []
        listPositions = []
        settings = []
        reminders = []
        memberships = []
        tasks = []
        taskPositions = []
        subtasks = []
        subtaskPositions = []
        notes = []
        files = []
        taskComments = []
        taskCommentStates = []
    }
}
