////
///  WunderNetworkError.swift
//

import Foundation

public final class WNetworkErrorMessage {

    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let message = "message"
        static let translationKey = "translation_key"
        static let type = "type"
    }
    
    // MARK: Properties
    public var message: String?
    public var translationKey: String?
    public var type: String?
    public var extDescription: String? = nil
    
    // MARK: Initializers
    ///
    /// - parameter object: The object of either Dictionary or Array kind that was passed.
    /// - returns: An initialized instance of the class.
    public init?(data: Data) {

        guard let mappedJSON = try? JSONSerialization.jsonObject(with: data) else { return nil }
        guard let dictJSON = mappedJSON as? [String: Any] else { return nil }

        if var errorDict = dictJSON["error"] as? [String: Any] {
        message = errorDict[SerializationKeys.message] as? String
        translationKey = errorDict[SerializationKeys.translationKey] as? String
        type = errorDict[SerializationKeys.type] as? String
        
        errorDict[SerializationKeys.message] = nil
        errorDict[SerializationKeys.translationKey] = nil
        errorDict[SerializationKeys.type] = nil
        for (key, value) in errorDict {
            let desc: String
            switch value {
            case is String:
                desc = String(describing: value)
            case is [String]:
                desc = String(describing: value as! [String])
            case is Bool:
                desc = String(describing: value as! Bool)
            default:
                desc = String(describing: value)
            }
            extDescription = (extDescription == nil ? "" : "\n") + "\(key): \(desc)"
            }
        } else {
            extDescription = "Unknown"
        }
    }
}
