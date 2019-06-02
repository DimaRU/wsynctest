////
///  WProvider.swift
//

//
//  WProvider.swift
//  wutest
//
//  Created by Dmitriy Borovikov on 03.08.17.
//  Copyright © 2017 Dmitriy Borovikov. All rights reserved.
//
import Moya
import Result
import Alamofire
import PromiseKit

class WProvider {
    typealias ErrorBlock = (Error) -> Void
    typealias RequestFuture = (target: WunderAPI, resolve: (Any) -> Void, reject: ErrorBlock)

    static let shared = WProvider()

    static func endpointClosure(_ target: WunderAPI) -> Endpoint {
        return Endpoint(url: url(target),
                        sampleResponseClosure: { return target.stubbedNetworkResponse },
                        method: target.method,
                        task: target.task,
                        httpHeaderFields: target.headers)
    }
    
    static func DefaultProvider() -> MoyaProvider<WunderAPI> {
        return MoyaProvider<WunderAPI>(endpointClosure: WProvider.endpointClosure,
                                       manager: WunderManager.manager,
                                       plugins: [
                                        NetworkLoggerPlugin(verbose: true)
            ])
    }


    static var defaultProvider: MoyaProvider<WunderAPI> = WProvider.DefaultProvider()
    static var moya: MoyaProvider<WunderAPI> {
        get {
            return defaultProvider
        }

        set {
            defaultProvider = newValue
        }
    }

    // MARK: - Public
    func request(_ target: WunderAPI) -> Promise<Data> {
        let (promise, resolver) = Promise<Data>.pending()
        sendRestRequest((target,
                     resolve: { rawData in resolver.fulfill(rawData as! Data) },
                     reject: resolver.reject))
        return promise
    }

    func request(_ target: WunderAPI) -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        assert(target.mappingType == nil)
        sendRequest((target,
                      resolve: { _ in resolver.fulfill(()) },
                      reject: resolver.reject))
        return promise
    }

    
    func request<T: JSONAble>(_ target: WunderAPI) -> Promise<T> {
        let (promise, resolver) = Promise<T>.pending()
        assert(target.mappingType != nil)
        assert(target.mappingType!.jsonableClass == T.self)
        sendRequest((target,
                       resolve: { rawData in self.parseData(data: rawData as! Data, resolver: resolver) },
                       reject: resolver.reject))
        return promise
    }
    
    func request<T: JSONAble>(_ target: WunderAPI) -> Promise<[T]> {
        let (promise, resolver) = Promise<[T]>.pending()
        assert(target.mappingType != nil)
        assert(target.mappingType!.jsonableClass == T.self)
        sendRequest((target,
                       resolve: { rawData in self.parseData(data: rawData as! Data, resolver: resolver) },
                       reject: resolver.reject))
        return promise
    }

    func request<T: WObject>(_ target: WunderAPI) -> Promise<Set<T>> {
        let (promise, resolver) = Promise<Set<T>>.pending()
        assert(target.mappingType != nil)
        assert(target.mappingType!.jsonableClass == T.self)
        sendRequest((target,
                      resolve: { rawData in self.parseData(data: rawData as! Data, resolver: resolver) },
                      reject: resolver.reject))
        return promise
    }
    
    private func sendRestRequest(_ request: RequestFuture) {
        print("Request:", request.target)
        WProvider.moya.request(request.target) { (result) in
            self.handleRequest(request: request, result: result)
        }
    }
    
    private func sendRequest(_ request: RequestFuture) {
        if WuWSSProvider.isConnected {
            print("Request:", request.target)
            WuWSSProvider.request(request.target, endpoint: WProvider.moya.endpoint(request.target)) { (result) in
                self.handleRequest(request: request, result: result)
            }
        } else {
            sendRestRequest(request)
        }
    }
}


// MARK: wunderRequest implementation
extension WProvider {
    
    // MARK: - Private
    
    fileprivate func handleRequest(request: RequestFuture, result: MoyaResult) {
        switch result {
        case let .success(moyaResponse):
            let data = moyaResponse.data
            let statusCode = moyaResponse.statusCode
            let headers = moyaResponse.response?.allHeaderFields
            let contentType = (headers?["content-type"] as? String) ?? ""
            
            switch statusCode {
            case 200...299, 300...399:
                request.resolve(data)
            case 401, 403:
                request.reject(WNetworkError.unauthorized)
            case 404:
                if !contentType.contains("application/json") {
                    self.retryBadResponce(request: request)
                } else {
                    request.reject(WNetworkError.notFound)
                }
            case 409:
                request.reject(WNetworkError.conflict)
            case 400, 405, 422:
                let errorMessage = WNetworkErrorMessage(data: data)
                request.reject(WNetworkError.replyError(code: statusCode, message: errorMessage))
            case 500, 502, 504:
                if !contentType.contains("application/json") {
                    self.retryBadResponce(request: request)
                } else {
                    let wError = WNetworkError.serverError(code: statusCode, data: String(data: data, encoding: .utf8))
                    request.reject(wError)
                }
            default:
                let wError = WNetworkError.serverError(code: statusCode, data: String(data: data, encoding: .utf8))
                request.reject(wError)
            }
            
        case .failure(let error):
            let wError = WNetworkError.unreachable(underlying: error)
            request.reject(wError)
        }
    }
    
    /// Parce response data
    fileprivate func parseData<T: Decodable>(data: Data, resolver: Resolver<T>) {
        do {
            let decoder = WJSONAbleCoders.decoder
            let jsonAble = try decoder.decode(T.self, from: data)
            resolver.fulfill(jsonAble)
        } catch {
            let werror = WNetworkError.replyDataError(underlying: error)
            print(T.self, error)
            resolver.reject(werror)
        }
    }
    
    //
    fileprivate func retryBadResponce(request: RequestFuture) {
        delay(0.01) {
            log("Retry bad request")
            self.sendRestRequest(request)
        }
    }
    
}
