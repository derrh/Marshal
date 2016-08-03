//
//  TestObjects.swift
//  Marshal
//
//  Created by J. B. Whiteley on 4/23/16.
//  Copyright © 2016 Utah iOS & Mac. All rights reserved.
//

import Foundation
import Marshal

struct Recording : Unmarshaling {
    enum Status:String {
        case None = "0"
        case Recorded = "-3"
        case Recording = "-2"
        case Unknown
    }
    
    enum RecGroup: String {
        case Deleted = "Deleted"
        case Default = "Default"
        case LiveTV = "LiveTV"
        case Unknown
    }
    
    // Date parsing is slow. Remove them so performance can focus on JSON mapping.
    //let startTs:NSDate?
    //let endTs:NSDate?
    let startTsStr:String
    let status:Status
    let recordId:String
    let recGroup:RecGroup
    
    init(object json:Marshaled) throws {
        //startTs = try? json.value(key: "StartTs")
        //endTs = try? json.value(key: "EndTs")
        startTsStr = try json.value(key: "StartTs")
        recordId = try json.value(key: "RecordId")
        status = (try? json.value(key: "Status")) ?? .Unknown
        recGroup = (try? json.value(key: "RecGroup")) ?? .Unknown
    }
}

struct Program : Unmarshaling {
    
    let title:String
    let chanId:String
    //let startTime:NSDate
    //let endTime:NSDate
    let description:String?
    let subtitle:String?
    let recording:Recording
    let season:Int?
    let episode:Int?
    
    init(object json: Marshaled) throws {
        try self.init(jsonObj:json)
    }
    
    init(jsonObj:Marshaled, channelId:String? = nil) throws {
        let json = jsonObj
        title = try json.value(key: "Title")
        
        if let channelId = channelId {
            self.chanId = channelId
        }
        else {
            chanId = try json.value(key: "Channel.ChanId")
        }
        //startTime = try json.value(key: "StartTime")
        //endTime = try json.value(key: "EndTime")
        description = try json.value(key: "Description")
        subtitle = try json.value(key: "SubTitle")
        recording = try json.value(key: "Recording")
        season = (try json.value(key: "Season") as String?).flatMap({Int($0)})
        episode = (try json.value(key: "Episode") as String?).flatMap({Int($0)})
    }
}

extension Date : ValueType {
    public static func value(any: Any) throws -> Date {
        guard let dateString = any as? String else {
            throw MarshalError.typeMismatch(expected: String.self, actual: any.dynamicType)
        }
        guard let date = Date.fromISO8601String(dateString) else {
            throw MarshalError.typeMismatch(expected: "ISO8601 date string", actual: dateString)
        }
        return date
    }
}

extension Date {
    static private let ISO8601MillisecondFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
        let tz = TimeZone(abbreviation:"GMT")
        formatter.timeZone = tz
        return formatter
    }()
    static private let ISO8601SecondFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
        let tz = TimeZone(abbreviation:"GMT")
        formatter.timeZone = tz
        return formatter
    }()
    
    static private let formatters = [ISO8601MillisecondFormatter,
                                     ISO8601SecondFormatter]
    
    static func fromISO8601String(_ dateString:String) -> Date? {
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return .none
    }
}

