////
///  WBackup.swift
//

import Foundation

struct WBackup: Codable {
    public let user: Int
    public let exported: String
    public let data: WBackupData
    
    struct WBackupData: Codable {
        public let lists: [WList]
        public let tasks: [WTask]
        public let reminders: [WReminder]
        public let subtasks: [WSubtask]
        public let notes: [WNote]
        public let taskPositions: [WTaskPosition]
        public let subtaskPositions: [WSubtaskPosition]
    }
}
