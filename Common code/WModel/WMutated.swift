////
///  WMutated.swift
//

import Foundation

public enum MutationOperation: String, Codable {
    case create
    case delete
    case update
    case touch
}

public struct WMutated: Codable {
    public let type: String
    public let recipientId: Int
    public let version: Int
    public let operation: MutationOperation
    public let data: ChangedData
    public let subject: Subject
    public let client: Client

    public struct ChangedData: Codable {
        public let revision: Int
    }
    
    public struct Subject: Codable {
        public struct Parent: Codable {
            public let id: Int
            public let type: String
        }
        
        public let id: Int
        public let type: MappingType
        public let revision: Int
        
        public let previousRevision: Int
        public let parents: [Parent]
        
    }
    
    public struct Client: Codable {
        public let id: String?
        public let requestId: String?
        public let deviceId: String?
        public let instanceId: String?
        public let userId: String?
        
    }
    
}

