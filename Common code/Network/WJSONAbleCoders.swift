////
///  WJSONAbleCoders.swift
//

import Foundation

struct WJSONAbleCoders {
    static let decoder: JSONDecoder = { //() -> JSONDecoder in
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom({decoder -> Date in
            
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            var tmpDate: Date?
            if dateStr.count == 24 {
                tmpDate = Date.iso8601FullFormatter.date(from: dateStr)
            } else {
                tmpDate = Date.iso8601Formatter.date(from: dateStr)
            }
            
            guard let date = tmpDate else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
            }
            
            return date
        })
        
        return decoder
    }()

    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(Date.iso8601FullFormatter)
        return encoder
    }()
}
