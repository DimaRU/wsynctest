////
///  CreateWObject.swift
//

import Foundation
import PromiseKit


extension WList {
    public init(id: Int, title: String) {
        self.id = id
        self.revision = 0
        self.title = title
        self.ownerId = nil
        self.ownerType = nil
        self.`public` = nil
        self.createdAt = Date()
        self.createdByRequestId = nil
    }
    
}

extension WTask {
    public init(id: Int, listId: Int, title: String, starred: Bool = false) {
        self.id = id
        self.revision = 0
        self.title = title
        self.completed = false
        self.starred = starred
        self.listId = listId
        self.recurrenceType = nil
        self.recurrenceCount = nil
        self.assigneeId = nil
        self.assignerId = nil
        self.dueDate = nil
        self.completedAt = nil
        self.completedById = nil
        self.createdById = nil
        self.createdAt = Date()
        self.createdByRequestId = nil
    }
}

extension WSubtask {
    public init(id: Int, taskId: Int, title: String) {
        self.id = id
        self.revision = 0
        self.taskId = taskId
        self.title = title
        self.completed = false
        self.createdAt = Date()
        self.createdById = nil
        self.createdByRequestId = nil
    }

}

extension WNote {
    public init(id: Int, taskId: Int, content: String) {
        self.id = id
        self.revision = 0
        self.taskId = taskId
        self.content = content
        self.createdByRequestId = nil
    }

}

extension WTaskComment {
    public init(id: Int, taskId: Int, text: String) {
        self.id = id
        self.revision = 0
        self.text = text
        self.taskId = taskId
        self.author = WTaskComment.WAuthor.init(id: -2, name: "Dmitry", avatar: nil)
        self.localCreatedAt = Date()
        self.createdAt = Date()
        self.createdByRequestId = nil
    }
}

extension WFolder {
    public init(id: Int, title: String, listIds: [Int]) {
        self.id = id
        self.revision = 0
        self.title = title
        self.listIds = listIds
        self.createdAt = Date()
        self.createdById = nil
        self.createdByRequestId = nil
        self.updatedAt = nil
        self.userId = nil
    }
}

extension WReminder {
    public init(id: Int, taskId: Int, date: Date) {
        self.id = id
        self.revision = 0
        self.taskId = taskId
        self.date = date
        self.createdAt = nil
        self.updatedAt = nil
        self.createdByRequestId = nil
    }
}
