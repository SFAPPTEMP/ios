//
//  Item.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import Foundation

public struct Item: Equatable {
    public let id: UUID
    public let sessionId: UUID
    public let sourceUrl: String
    public let productName: String?
    public let priceSnapshot: MoneySnapshot?
    public let thumbnailImage: ImageRef?
    public let note: String?
    public let intentState: ItemIntentState
    public let captures: [Capture]
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID,
        sessionId: UUID,
        sourceUrl: String,
        productName: String? = nil,
        priceSnapshot: MoneySnapshot? = nil,
        thumbnailImage: ImageRef? = nil,
        note: String? = nil,
        intentState: ItemIntentState,
        captures: [Capture] = [],
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.sourceUrl = sourceUrl
        self.productName = productName
        self.priceSnapshot = priceSnapshot
        self.thumbnailImage = thumbnailImage
        self.note = note
        self.intentState = intentState
        self.captures = captures
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum ItemIntentState: String, Equatable, CaseIterable {
    case interested = "Interested"
    case hold = "Hold"
    case dropped = "Dropped"
}
