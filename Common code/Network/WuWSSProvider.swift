////
///  WuWSSProvider.swift
//

import Foundation
import Moya
import Result
import Starscream


public class WuWSSProvider {
    let WSSHealthInterval = 20.0
    let WSSRequestTimeout = 15.0

    var healthTimer: Timer?

    internal struct RequestConfig {
        let completion: Completion
        let timer: Timer
        let target: WunderAPI?
    }
    
    internal struct Health: Decodable {
        let healthy: Bool
    }

    static internal var instance: WuWSSProvider = WuWSSProvider()

    var websocketProvider: WebSocketIO?
    var wssRequestList: [String: RequestConfig] = [:]

    
    public init() {
        healthTimer = Timer.scheduledTimer(withTimeInterval: WSSHealthInterval, repeats: true, block: healthPing)
    }
    
    deinit {
        healthTimer?.invalidate()
    }
    
    func healthPing(timer: Timer) {
        var headers: [String: String] = [:]
        let requestId = UUID().uuidString.lowercased()
        headers["x-client-id"] = APIKeys.shared.clientId
        headers["x-client-request-id"] = requestId
        let wssRequest = WunderWSSRequest(type: "health",
                                          headers: headers,
                                          verb: nil,
                                          uri: nil,
                                          body: nil)

        let encoder = WJSONAbleCoders.encoder
        let request = try! encoder.encode(wssRequest)

        let healthCompletion: Moya.Completion = { result in
            switch result {
            case .success(let responce):
                let decoder = WJSONAbleCoders.decoder
                if let health = try? decoder.decode(Health.self, from: responce.data) {
                    print("Healthy: \(health.healthy)")
                }
            case .failure(let error):
                print("Health timeout: \(error)")
            }
        }
        
        enqueueRequest(requestId: requestId, request: request, completion: healthCompletion, target: nil)
    }


    // MARK: Call after success authorisation
    static func websocketInit() {
        guard let token = KeychainService.shared[.token] else { return }
        
        let clientId = APIKeys.shared.clientId
        WuWSSProvider.instance.websocketProvider = WebSocketIO(token: token, clientId: clientId)
    }
    
    public static var isConnected: Bool {
        return WuWSSProvider.instance.websocketProvider?.socket.isConnected ?? false
    }

    public static func request(_ target: WunderAPI, endpoint: Endpoint, completion: @escaping Moya.Completion)  {
        WuWSSProvider.instance.processRequest(target, endpoint: endpoint, completion: completion)
    }

    internal func processRequest(_ target: WunderAPI, endpoint: Endpoint, completion: @escaping Moya.Completion)  {
        let (requestId, request) = encodeRequest(target, endpoint: endpoint)
        enqueueRequest(requestId: requestId, request: request, completion: completion, target: target)
    }
    
    func encodeRequest(_ target: WunderAPI, endpoint: Endpoint) -> (requestId: String, request: Data) {
        var urlRequest = try! endpoint.urlRequest()
        let requestId = urlRequest.allHTTPHeaderFields!["x-client-request-id"]!
        
        let body = urlRequest.httpBody != nil ? String(data: urlRequest.httpBody!, encoding: .utf8) : nil
        let wssRequest = WunderWSSRequest(type: "request",
                                          headers: urlRequest.allHTTPHeaderFields!,
                                          verb: urlRequest.httpMethod!,
                                          uri: urlRequest.url!.uri(),
                                          body: body)
        
        let encoder = WJSONAbleCoders.encoder
        let data = try! encoder.encode(wssRequest)
        return (requestId, data)
    }

    struct WunderWSSRequest: Encodable {
        let type: String
        let headers: [String: String]
        let verb: String?
        let uri: String?
        let body: String?
    }

    struct WunderWSSRequestReply {
        let type: String
        let status: Int
        let headers: [String: String]
        let body: String
    }
    
