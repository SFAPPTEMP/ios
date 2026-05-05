//
//  CaptureEntity.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import CoreData
import Foundation

@objc(CaptureEntity)
final class CaptureEntity: NSManagedObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CaptureEntity> {
        NSFetchRequest<CaptureEntity>(entityName: "CaptureEntity")
    }

    @NSManaged var id: String?
    @NSManaged var itemId: String?
    @NSManaged var imageRemoteUrl: String?
    @NSManaged var imageLocalPath: String?
    @NSManaged var capturedAt: Date?
    @NSManaged var memo: String?
}
