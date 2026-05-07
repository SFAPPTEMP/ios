//
//  DecisionEntity.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import CoreData
import Foundation

@objc(DecisionEntity)
final class DecisionEntity: NSManagedObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<DecisionEntity> {
        NSFetchRequest<DecisionEntity>(entityName: "DecisionEntity")
    }

    @NSManaged var id: String?
    @NSManaged var sessionId: String?
    @NSManaged var itemId: String?
    @NSManaged var decidedAt: Date?
}
