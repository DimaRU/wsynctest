////
///  WunderAPI.swift
//

import Foundation
import Moya
import Result

typealias MoyaResult = Result<Moya.Response, Moya.MoyaError>


// MARK: - Provider setup
/// URL constants
let API_DOMAIN = "https://a.wunderlist.com"


// MARK: - Provider support

public enum WunderAPI: TargetType {
    case root
    case user
    case avatar(userId: Int)
    case unreadActivityCounts
    
    case createFile(uploadId: Int, taskId: Int)
    case upload(fileName: String, fileSize: Int, contentType: String)
    case uploadFinish(uploadId: Int)

    case loadWObject(type: Revisionable.Type)
    case loadWObjectById(type: Revisionable.Type, id: Int)
    case loadWObjectByTaskId(type: Revisionable.Type, taskId: Int)
    case loadWObjectByListId(type: Revisionable.Type, listId: Int, completed: Bool)

    case loadRevisions(type: Revisionable.Type)
    case loadRevisionsByTaskId(type: Revisionable.Type, taskId: Int)
    case loadRevisionsByListId(type: Revisionable.Type, listId: Int, completed: Bool)

    case createWObject(type: Revisionable.Type, params: [String: Any], requestId: String)
    case updateWObject(type: Revisionable.Type, id: Int, params: [String: Any], requestId: String)
    case deleteWObject(type: Revisionable.Type, id: Int, revision: Int)
    
    func requestPath(type: Revisionable.Type) -> String {
        switch type {
        case is WFeature.Type              : return "features"
        case is WFile.Type                 : return "files"
        case is WFolder.Type               : return "folders"
        case is WList.Type                 : return "lists"
        case is WListPosition.Type         : return "list_positions"
        case is WMembership.Type           : return "memberships"
        case is WNote.Type                 : return "notes"
        case is WReminder.Type             : return "reminders"
        case is WSetting.Type              : return "settings"
        case is WSubtask.Type              : return "subtasks"
        case is WSubtaskPosition.Type      : return "subtask_positions"
        case is WTask.Type                 : return "tasks"
        case is WTaskComment.Type          : return "task_comments"
        case is WTaskCommentsState.Type    : return "task_comments_states"
        case is WTaskPosition.Type         : return "task_positions"
        case is WUser.Type                 : return "users"
        default: fatalError()
        }
    }

    func requestRevisionsPath(type: Revisionable.Type) -> String {
        switch type {
        case is WFeature.Type              : return "feature_revisions"
        case is WFile.Type                 : return "file_revisions"
        case is WFolder.Type               : return "folder_revisions"
        case is WList.Type                 : return "list_revisions"
        case is WListPosition.Type         : return "list_position_revisions"
        case is WMembership.Type           : return "membership_revisions"
        case is WNote.Type                 : return "note_revisions"
        case is WReminder.Type             : return "reminder_revisions"
        case is WSetting.Type              : return "setting_revisions"
        case is WSubtask.Type              : return "subtask_revisions"
        case is WSubtaskPosition.Type      : return "subtask_position_revisions"
        case is WTask.Type                 : return "task_revisions"
        case is WTaskComment.Type          : return "task_comment_revisions"
        case is WTaskCommentsState.Type    : return "task_comments_state_revisions"
        case is WTaskPosition.Type         : return "task_position_revisions"
        case is WUser.Type                 : return "user_revisions"
        default: fatalError()
        }
    }

    var mappingType: MappingType? {
        switch self {
        case .root                 : return .Root
        case .unreadActivityCounts : return .UnreadActivityCount
        case .avatar               : return nil
        case .createFile           : return .File
        case .upload               : return .Upload
        case .uploadFinish         : return .Upload
        case .user                 : return .User
        case .deleteWObject        : return nil
        case .loadWObject(let type),
             .loadWObjectById(let type, _),
             .loadWObjectByTaskId(let type, _),
             .loadWObjectByListId(let type, _, _),
             .createWObject(let type, _, _),
             .updateWObject(let type, _, _, _):
            return MappingType(object: type)
        case .loadRevisions(let type),
             .loadRevisionsByTaskId(let type, _),
             .loadRevisionsByListId(let type, _, _):
            return MappingType(revisionType: type)
        }
    }
}

extension WunderAPI {
    
    public var method: Moya.Method {
        switch self {
        case .avatar:
            return .get
        case .root,
             .user,
             .unreadActivityCounts:
            return .get
        case .upload,
            .createFile:
            return .post
        case .uploadFinish:
            return .patch
        case .loadWObject,
             .loadWObjectById,
             .loadWObjectByTaskId,
             .loadWObjectByListId,
             .loadRevisions,
             .loadRevisionsByTaskId,
             .loadRevisionsByListId:
            return .get
        case .createWObject:
            return .post
        case .updateWObject:
            return .patch
        case .deleteWObject:
            return .delete
        }
    }
}

extension WunderAPI {
    
