//
//  ItemEntity.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import CoreData
import Foundation

@objc(ItemEntity)
final class ItemEntity: NSManagedObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ItemEntity> {
        NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
    }

    @NSManaged var id: String?
    @NSManaged var sessionId: String?
    @NSManaged var sourceUrl: String?
    @NSManaged var productName: String?
    @NSManaged var priceAmount: String?
    @NSManaged var priceCurrency: String?
    @NSManaged var priceRawText: String?
    @NSManaged var thumbnailRemoteUrl: String?
    @NSManaged var thumbnailLocalPath: String?
    @NSManaged var note: String?
    @NSManaged var intentState: String?
    @NSManaged var createdAt: Date?
    @NSManaged var updatedAt: Date?
}
