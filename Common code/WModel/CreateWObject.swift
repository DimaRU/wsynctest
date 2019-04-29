////
///  CreateWObject.swift
//

import Foundation
import PromiseKit


extension WList: CreateWObject {
    public init(title: String) {
        self.id = -1
        self.revision = 0
        self.title = title
        self.ownerId = nil
        self.ownerType = nil
        self.listType = nil
        self.`public` = nil
        self.createdAt = Date()
    }
    
    public static let createFieldList = ["title"]
}

extension WTask: CreateWObject {
    public init(listId: Int, title: String, starred: Bool = false) {
        self.id = -1
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
    }

    public static let createFieldList = ["list_id", "title", "starred"]
}

extension WSubtask: CreateWObject {
    public init(taskId: Int, title: String) {
        self.id = -1
        self.revision = 0
        self.taskId = taskId
        self.title = title
        self.completed = false
        self.createdAt = Date()
        self.createdById = nil
    }

    public static let createFieldList = ["task_id", "title"]
}

extension WNote {
    public init(taskId: Int, content: String) {
        self.id = -1
        self.revision = 0
        self.taskId = taskId
        self.content = content
    }

    public static let createFieldList = ["task_id", "content"]
}

extension WTaskComment: CreateWObject {
    public init(taskId: Int, text: String) {
        self.id = -1
        self.revision = 0
        self.text = text
        self.taskId = taskId
        self.author = WTaskComment.WAuthor.init(id: -2, name: "Dmitry", avatar: nil)
        self.localCreatedAt = Date()
        self.createdAt = Date()
    }
    
    public static let createFieldList = ["task_id", "text", "local_created_at"]
}

