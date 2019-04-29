////
///  WMutatedService.swift
//

import Foundation

struct WMutatedService {
    
    private init() {}
    
    static func dump(data: Data, dict: [String: Any]) {
        
        let decoder = WJSONAbleCoders.decoder
        do {
            let mutated = try decoder.decode(WMutated.self, from: data)
            let s = "\(mutated.operation.rawValue)\t" +
                "\(mutated.subject.type.rawValue):\(mutated.subject.id)\t" +
            "\(mutated.subject.previousRevision)->\(mutated.subject.revision)\t"
            log(s)
            var changedData = dict["data"] as! [String : Any]
            var keyList = "\tdata: revision:\(changedData["revision"] as! Int)"
            for (key, _) in changedData {
                if key == "revision" { continue }
                keyList += " " + key
            }
            log(keyList)
            mutated.subject.parents.forEach { log("\tparent: \($0.type): \($0.id)") }
            
        } catch {
            log(error: error)
        }
    }
    
    
    static func decodeData(_ type: MappingType, from data: Data) -> JSONAble? {
        let decoder = WJSONAbleCoders.decoder
        
        do {
                switch type {
                case .Feature:
                    return try decoder.decode(WFeature.self, from: data)
                case .File:
                    return try decoder.decode(WFile.self, from: data)
                case .Folder:
                    return try decoder.decode(WFolder.self, from: data)
                case .List:
                    return try decoder.decode(WList.self, from: data)
                case .ListPosition:
                    return try decoder.decode(WListPosition.self, from: data)
                case .Membership,
                     .ListMembership:
                    return try decoder.decode(WMembership.self, from: data)
                case .Note:
                    return try decoder.decode(WNote.self, from: data)
                case .Reminder:
                    return try decoder.decode(WReminder.self, from: data)
                case .Root:
                    return try decoder.decode(WRoot.self, from: data)
                case .Setting:
                    return try decoder.decode(WSetting.self, from: data)
                case .Subtask:
                    return try decoder.decode(WSubtask.self, from: data)
                case .SubtaskPosition:
                    return try decoder.decode(WSubtaskPosition.self, from: data)
                case .Task:
                    return try decoder.decode(WTask.self, from: data)
                case .TaskComment:
                    return try decoder.decode(WTaskComment.self, from: data)
                case .TaskCommentsState:
                    return try decoder.decode(WTaskCommentsState.self, from: data)
                case .TaskPosition:
                    return try decoder.decode(WTaskPosition.self, from: data)
                case .User:
                    return try decoder.decode(WUser.self, from: data)
                default:
                    fatalError()
            }
        } catch {
            log(error: error)
            return nil
        }
    }
    
    
    static func getObject(dict: [String: Any]) {
        var dataDict = dict["data"] as! [String : Any]
        let subjectDict = dict["subject"] as! [String: Any]
        let operation = MutationOperation(rawValue: dict["operation"] as! String)!
        dataDict["type"] = subjectDict["type"]
        dataDict["id"] = subjectDict["id"]
        let mappingType = MappingType(rawValue: subjectDict["type"] as! String)!
        
        let objectData = try! JSONSerialization.data(withJSONObject: dataDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        print("\(operation.rawValue) \(mappingType.rawValue):\(subjectDict["id"] as! Int)")
        
        switch operation {
        case .create:
            if let object: JSONAble = WMutatedService.decodeData(mappingType, from: objectData) {
                print(object)
            }
        case .update:
            print(String(data: objectData, encoding: .utf8)!)
        case .delete:
            print(String(data: objectData, encoding: .utf8)!)
        case .touch:
            print(String(data: objectData, encoding: .utf8)!)
        }
        

    }
}
