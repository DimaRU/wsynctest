////
///  WebsocketIO.swift
//

import Foundation
import Starscream

class WebSocketIO {
    
    let socket: WebSocket

    init(token: String, clientId: String) {
        let connectString = "wss://socket.wunderlist.com/api/v1/sync?client_id=\(clientId)&access_token=\(token)&client_device_id=\(WunderAPI.clientDeviceId)&client_instance_id=\(WunderAPI.clientInstanceId)"
        print(connectString)
        socket = WebSocket(url: URL(string: connectString)!)

        socket.delegate = self
        socket.connect()
    }
    
    deinit {
        if socket.isConnected {
            socket.disconnect()
        }
    }
    
    open func connect() {
        socket.connect()
    }

    open func write(_ string: String) {
        socket.write(string: string) {
            logStream(header: "WSS request:", string)
        }
    }
}


// MARK: Websocket Delegate Methods.

extension WebSocketIO: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        log("Websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error {
            log("websocket is disconnected: \(e.localizedDescription)")
        } else {
            log("websocket disconnected")
        }
        delay(5) {
            log("Reconnect")
            socket.connect()
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        logStream(header: "WSS reply:", text)
        WuWSSProvider.wssIncoming(message: text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        log("WSS binary: \(data.count) ---------------------")
    }
}
