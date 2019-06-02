////
///  StreamLog.swift
//

import Foundation


class StreamLog {
    static var shared: StreamLog?
    private let outputStream: OutputStream
    private let logQueue = DispatchQueue(label: "wtest.stream.log")
    private let formater = DateFormatter()

    init(directory: FileManager.SearchPathDirectory, filePath: String) {
        let fileURL = try! FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(filePath)
        guard let outputStream = OutputStream(url: fileURL, append: true) else {
            fatalError("StreamLog")
        }
        formater.dateFormat = "HH:mm:ss.SSS"
        self.outputStream = outputStream
        outputStream.open()
        StreamLog.shared = self
        
        let session = "\nSession start: \(Date())"
        StreamLog.logStream(session)
    }
    
    static func logStream(_ string: String) {
        let enddedString = string + "\n"
        StreamLog.shared?.logQueue.async {
            enddedString.write(StreamLog.shared!.outputStream)
        }
    }
    
    static func timeStamp() -> String {
        return StreamLog.shared?.formater.string(from: Date()) ?? ""
    }
    
    deinit {
        outputStream.close()
    }
}

public func logStream(_ string: String) {
    StreamLog.logStream(string)
}

public func logStream(header: String, _ msg: String) {
    StreamLog.logStream(StreamLog.timeStamp() + " " + header)
    StreamLog.logStream(msg)
}
