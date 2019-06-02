////
///  MappingType.swift
//

import Foundation

public enum MappingType: String, Codable {
    // these keys define the place in the JSON response where the WunderProvider
    // should look for the response data.

    case Feature                   = "feature"
    case File                      = "file"
    case Folder                    = "folder"
    case List                      = "list"
    case ListPosition              = "list_position"
    case Membership                = "membership"
    case Note                      = "note"
    case Reminder                  = "reminder"
    case Root                      = "root"
    case Setting                   = "setting"
    case Subtask                   = "subtask"
    case SubtaskPosition           = "subtask_position"
    case Task                      = "task"
    case TaskComment               = "task_comment"
    case TaskCommentsState         = "task_comments_state"
    case TaskPosition              = "task_position"
    case UnreadActivityCount       = "unread_activities_count"
    case User                      = "user"
    case Upload                    = "upload"
    case SettingRevision           = "setting_revision"
    case FolderRevision            = "folder_revision"
    case ListRevision              = "list_revision"
    case ListPositionRevision      = "list_position_revision"
    case TaskRevision              = "task_revision"
    case TaskPositionRevision      = "task_position_revision"
    case SubtaskRevision           = "subtask_revision"
    case FileRevision              = "file_revision"
    case NoteRevision              = "note_revision"
    case TaskCommentRevision       = "task_comment_revision"
    case ReminderRevision          = "reminder_revision"
    case SubtaskPositionRevision   = "subtask_position_revision"
    case TaskCommentsStateRevision = "task_comments_state_revision"
    case FeatureRevision           = "feature_revision"
    case MembershipRevision        = "membership_revision"
    case UserRevision              = "user_revision"
    case ListMembership            = "list_membership"
    case DesktopNotification       = "desktop_notification"
   
    var jsonableClass: JSONAble.Type {
        switch self {
        case .Feature:
            return WFeature.self
        case .File:
            return WFile.self
        case .Folder:
            return WFolder.self
        case .List:
            return WList.self
        case .ListPosition:
            return WListPosition.self
        case .Membership,
             .ListMembership:
            return WMembership.self
        case .Note:
            return WNote.self
        case .Reminder:
            return WReminder.self
        case .Root:
            return WRoot.self
        case .Setting:
            return WSetting.self
        case .Subtask:
            return WSubtask.self
        case .SubtaskPosition:
            return WSubtaskPosition.self
        case .Task:
            return WTask.self
        case .TaskComment:
            return WTaskComment.self
        case .TaskCommentsState:
            return WTaskCommentsState.self
        case .TaskPosition:
            return WTaskPosition.self
        case .UnreadActivityCount:
            return WUnreadActivityCount.self
        case .DesktopNotification:
            return WDesktopNotification.self
        case .User:
            return WUser.self
        case .Upload:
            return WUpload.self
        case .SettingRevision,
             .FolderRevision,
             .ListRevision,
             .TaskRevision,
             .SubtaskRevision,
             .ListPositionRevision,
             .TaskPositionRevision,
             .FileRevision,
             .NoteRevision,
             .TaskCommentRevision,
             .ReminderRevision,
             .SubtaskPositionRevision,
             .TaskCommentsStateRevision,
             .FeatureRevision,
             .MembershipRevision,
             .UserRevision:
            return WRevision.self
        }
    }

    var revisionableClass: Revisionable.Type {
        switch self {
        case .Feature:
            return WFeature.self
        case .File:
            return WFile.self
        case .Folder:
            return WFolder.self
        case .List:
            return WList.self
        case .ListPosition:
            return WListPosition.self
        case .Membership,
             .ListMembership:
            return WMembership.self
        case .Note:
            return WNote.self
        case .Reminder:
            return WReminder.self
        case .Root:
            return WRoot.self
        case .Setting:
            return WSetting.self
        case .Subtask:
            return WSubtask.self
        case .SubtaskPosition:
            return WSubtaskPosition.self
        case .Task:
            return WTask.self
        case .TaskComment:
            return WTaskComment.self
        case .TaskCommentsState:
            return WTaskCommentsState.self
        case .TaskPosition:
            return WTaskPosition.self
        case .User:
            return WUser.self
        case .SettingRevision,
             .FolderRevision,
             .ListRevision,
             .TaskRevision,
             .SubtaskRevision,
             .ListPositionRevision,
             .TaskPositionRevision,
             .FileRevision,
             .NoteRevision,
             .TaskCommentRevision,
             .ReminderRevision,
             .SubtaskPositionRevision,
             .TaskCommentsStateRevision,
             .FeatureRevision,
             .MembershipRevision,
             .UserRevision:
            return WRevision.self
        default:
            fatalError()
        }
    }

    init(object: Revisionable.Type) {
        switch object {
        case is WFeature.Type              : self = .Feature
        case is WFile.Type                 : self = .File
        case is WFolder.Type               : self = .Folder
        case is WList.Type                 : self = .List
        case is WTask.Type                 : self = .Task
        case is WMembership.Type           : self = .Membership
        case is WNote.Type                 : self = .Note
        case is WReminder.Type             : self = .Reminder
        case is WRoot.Type                 : self = .Root
        case is WSetting.Type              : self = .Setting
        case is WSubtask.Type              : self = .Subtask
        case is WTaskComment.Type          : self = .TaskComment
        case is WTaskCommentsState.Type    : self = .TaskCommentsState
        case is WListPosition.Type         : self = .ListPosition
        case is WTaskPosition.Type         : self = .TaskPosition
        case is WSubtaskPosition.Type      : self = .SubtaskPosition
        case is WUser.Type                 : self = .User
        default: fatalError()
        }
    }
    
    init(revisionType type: Revisionable.Type) {
        switch type {
        case is WFeature.Type              : self = .FeatureRevision
        case is WFile.Type                 : self = .FileRevision
        case is WFolder.Type               : self = .FolderRevision
        case is WList.Type                 : self = .ListRevision
        case is WTask.Type                 : self = .TaskRevision
        case is WMembership.Type           : self = .MembershipRevision
        case is WNote.Type                 : self = .NoteRevision
        case is WReminder.Type             : self = .ReminderRevision
        case is WSetting.Type              : self = .SettingRevision
        case is WSubtask.Type              : self = .SubtaskRevision
        case is WTaskComment.Type          : self = .TaskCommentRevision
        case is WTaskCommentsState.Type    : self = .TaskCommentsStateRevision
        case is WListPosition.Type         : self = .ListPositionRevision
        case is WTaskPosition.Type         : self = .TaskPositionRevision
        case is WSubtaskPosition.Type      : self = .SubtaskPositionRevision
        case is WUser.Type                 : self = .UserRevision
        default: fatalError()
        }
    }
}
