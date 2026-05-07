//
//  SessionViewStateEntity.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import CoreData
import Foundation

@objc(SessionViewStateEntity)
final class SessionViewStateEntity: NSManagedObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<SessionViewStateEntity> {
        NSFetchRequest<SessionViewStateEntity>(entityName: "SessionViewStateEntity")
    }

    @NSManaged var sessionId: String?
    @NSManaged var lastWebUrl: String?
    @NSManaged var bottomSheetState: String?
    @NSManaged var lastOpenedAt: Date?
}
