//
//  SessionViewState.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import Foundation

public struct SessionViewState: Equatable {
    public let sessionId: UUID
    public let lastWebUrl: String?
    public let bottomSheetState: BottomSheetState
    public let lastOpenedAt: Date

    public init(
        sessionId: UUID,
        lastWebUrl: String? = nil,
        bottomSheetState: BottomSheetState,
        lastOpenedAt: Date
    ) {
        self.sessionId = sessionId
        self.lastWebUrl = lastWebUrl
        self.bottomSheetState = bottomSheetState
        self.lastOpenedAt = lastOpenedAt
    }

    public func resolvedUIState(decisionCount: Int) -> SessionUIState {
        let hasDecision = decisionCount > 0

        switch (hasDecision, bottomSheetState) {
        case (false, .expanded):
            return .comparing
        case (true, .expanded):
            return .reviewComparing
        case (false, .hidden), (false, .peek):
            return .browsing
        case (true, .hidden), (true, .peek):
            return .reviewBrowsing
        }
    }
}

public enum BottomSheetState: String, Equatable, CaseIterable {
    case hidden = "Hidden"
    case peek = "Peek"
    case expanded = "Expanded"
}

public enum SessionUIState: String, Equatable, CaseIterable {
    case browsing = "Browsing"
    case comparing = "Comparing"
    case reviewBrowsing = "ReviewBrowsing"
    case reviewComparing = "ReviewComparing"
}
