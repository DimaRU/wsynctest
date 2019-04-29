////
///  APIKeys.swift
//

import Keys


// Mark: - API Keys

struct APIKeys {
    let clientId: String
    let clientSecret: String

    // MARK: Shared Keys
    static let `default`: APIKeys = {
        return APIKeys(
            clientId: WuTimerKeys().clientId,
            clientSecret: WuTimerKeys().clientSecret
            )
    }()

    static var shared = APIKeys.default

    // MARK: Initializers

    init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
}
