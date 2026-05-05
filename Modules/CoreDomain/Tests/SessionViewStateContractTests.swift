//
//  SessionViewStateContractTests.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import XCTest

import CoreDomain

final class SessionViewStateContractTests: XCTestCase {
    func test_expandedBottomSheet_withoutDecision_resolvesComparing_forPendingReentry() {
        let viewState = SessionViewState(
            sessionId: .fixedSession,
            lastWebUrl: "https://example.com/products/clipy-case",
            bottomSheetState: .expanded,
            lastOpenedAt: .fixedNow
        )

        XCTAssertEqual(viewState.resolvedUIState(decisionCount: 0), .comparing)
    }

    func test_expandedBottomSheet_withDecision_resolvesReviewComparing_forDecidedReentry() {
        let viewState = SessionViewState(
            sessionId: .fixedSession,
            lastWebUrl: "https://example.com/products/clipy-case",
            bottomSheetState: .expanded,
            lastOpenedAt: .fixedNow
        )

        XCTAssertEqual(viewState.resolvedUIState(decisionCount: 1), .reviewComparing)
    }

    func test_hiddenOrPeekBottomSheet_resolvesBrowsingStates_forStoredViewState() {
        let hidden = SessionViewState(
            sessionId: .fixedSession,
            bottomSheetState: .hidden,
            lastOpenedAt: .fixedNow
        )
        let peek = SessionViewState(
            sessionId: .fixedSession,
            bottomSheetState: .peek,
            lastOpenedAt: .fixedNow
        )

        XCTAssertEqual(hidden.resolvedUIState(decisionCount: 0), .browsing)
        XCTAssertEqual(peek.resolvedUIState(decisionCount: 1), .reviewBrowsing)
    }

    func test_viewStateEnums_keepStableStoredValues_forLocalRestore() {
        XCTAssertEqual(BottomSheetState.allCases.map(\.rawValue), [
            "Hidden",
            "Peek",
            "Expanded"
        ])
        XCTAssertEqual(SessionUIState.allCases.map(\.rawValue), [
            "Browsing",
            "Comparing",
            "ReviewBrowsing",
            "ReviewComparing"
        ])
    }
}

private extension UUID {
    static let fixedSession = UUID(uuidString: "00000000-0000-0000-0000-000000000101")!
}

private extension Date {
    static let fixedNow = Date(timeIntervalSince1970: 1_800_000_000)
}
