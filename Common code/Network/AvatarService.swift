////
///  AvatarService.swift
//

import Cocoa
import PromiseKit

// Load avatar image

struct WAvatar {
    
    static func loadCurrent(completion: @escaping (NSImage?) -> Void) {
        WuProvider.moya.request(WunderAPI.root)
            .then { (root: WRoot) -> Promise<Data> in
                WuProvider.moya.request(WunderAPI.avatar(userId: root.userId))
            }.done { (data) -> Void in
                let image = NSImage(data: data)
                completion(image)
            }.catch { error in
                log(error: error)
        }
    }
    
}
