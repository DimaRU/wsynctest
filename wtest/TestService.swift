////
///  TestService.swift
//

import PromiseKit
import Alamofire

struct TestService {

   let testFileContent = "[This is test file content]"

    private let queue = DispatchQueue(label: "wtest", qos: .background, attributes: [.concurrent])

    func createList(title: String) throws -> WList {
        let listProto = WList.init(title: title)
        let list = try create(from: listProto).wait()
        log("List created:")
        PrintContent.wprint(list)
        return list
    }
    
    func createTask(title: String, for listId: Int, starred: Bool = false) throws -> WTask {
        let taskProto = WTask.init(listId: listId, title: title, starred: starred)
        let task = try create(from: taskProto).wait()
        log("Task created:")
        PrintContent.wprint(task)
        return task
    }
    
    func createSubtask(title: String, for taskId: Int) throws -> WSubtask {
        let subtaskProto = WSubtask.init(taskId: taskId, title: title)
        let subtask = try create(from: subtaskProto).wait()
        log("Subtask created:")
        PrintContent.wprint([subtask], for: taskId)
        return subtask
    }
    
    func delete<T: WObject>(_ object: T) throws {
        try WAPI.delete(T.self, id: object.id, revision: object.revision).wait()
        log("\(T.typeName()) deleted\t\t\(object.id)")
    }
    
    func uploadFile(_ content: String, for taskId: Int) throws -> WFile {
        let uploadService = WUploadService()
        let data = content.data(using: .utf8, allowLossyConversion: false)

        let file: WFile = try uploadService.upload(data!, filename: "TestFile.txt", for: taskId).wait()
        log("File uploaded: \(file.fileName), size: \(file.fileSize)")
        return file
    }
    
    func downloadFile(_ fileId: Int) throws -> Data {
        let (data, _) = try WAPI.get(WFile.self, id: fileId)
            .then(on: self.queue) { (file: WFile) -> Promise<(data: Data, response: PMKAlamofireDataResponse)> in
                log("Download \(file.fileName):\(file.fileSize)\t\(file.contentType)")
                return Alamofire.request(file.url, method: .get).responseData()
            }.wait()
        let content = String(data: data, encoding: String.Encoding.utf8)
        log("--File content:--")
        log(content ?? "NULL")
        log("-- eof --")
        return data
    }
    
   
    func testList() throws {
        var list: WList
        list = try createList(title: "Test list")
        var newList = list
        newList.title = "Test list new title"
        list = try update(from: list, to: newList).wait()
        try delete(list)
    }

    func testTask() throws {
        var list: WList
        var task: WTask
        
        list = try createList(title: "Test list")
        task = try createTask(title: "Test task", for: list.id)
        var new = task
        new.title = "Test task new title"
        task = try update(from: task, to: new).wait()
        new = task
        new.starred = true
        task = try update(from: task, to: new).wait()
        new = task
        new.completed = true
        task = try update(from: task, to: new).wait()

        try delete(task)
        list = try WAPI.get(WList.self, id: list.id).wait()
        try delete(list)
    }

    func testSubtask() throws {
        var list: WList
        var task: WTask
        var subtask: WSubtask
        
        list = try createList(title: "Test list")
        task = try createTask(title: "Test task", for: list.id)

        subtask = try createSubtask(title: "Test subtask", for: task.id)
        var new = subtask
        new.title = "Test subtask new title"
        subtask = try update(from: subtask, to: new).wait()
        new = subtask
        subtask.completed = true
        subtask = try update(from: subtask, to: new).wait()
        try delete(subtask)
        
        task = try WAPI.get(WTask.self, id: task.id).wait()
        try delete(task)
        list = try WAPI.get(WList.self, id: list.id).wait()
        try delete(list)
    }

    func testFileIO() throws {
        var list: WList
        var task: WTask
        var file: WFile
        list = try createList(title: "Test list")
        task = try createTask(title: "Test task", for: list.id)
        
        file = try uploadFile(testFileContent, for: task.id)
        let data = try downloadFile(file.id)
        let content = String(data: data, encoding: .utf8)
        if testFileContent != content {
            log("File content is't equal source")
        }
        try delete(file)
        
        let commentText = "Test comment"
        let commentProto = WTaskComment.init(taskId: task.id, text: commentText)
        let comment = try create(from: commentProto).wait()
        let commentState = try WAPI.get(WTaskCommentsState.self, taskId: task.id).wait()
        PrintContent.wprint([comment], commentState, for: task.id)
        try! delete(comment)
        
        task = try WAPI.get(WTask.self, id: task.id).wait()
        try delete(task)
        list = try WAPI.get(WList.self, id: list.id).wait()
        try delete(list)
    }

    func update<T: WObject>(from: T, to: T) -> Promise<T> {
        assert(from.id == to.id, "Update object id is't equal")
        let params = to.updateParams(from: from)
        log("Update \(T.typeName()), id: \(from.id) revision: \(from.revision) params: \(params)")
        return WAPI.update(T.self, id: from.id, params: params, requestId: UUID().uuidString.lowercased())
    }

    func create<T: WObject & WCreatable>(from wobject: T) throws -> Promise<T> {
        let params = wobject.createParams()
        log("\(T.typeName()) created")
        return WAPI.create(T.self, params: params, requestId: UUID().uuidString.lowercased())
    }


    public func testAll() {
        queue.async {
            do {
                try self.testList()
                try self.testTask()
                try self.testSubtask()
                try self.testFileIO()
            } catch {
                log("Error in test \(String(describing: error))")
            }
        }
    }
}
