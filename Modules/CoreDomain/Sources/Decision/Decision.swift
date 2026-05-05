//
//  Decision.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import Foundation

public struct Decision: Equatable {
    public let id: UUID
    public let sessionId: UUID
    public let itemId: UUID
    public let decidedAt: Date

    public init(
        id: UUID,
        sessionId: UUID,
        itemId: UUID,
        decidedAt: Date
    ) {
        self.id = id
        self.sessionId = sessionId
        self.itemId = itemId
        self.decidedAt = decidedAt
    }
}
