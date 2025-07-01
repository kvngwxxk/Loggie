//
//  LoggieNetworkLog+CoreDataProperties.swift
//  Loggie
//
//  Created by Kangwook Lee on 5/27/25.
//
//

import Foundation
import CoreData


extension LoggieNetworkLog {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LoggieNetworkLog> {
        let req = NSFetchRequest<LoggieNetworkLog>(entityName: "LoggieNetworkLog")
        req.sortDescriptors = [NSSortDescriptor(key: #keyPath(LoggieNetworkLog.timestamp), ascending: false)]
        return req
    }
    @nonobjc public override class func entity() -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "LoggieNetworkLog",
                                          in: CoreDataManager.shared.context)!
    }
    
    @NSManaged public var source: String?
    @NSManaged public var duration: Double
    @NSManaged public var endPoint: String?
    @NSManaged public var id: UUID?
    @NSManaged public var method: String?
    @NSManaged public var requestBody: String
    @NSManaged public var requestURL: String?
    @NSManaged public var responseData: String
    @NSManaged public var responseStatusCode: Int16
    @NSManaged public var timestamp: Date?
    
}
