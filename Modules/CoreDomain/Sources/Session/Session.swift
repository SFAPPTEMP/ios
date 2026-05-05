//
//  Session.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import Foundation

public struct Session: Equatable {
    public let id: UUID
    public let name: String?
    public let status: SessionStatus
    public let createdAt: Date
    public let updatedAt: Date
    public let closedAt: Date?
    public let abandonedAt: Date?
    public let items: [Item]
    public let decisions: [Decision]

    public init(
        id: UUID,
        name: String? = nil,
        status: SessionStatus,
        createdAt: Date,
        updatedAt: Date,
        closedAt: Date? = nil,
        abandonedAt: Date? = nil,
        items: [Item] = [],
        decisions: [Decision] = []
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.closedAt = closedAt
        self.abandonedAt = abandonedAt
        self.items = items
        self.decisions = decisions
    }
}

public enum SessionStatus: String, Equatable, CaseIterable {
    case draft = "Draft"
    case collecting = "Collecting"
    case pending = "Pending"
    case decided = "Decided"
    case abandoned = "Abandoned"
}
