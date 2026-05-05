//
//  DomainModelBaselineTests.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import XCTest
import CoreDomain

// 이 suite는 다른 모듈들이 함께 쓰는 public domain contract를 고정합니다.
// 내부 동작을 직접 검증해야 한다면 별도 test suite에서 @testable import를 검토합니다.

final class DomainModelContractTests: XCTestCase {
    func test_draftSession_hasNoItemsOrDecisions_asEmptyComparisonContext() {
        let session = Session(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            status: .draft,
            createdAt: .fixedNow,
            updatedAt: .fixedNow
        )

        XCTAssertEqual(session.status, .draft)
        XCTAssertTrue(session.items.isEmpty)
        XCTAssertTrue(session.decisions.isEmpty)
    }

    func test_decidedSession_linksDecisionToSelectedItem_preservingItemContext() {
        let sessionId = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let itemId = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
        let capture = Capture(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            itemId: itemId,
            imageRef: ImageRef(remoteUrl: "https://example.com/images/item.png"),
            capturedAt: .fixedNow
        )
        let item = Item(
            id: itemId,
            sessionId: sessionId,
            sourceUrl: "https://example.com/products/clipy-case",
            note: "Lightweight option",
            intentState: .interested,
            captures: [capture],
            createdAt: .fixedNow,
            updatedAt: .fixedNow
        )
        let decision = Decision(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            sessionId: sessionId,
            itemId: itemId,
            decidedAt: .fixedNow
        )

        let session = Session(
            id: sessionId,
            name: "Travel bag",
            status: .decided,
            createdAt: .fixedNow,
            updatedAt: .fixedNow,
            items: [item],
            decisions: [decision]
        )

        XCTAssertEqual(session.items.map(\.sessionId), [session.id])
        XCTAssertEqual(session.items.flatMap(\.captures).map(\.itemId), [itemId])
        XCTAssertEqual(session.decisions.map(\.itemId), [itemId])
        XCTAssertEqual(session.items.first?.note, "Lightweight option")
    }

    func test_domainStates_keepStableStoredValues_forLocalRestore() {
        XCTAssertEqual(SessionStatus.allCases.map(\.rawValue), [
            "Draft",
            "Collecting",
            "Pending",
            "Decided",
            "Abandoned"
        ])
        XCTAssertEqual(ItemIntentState.allCases.map(\.rawValue), [
            "Interested",
            "Hold",
            "Dropped"
        ])
    }
}

private extension Date {
    static let fixedNow = Date(timeIntervalSince1970: 0)
}