    public static func wssIncoming(message: String) {
        let data = message.data(using: .utf8)!
        let messageDict: [String: Any]
        do {
            messageDict = try JSONSerialization.jsonObject(with: data) as! [String : Any]
        } catch {
            log("WSS message is't serializable \(message)")
            log(error: error)
            return
        }

        guard let type = messageDict["type"] as? String else {
            log("WSS message has't type: \(message)")
            return
        }

        switch type {
        case "request":
            WuWSSProvider.instance.wssIncomingRequest(dict: messageDict)
        case "health":
            WuWSSProvider.instance.wssIncomingHealth(dict: messageDict)
        case "desktop_notification":
            WuWSSProvider.instance.wssDesktopNotification(data)
        case "mutation":
            WMutatedService.dump(data: data, dict: messageDict)
            WMutatedService.getObject(dict: messageDict)
        default:
            print(type, message)
            fatalError("Illegal wss type \(type)")
        }
    }
    
    func wssDesktopNotification(_ data: Data) {
        let decoder = WJSONAbleCoders.decoder
        if let desktopNotification = try? decoder.decode(WDesktopNotification.self, from: data) {
            log("Event: \(desktopNotification.event): \(desktopNotification.message)")
        }
    }
    
    func wssIncomingHealth(dict: [String: Any]) {
        guard let headers = dict["headers"] as? [String: String],
            let body = dict["body"],
            let requestId = headers["x-client-request-id"]
            else {
                log("Bad incoming health message content")
                return
        }
        
        guard let requestConfig = dequeueRequest(for: requestId) else {
            log("Request reply not match: \(requestId)")
            return
        }
        
        let data = (body as? String)?.data(using: .utf8)
        let responce = Moya.Response(statusCode: 0, data: data ?? Data.init(count: 0))
        
        requestConfig.completion(.success(responce))
    }

    func wssIncomingRequest(dict: [String: Any]) {
        guard let status = dict["status"] as? Int,
            let headers = dict["headers"] as? [String: String],
            let clientRequestId = headers["x-client-request-id"]
        else {
            log("Bad incoming reply wss message content")
            return
        }
        
        guard let requestConfig = dequeueRequest(for: clientRequestId) else {
            log("Request reply not match: \(clientRequestId)")
            return
        }
        
        let data: Data?
        if let body = dict["body"] {
            let contentType = headers["content-type"]  ?? ""
            switch contentType {
            case "application/json",
                 "application/json; charset=utf-8":
                data = (body as? String)?.data(using: .utf8)
            case "image/png":
                data = nil
            default:
                data = (body as? String)?.data(using: .utf8)
//                if (200...399).contains(status) {
                let target = requestConfig.target!
                log("WuWSS: status: \(status) Invalid content type: \(contentType), \(target)")
//                }
            }
        } else {
            data = nil
        }
        
        let url = URL.init(string: "wss://request")!
        let httpUrlResponce = HTTPURLResponse.init(url: url, statusCode: status, httpVersion: nil, headerFields: headers)
        let responce = Moya.Response.init(statusCode: status, data: data ?? Data.init(count: 0), request: nil, response: httpUrlResponce)

        requestConfig.completion(.success(responce))
    }
    
    @objc func replyTimeout(timer: Timer) {
        guard let requestConfig = dequeueRequest(for: timer.userInfo as! String) else {
            print("Timeout not math")
            return
        }
        let error = MoyaError.underlying(NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil), nil)
        requestConfig.completion(.failure(error))
    }
    
    internal func enqueueRequest(requestId: String, request: Data, completion: @escaping Moya.Completion, target: WunderAPI?) {
        let timer = Timer.scheduledTimer(timeInterval: WSSRequestTimeout, target: self, selector: #selector(replyTimeout), userInfo: requestId, repeats: false)
        let requestConfig = RequestConfig(completion: completion, timer: timer, target: target)
        let wssString = String(data: request, encoding: .utf8)!
        
        objc_sync_enter(self)
        wssRequestList[requestId] = requestConfig
        objc_sync_exit(self)
        
        websocketProvider?.write(wssString)
    }
    
    func dequeueRequest(for id: String) -> RequestConfig? {
        
        objc_sync_enter(self)
        let requestConfig = wssRequestList[id]
        if requestConfig != nil {
            requestConfig!.timer.invalidate()
            wssRequestList.removeValue(forKey: id)
        }
        objc_sync_exit(self)
        
        return requestConfig
    }
}
