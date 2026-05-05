//
//  Capture.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import Foundation

public struct Capture: Equatable {
    public let id: UUID
    public let itemId: UUID
    public let imageRef: ImageRef
    public let capturedAt: Date
    public let memo: String?

    public init(
        id: UUID,
        itemId: UUID,
        imageRef: ImageRef,
        capturedAt: Date,
        memo: String? = nil
    ) {
        self.id = id
        self.itemId = itemId
        self.imageRef = imageRef
        self.capturedAt = capturedAt
        self.memo = memo
    }
}
