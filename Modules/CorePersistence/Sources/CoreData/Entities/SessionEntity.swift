//
//  SessionEntity.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import CoreData
import Foundation

@objc(SessionEntity)
final class SessionEntity: NSManagedObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<SessionEntity> {
        NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
    }

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var status: String?
    @NSManaged var createdAt: Date?
    @NSManaged var updatedAt: Date?
    @NSManaged var closedAt: Date?
    @NSManaged var abandonedAt: Date?
}
