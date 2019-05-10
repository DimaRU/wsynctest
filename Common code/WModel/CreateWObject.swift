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
        self.createdByRequestId = UUID().uuidString
    }
    
    public static let createFieldList: [PartialKeyPath<WList>] = [\WList.title]
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
        self.createdByRequestId = UUID().uuidString
    }
    public static let createFieldList: [PartialKeyPath<WTask>] = [
        \WTask.listId,
        \WTask.title,
        \WTask.starred
    ]
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
        self.createdByRequestId = UUID().uuidString
    }

    public static let createFieldList: [PartialKeyPath<WSubtask>] = [
        \WSubtask.taskId,
        \WSubtask.title
    ]
}

extension WNote: CreateWObject {
    public init(taskId: Int, content: String) {
        self.id = -1
        self.revision = 0
        self.taskId = taskId
        self.content = content
        self.createdByRequestId = UUID().uuidString
    }

    public static let createFieldList: [PartialKeyPath<WNote>] = [
        \WNote.taskId,
        \WNote.content
    ]
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
        self.createdByRequestId = UUID().uuidString
    }
    
    public static let createFieldList: [PartialKeyPath<WTaskComment>] = [
        \WTaskComment.taskId,
        \WTaskComment.text,
        \WTaskComment.localCreatedAt
    ]
}

