//
//  MoneySnapshot.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import Foundation

public struct MoneySnapshot: Equatable {
    public let amount: Decimal
    public let currency: String
    public let rawText: String?

    public init(
        amount: Decimal,
        currency: String,
        rawText: String? = nil
    ) {
        self.amount = amount
        self.currency = currency
        self.rawText = rawText
    }
}
