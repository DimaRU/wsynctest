////
///  WunderManager.swift
//

import Alamofire
//import WunderCerts


struct WunderManager {
    static var serverTrustPolicies: [String: ServerTrustPolicy] {
        let policyDict: [String: ServerTrustPolicy]
        policyDict = [:]
        return policyDict
    }

    static var manager: SessionManager {
        let config = URLSessionConfiguration.default
        config.sharedContainerIdentifier = "group.wunder.Wunder"
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        return SessionManager(
            configuration: config,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: WunderManager.serverTrustPolicies)
        )
    }

}
