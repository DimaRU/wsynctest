////
///  AvatarService.swift
//

import Cocoa
import PromiseKit

// Load avatar image

struct WAvatar {
    
    static func loadCurrent(completion: @escaping (Data) -> Void) {
        WProvider.shared.request(WunderAPI.root)
            .then { (root: WRoot) -> Promise<Data> in
                WProvider.shared.request(WunderAPI.avatar(userId: root.userId))
            }.done { data in
                completion(data)
            }.catch { error in
                log(error: error)
        }
    }
    
}
