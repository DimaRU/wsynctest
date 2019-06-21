////
///  WSetting.swift
//

import Foundation

public struct WSetting: WObject {
    public var storedSyncState: WSyncState? = .created
    public let id: Int
    public var revision: Int
    public let type: MappingType = .Setting
    public let createdByRequestId: WRequestId?

    public let key: SettingsKey
    public var value: String

// sourcery:inline:auto:WSetting.property
public static let storedProperty: [PartialKeyPath<WSetting>:String] = [
        \WSetting.id :"id",
        \WSetting.revision :"revision",
        \WSetting.type :"type",
        \WSetting.createdByRequestId :"created_by_request_id",
        \WSetting.key :"key",
        \WSetting.value :"value"
    ]

public static let mutableProperty: [PartialKeyPath<WSetting>:String] = [
        \WSetting.value :"value"
    ]
// sourcery:end
}

public enum SettingsKey: String, Codable {
    case accountLocale
    case automaticReminders
    case background
    case behaviorStarTasksToTop
    case confirmDeleteEntity
    case migratedWunderlistOneUser
    case newsletterSubscriptionEnabled
    case newTaskLocation
    case notificationsDesktopEnabled
    case notificationsEmailEnabled
    case notificationsPushEnabled
    case printCompletedItems
    case showCompletedItems
    case showSubtaskProgress
    case smartDates
    case smartDatesRemoveFromTodo
    case smartlistVisibilityAll
    case smartlistVisibilityAssignedToMe
    case smartlistVisibilityDone
    case smartlistVisibilityStarred
    case smartlistVisibilityToday
    case smartlistVisibilityWeek
    case soundCheckoffEnabled
    case soundNotificationEnabled
    case startOfWeek
    case todaySmartListVisibleTasks
    case webAddToChrome
    case webAddToFirefox
    case webAppFirstUsed
    case webChromeAppRatingLater
    case webChromeRatingLater
    case webDateFormat
    case webEnableHtmlContextMenus
    case webEnableNaturalDateRecognition
    case webId
    case webLanguage
    case webLastOpenAppDate
    case webLocale
    case webNewInstallation
    case webOnboardingAddTodo
    case webOnboardingClickCreateList
    case webOnboardingClickShareList
    case webProTrialLimitAssigning
    case webProTrialLimitComments
    case webProTrialLimitFiles
    case webShortcutAddNewList
    case webShortcutAddNewTask
    case webShortcutCopyTasks
    case webShortcutDelete
    case webShortcutGotoFilterAll
    case webShortcutGotoFilterAssigned
    case webShortcutGotoFilterCompleted
    case webShortcutGotoFilterStarred
    case webShortcutGotoFilterToday
    case webShortcutGotoFilterWeek
    case webShortcutGotoInbox
    case webShortcutGotoPreferences
    case webShortcutGotoSearch
    case webShortcutMarkTaskDone
    case webShortcutMarkTaskStarred
    case webShortcutPasteTasks
    case webShortcutSelectAllTasks
    case webShortcutSendViaEmail
    case webShortcutShowNotifications
    case webShortcutSync
    case webSignificantEventCount
    case webTimeFormat
    case webType
    case webWebappSidebarFolderGuideDidShow
    
    case unknown
}

extension SettingsKey {
    fileprivate static func convertFromSnakeCase(_ stringKey: String) -> String {
        var components = stringKey.split(separator: "_")
        guard components.count > 1 else {
            // No underscores in key, leave the word as is - maybe already camel cased
            return stringKey
        }
        return ([components[0].lowercased()] + components[1...].map { $0.capitalized }).joined()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try SettingsKey.convertFromSnakeCase(container.decode(String.self))
        if raw.isEmpty {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot initialize SettingsKey from an empty string"
            )
        }
        if let rezult = SettingsKey(rawValue: raw) {
            self = rezult
        } else {
            self = .unknown
        }
    }
    
}
