////
///  WBackup.swift
//

import Cocoa
import Alamofire

// MARK: Import/export whole content

struct WunderImport {

    func makeHeaders() -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "X-Access-Token": KeychainService.shared[.token]!,
            "X-Client-ID": APIKeys.shared.clientId,
            "x-client-device-id": WunderAPI.clientDeviceId,
            "x-client-instance-id": WunderAPI.clientInstanceId
        ]
        return headers
    }
    
    func importJson(json: String) {
        guard let data = json.data(using: .utf8) else {
            log("Wrong import json")
            return
        }
        
        Alamofire.upload(data, to: "https://backup.wunderlist.com/api/v1/import", headers: makeHeaders())
            .validate(statusCode: 200...200)
            .responseJSON { result in
                switch result.result {
                case .success:
                    log("Import Ok")
                case .failure(let error):
                    log(error.localizedDescription)
                }
        }
    }
    
    func importFile(path: String) {
        let fileUrl = URL(fileURLWithPath: path)
        
        Alamofire.upload(fileUrl, to: "https://backup.wunderlist.com/api/v1/import", headers: makeHeaders())
            .validate(statusCode: 200...200)
            .responseJSON { result in
                switch result.result {
                case .success:
                    log("Import Ok")
                case .failure(let error):
                    print(error)
                    log(error.localizedDescription)
                }
        }
    }
}

