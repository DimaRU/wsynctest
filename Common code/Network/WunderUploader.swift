////
///  WunderUploader.swift
//

import PromiseKit

class WunderUploader {
    let data: Data
    let upload: WUpload
    let (promise, resolver) = Promise<WUpload>.pending()

    init(upload: WUpload, data: Data) {
        self.data = data
        self.upload = upload
    }

    fileprivate func uploadRequestBuilder() -> URLRequest {
        var request: URLRequest

        let cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        let url = upload.part!.url

        request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "PUT"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("", forHTTPHeaderField: "Content-Type")
        request.setValue(upload.part!.authorization, forHTTPHeaderField: "Authorization")
        request.setValue(upload.part!.date, forHTTPHeaderField: "x-amz-date")
        request.httpBody = data
        
        return request
    }

    func start() -> Promise<WUpload> {

        let request = uploadRequestBuilder()

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            nextTick {
                let httpResponse = response as? HTTPURLResponse
                if let error = error {
                    self.resolver.reject(WNetworkError.networkError(underlying: error))
                    return
                }
                if let statusCode = httpResponse?.statusCode {
                    if statusCode >= 200 && statusCode < 300 {
                        self.resolver.fulfill(self.upload)
                    }
                    else {
                        self.resolver.reject(WNetworkError.serverError(code: statusCode, data: nil))
                    }
                } else {
                    self.resolver.reject(WNetworkError.serverError(code: 0, data: nil))
                }
            }
        })
        task.resume()

        return promise
    }

}
