//
//  SessionRepositoryTests.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import CoreData
import XCTest

import CoreDomain
import CorePersistence

final class SessionRepositoryTests: XCTestCase {
    private var stack: ClipyCoreDataStack!
    private var sut: CoreDataSessionRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        stack = try ClipyCoreDataStack(storeType: NSInMemoryStoreType)
        sut = CoreDataSessionRepository(stack: stack)
    }

    override func tearDown() {
        sut = nil
        stack = nil
        super.tearDown()
    }

    @MainActor
    func test_savedSession_restoresDomainAndViewState_forLocalReentry() async throws {
        let snapshot = makeDecidedSnapshot()

        try await sut.save(snapshot)
        let loaded = try await sut.loadSession(id: snapshot.session.id)

        XCTAssertEqual(loaded, snapshot)
        XCTAssertEqual(
            loaded?.viewState?.resolvedUIState(decisionCount: loaded?.session.decisions.count ?? 0),
            .reviewComparing
        )
    }

    @MainActor
    func test_savingSameSession_replacesItemsAndViewState_withoutStaleRows() async throws {
        let first = makePendingSnapshot(
            itemId: UUID(uuidString: "00000000-0000-0000-0000-000000000202")!,
            sourceUrl: "https://example.com/first",
            lastWebUrl: "https://example.com/first",
            bottomSheetState: .peek
        )
        let second = makePendingSnapshot(
            itemId: UUID(uuidString: "00000000-0000-0000-0000-000000000203")!,
            sourceUrl: "https://example.com/second",
            lastWebUrl: "https://example.com/second",
            bottomSheetState: .expanded
        )

        try await sut.save(first)
        try await sut.save(second)
        let loaded = try await sut.loadSession(id: second.session.id)

        XCTAssertEqual(loaded?.session.items.map(\.sourceUrl), ["https://example.com/second"])
        XCTAssertEqual(loaded?.viewState?.lastWebUrl, "https://example.com/second")
        XCTAssertEqual(loaded?.viewState?.bottomSheetState, .expanded)
    }

    @MainActor
    func test_savedSession_preservesOptionalItemValues_forLocalRestore() async throws {
        let item = makeItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000204")!,
            priceSnapshot: MoneySnapshot(amount: Decimal(string: "1299.99")!, currency: "USD", rawText: "$1,299.99"),
            thumbnailImage: ImageRef(
                remoteUrl: "https://example.com/images/thumb.png",
                localPath: "cache/thumb.png"
            )
        )
        let session = Session(
            id: .fixedSession,
            name: "Travel bag",
            status: .collecting,
            createdAt: .created,
            updatedAt: .updated,
            items: [item]
        )

        try await sut.save(SessionSnapshot(session: session))
        let loadedItem = try await sut.loadSession(id: session.id)?.session.items.first

        XCTAssertEqual(loadedItem?.priceSnapshot, item.priceSnapshot)
        XCTAssertEqual(loadedItem?.thumbnailImage, item.thumbnailImage)
        XCTAssertEqual(loadedItem?.note, item.note)
    }

    private func makeDecidedSnapshot() -> SessionSnapshot {
        let item = makeItem(id: .fixedItem)
        let decision = Decision(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000205")!,
            sessionId: .fixedSession,
            itemId: item.id,
            decidedAt: .decided
        )
        let session = Session(
            id: .fixedSession,
            name: "Travel bag",
            status: .decided,
            createdAt: .created,
            updatedAt: .updated,
            items: [item],
            decisions: [decision]
        )
        let viewState = SessionViewState(
            sessionId: session.id,
            lastWebUrl: item.sourceUrl,
            bottomSheetState: .expanded,
            lastOpenedAt: .opened
        )

        return SessionSnapshot(session: session, viewState: viewState)
    }

    private func makePendingSnapshot(
        itemId: UUID,
        sourceUrl: String,
        lastWebUrl: String,
        bottomSheetState: BottomSheetState
    ) -> SessionSnapshot {
        let item = makeItem(id: itemId, sourceUrl: sourceUrl)
        let session = Session(
            id: .fixedSession,
            name: "Travel bag",
            status: .pending,
            createdAt: .created,
            updatedAt: .updated,
            closedAt: .closed,
            items: [item]
        )
        let viewState = SessionViewState(
            sessionId: session.id,
            lastWebUrl: lastWebUrl,
            bottomSheetState: bottomSheetState,
            lastOpenedAt: .opened
        )

        return SessionSnapshot(session: session, viewState: viewState)
    }

    private func makeItem(
        id: UUID,
        sourceUrl: String = "https://example.com/products/clipy-case",
        priceSnapshot: MoneySnapshot? = nil,
        thumbnailImage: ImageRef? = nil
    ) -> Item {
        let capture = Capture(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000206")!,
            itemId: id,
            imageRef: ImageRef(remoteUrl: "https://example.com/images/capture.png"),
            capturedAt: .captured,
            memo: "front view"
        )

        return Item(
            id: id,
            sessionId: .fixedSession,
            sourceUrl: sourceUrl,
            productName: "Clipy Case",
            priceSnapshot: priceSnapshot,
            thumbnailImage: thumbnailImage,
            note: "Lightweight option",
            intentState: .interested,
            captures: [capture],
            createdAt: .created,
            updatedAt: .updated
        )
    }
}

private extension UUID {
    static let fixedSession = UUID(uuidString: "00000000-0000-0000-0000-000000000201")!
    static let fixedItem = UUID(uuidString: "00000000-0000-0000-0000-000000000202")!
}

private extension Date {
    static let created = Date(timeIntervalSince1970: 1_800_000_000)
    static let updated = Date(timeIntervalSince1970: 1_800_000_100)
    static let closed = Date(timeIntervalSince1970: 1_800_000_200)
    static let captured = Date(timeIntervalSince1970: 1_800_000_300)
    static let decided = Date(timeIntervalSince1970: 1_800_000_400)
    static let opened = Date(timeIntervalSince1970: 1_800_000_500)
}
