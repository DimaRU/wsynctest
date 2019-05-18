////
///  WDumpProvider.swift
//

import Foundation
import Moya

extension WProvider {

    fileprivate static func testableClosure(_ wdump: WDump)  -> (_ target: WunderAPI) -> Endpoint {
        func getWObjectData<T: WObject>(from wobjectSet: Set<T>, target: WunderAPI) -> Data? {
            let encoder = WJSONAbleCoders.encoder

            let data: Data?
            switch target {
            case .loadWObject:
                data = try! encoder.encode(wobjectSet)
            case .loadWObjectById(_ , let id):
                if let wobject = wobjectSet[id] {
                    data = try! encoder.encode(wobject)
                } else {
                    data = nil
                }
            case .loadWObjectByTaskId(let type , let taskId):
                if type is TaskChild {
                    let subset = wobjectSet.filter{ ($0 as! TaskChild).taskId == taskId }
                    data = try! encoder.encode(subset)
                } else {
                    fatalError()
                }
            case .loadWObjectByListId(let type, let listId, let completed):
                switch type {
                case is WTask.Type:
                    let subset = wobjectSet.filter{ ($0 as! WTask).listId == listId && ($0 as! WTask).completed == completed }
                    data = try! encoder.encode(subset)
                case is ListChild:
                    let subset = wobjectSet.filter{ ($0 as! ListChild).listId == listId }
                    data = try! encoder.encode(subset)
                case is TaskChild:
                    let taskSet = Set<Int>(wdump.tasks.filter{ $0.listId == listId }.map { $0.id })
                    let subset = wobjectSet.filter{ taskSet.contains(($0 as! TaskChild).taskId) }
                    data = try! encoder.encode(subset)
                default: fatalError()
                }
            case .loadRevisions:
                let revisions = wobjectSet.map{ WRevision(storedSyncState: nil, id: $0.id, revision: $0.revision, type: .init(revisionType: T.self))}
                data = try! encoder.encode(revisions)
            case .loadRevisionsByTaskId(let type , let taskId):
                if type is TaskChild {
                    let subset = wobjectSet.filter{ ($0 as! TaskChild).taskId == taskId }
                        .map{ WRevision(storedSyncState: nil, id: $0.id, revision: $0.revision, type: .init(revisionType: T.self))}
                    data = try! encoder.encode(subset)
                } else {
                    fatalError()
                }
            case .loadRevisionsByListId(let type , let listId, let completed):
                switch type {
                case is WTask.Type:
                    let subset = wobjectSet.filter{ ($0 as! WTask).listId == listId && ($0 as! WTask).completed == completed }
                    data = try! encoder.encode(subset)
                case is ListChild:
                    let subset = wobjectSet.filter{ ($0 as! ListChild).listId == listId }
                    data = try! encoder.encode(subset)
                case is TaskChild:
                    let taskSet = Set<Int>(wdump.tasks.filter{ $0.listId == listId }.map { $0.id })
                    let subset = wobjectSet.filter{ taskSet.contains(($0 as! TaskChild).taskId) }
                        .map{ WRevision(storedSyncState: nil, id: $0.id, revision: $0.revision, type: .init(revisionType: T.self))}
                    data = try! encoder.encode(subset)
                default: fatalError()
                }
            case .root,
                 .user,
                 .avatar,
                 .unreadActivityCounts,
                 .createFile,
                 .upload,
                 .uploadFinish,
                 .createWObject,
                 .updateWObject,
                 .deleteWObject:
                fatalError()
            }
            return data
        }

        return { (target: WunderAPI) -> Endpoint in

            func wdumpResponce() -> EndpointSampleResponse {
                let encoder = WJSONAbleCoders.encoder
                switch target {
                case .root:
                    let data = try! encoder.encode(wdump.root)
                    return .networkResponse(200, data)
                case .user:
                    let userId = wdump.root.userId
                    let user = wdump.users[userId]!
                    let data = try! encoder.encode(user)
                    return .networkResponse(200, data)
                case .loadWObject(let type),
                     .loadWObjectById(let type, _),
                     .loadWObjectByTaskId(let type, _),
                     .loadWObjectByListId(let type, _, _),
                     .loadRevisions(let type),
                     .loadRevisionsByTaskId(let type, _),
                     .loadRevisionsByListId(let type, _, _):
                    let data: Data?
                    switch type {
                    case is WUser.Type: data = getWObjectData(from: wdump.users, target: target)
                    case is WFolder.Type: data = getWObjectData(from: wdump.folders, target: target)
                    case is WList.Type: data = getWObjectData(from: wdump.lists, target: target)
                    case is WListPosition.Type: data = getWObjectData(from: wdump.listPositions, target: target)
                    case is WSetting.Type: data = getWObjectData(from: wdump.settings, target: target)
                    case is WReminder.Type: data = getWObjectData(from: wdump.reminders, target: target)

                    case is WMembership.Type: data = getWObjectData(from: wdump.memberships, target: target)
                    case is WTask.Type: data = getWObjectData(from: wdump.tasks, target: target)
                    case is WTaskPosition.Type: data = getWObjectData(from: wdump.taskPositions, target: target)

                    case is WSubtask.Type: data = getWObjectData(from: wdump.subtasks, target: target)
                    case is WSubtaskPosition.Type: data = getWObjectData(from: wdump.subtaskPositions, target: target)
                    case is WNote.Type: data = getWObjectData(from: wdump.notes, target: target)
                    case is WFile.Type: data = getWObjectData(from: wdump.files, target: target)
                    case is WTaskComment.Type: data = getWObjectData(from: wdump.taskComments, target: target)
                    case is WTaskCommentsState.Type: data = getWObjectData(from: wdump.taskCommentStates, target: target)
                    default:
                        fatalError()
                    }
                    if let data = data {
                        return .networkResponse(200, data)
                    } else {
                        return .networkResponse(404, Data())
                    }
                case .createWObject,
                     .updateWObject,
                     .deleteWObject,
                     .unreadActivityCounts,
                     .avatar,
                     .createFile,
                     .upload,
                     .uploadFinish:
                    return .networkResponse(404, Data())
                }
            }

            return Endpoint(url: url(target),
                            sampleResponseClosure: wdumpResponce,
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
    }


    static func WDumpProvider(wdump: WDump) -> MoyaProvider<WunderAPI> {
        return MoyaProvider<WunderAPI>(endpointClosure: WProvider.testableClosure(wdump),
                                       stubClosure: MoyaProvider.immediatelyStub)
    }
}
