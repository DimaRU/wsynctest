////
///  String+OutputStream.swift
//

import Foundation

extension String {
    /// Write `String` to `OutputStream`
    ///
    /// - parameter stream:      Closed OutputStream
    func write(_ stream: OutputStream) {
        guard let data = self.data(using: .utf8, allowLossyConversion: true) else {
            fatalError()
        }
        data.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) in
            let pointer = rawBufferPointer.bindMemory(to: UInt8.self)
            let bytesWritten = stream.write(pointer.baseAddress!, maxLength: data.count)

            if bytesWritten < 0 {
                fatalError("\(stream.streamError!)")
            }
            guard bytesWritten == data.count else {
                fatalError("Requed: \(data.count), written: \(bytesWritten)")
            }
        }
    }
}