    public var path: String {
        switch self {
        case .root:
            return "root"
        case .unreadActivityCounts:
            return "unread_activity_counts"
        case .avatar:
            return "avatar"
        case .upload:
            return "uploads"
        case .uploadFinish(let uploadId):
            return "uploads/\(uploadId)"
        case .createFile:
            return "files"
        case .user:
            return "user"
        case .loadWObject(let type):
            return requestPath(type: type)
        case .loadWObjectById(let type, let id):
            return requestPath(type: type) + "/\(id)"
        case .loadWObjectByTaskId(let type, _):
            return requestPath(type: type)
        case .loadWObjectByListId(let type, _, _):
            return requestPath(type: type)
        case .createWObject(let type, _, _):
            return requestPath(type: type)
        case .updateWObject(let type, let id, _, _):
            return requestPath(type: type) + "/\(id)"
        case .deleteWObject(let type, let id, _):
            return requestPath(type: type) + "/\(id)"
        case .loadRevisions(let type),
             .loadRevisionsByTaskId(let type, _),
             .loadRevisionsByListId(let type, _, _):
            return requestRevisionsPath(type: type)
        }
    }
}

extension WunderAPI {
  
    public var baseURL: URL {
        var apiVersion = "/api/v1/"
        switch self {
        case .loadWObject(let type),
             .loadWObjectById(let type, _),
             .loadWObjectByTaskId(let type, _),
             .loadWObjectByListId(let type, _, _),
             .createWObject(let type, _, _),
             .updateWObject(let type, _, _, _),
             .deleteWObject(let type, _, _),
             .loadRevisions(let type),
             .loadRevisionsByTaskId(let type, _),
             .loadRevisionsByListId(let type, _, _):
            if type is WFile.Type {
                apiVersion = "/api/v2/"
            }
        default:
            break
        }
        return URL(string: API_DOMAIN + apiVersion)!
    }
    
    
    
    public var task: Task {
        switch self {
        case .avatar(let userId):
            return .requestParameters(parameters: ["user_id" : userId], encoding: WunderAPI.urlEncoding)
        case .root,
             .unreadActivityCounts,
             .user:
            return .requestPlain
        case .upload(let fileName, let fileSize, let contentType):
            return .requestParameters(parameters: [
                "file_name" : fileName,
                "file_size" : fileSize,
                "content_type" : contentType
            ], encoding: JSONEncoding.default)
        case .uploadFinish:
            return .requestParameters(parameters: ["state" : "finished"], encoding: JSONEncoding.default)
        case .createFile(let uploadId, let taskId):
            return .requestParameters(parameters: [
                "upload_id" : uploadId,
                "task_id" : taskId,
                "local_created_at" : Date().iso8601
            ], encoding: JSONEncoding.default)
        case .loadWObjectByListId( let type, let listId, let completed),
             .loadRevisionsByListId( let type, let listId, let completed):
            var params: [String: Any] = ["list_id" : listId]
            
            if completed {
                if type is WTask.Type {
                    params["completed"] = completed
                } else {
                    params["completed_tasks"] = completed
                }
            }
            return .requestParameters(parameters: params, encoding: WunderAPI.urlEncoding)
        case .loadRevisionsByTaskId( _, let taskId),
             .loadWObjectByTaskId( _, let taskId):
            return .requestParameters(parameters: ["task_id" : taskId], encoding: WunderAPI.urlEncoding)
        case .createWObject( _, let params, _):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .updateWObject( _, _, let params, _):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .deleteWObject( _,  _, let revision):
            return .requestParameters(parameters: ["revision" : revision], encoding: WunderAPI.urlEncoding)
        case .loadWObject,
             .loadWObjectById,
             .loadRevisions:
            return .requestPlain
        }
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return stubbedData("none")
        }
    }

    var stubbedNetworkResponse: EndpointSampleResponse {
        switch self {
        default:
            return .networkResponse(200, sampleData)
        }
    }

    static let clientInstanceId = UUID().uuidString.lowercased()
    static let clientDeviceId = getHwUUID().lowercased()

    public var headers: [String : String]? {
        
        var assigned: [String: String] = [
            "Accept"               : "application/json",
            "Content-Type"         : "application/json",
            "X-Client-ID"          : APIKeys.shared.clientId,
            "x-client-instance-id" : WunderAPI.clientInstanceId,
            "x-client-device-id"   : WunderAPI.clientDeviceId
            ]

        assigned["X-Access-Token"] = KeychainService.shared[.token]

        switch self {
        case .createWObject( _, _, let requestId),
             .updateWObject( _, _, _, let requestId):
            assigned["x-client-request-id"] = requestId
        default:
            assigned["x-client-request-id"] = UUID().uuidString.lowercased()
        }

        return assigned
    }

    static let urlEncoding = URLEncoding(destination: .methodDependent, arrayEncoding: .noBrackets, boolEncoding: .literal)
}

// MARK: - Provider support
func stubbedData(_ filename: String) -> Data {
    let bundle = Bundle.main
    let path = bundle.path(forResource: filename, ofType: "json")
    return (try! Data(contentsOf: URL(fileURLWithPath: path!)))
}

private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}

func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

func += <KeyType, ValueType> (left: inout [KeyType: ValueType], right: [KeyType: ValueType]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}
