//
//  SessionEntityMapper.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import Foundation

import CoreDomain

enum SessionEntityMapper {
    static func apply(_ session: Session, to entity: SessionEntity) {
        entity.id = session.id.uuidString
        entity.name = session.name
        entity.status = session.status.rawValue
        entity.createdAt = session.createdAt
        entity.updatedAt = session.updatedAt
        entity.closedAt = session.closedAt
        entity.abandonedAt = session.abandonedAt
    }

    static func session(
        from entity: SessionEntity,
        items: [Item],
        decisions: [Decision]
    ) throws -> Session {
        let id = try uuid(entity.id, field: "SessionEntity.id")
        let statusText = try required(entity.status, entity: "SessionEntity", field: "status")
        guard let status = SessionStatus(rawValue: statusText) else {
            throw PersistenceMappingError.invalidEnum(field: "SessionEntity.status", value: statusText)
        }

        return Session(
            id: id,
            name: entity.name,
            status: status,
            createdAt: try required(entity.createdAt, entity: "SessionEntity", field: "createdAt"),
            updatedAt: try required(entity.updatedAt, entity: "SessionEntity", field: "updatedAt"),
            closedAt: entity.closedAt,
            abandonedAt: entity.abandonedAt,
            items: items,
            decisions: decisions
        )
    }

    static func apply(_ item: Item, to entity: ItemEntity) {
        entity.id = item.id.uuidString
        entity.sessionId = item.sessionId.uuidString
        entity.sourceUrl = item.sourceUrl
        entity.productName = item.productName
        entity.priceAmount = item.priceSnapshot.map { NSDecimalNumber(decimal: $0.amount).stringValue }
        entity.priceCurrency = item.priceSnapshot?.currency
        entity.priceRawText = item.priceSnapshot?.rawText
        entity.thumbnailRemoteUrl = item.thumbnailImage?.remoteUrl
        entity.thumbnailLocalPath = item.thumbnailImage?.localPath
        entity.note = item.note
        entity.intentState = item.intentState.rawValue
        entity.createdAt = item.createdAt
        entity.updatedAt = item.updatedAt
    }

    static func item(from entity: ItemEntity, captures: [Capture]) throws -> Item {
        let id = try uuid(entity.id, field: "ItemEntity.id")
        let sessionId = try uuid(entity.sessionId, field: "ItemEntity.sessionId")
        let intentText = try required(entity.intentState, entity: "ItemEntity", field: "intentState")
        guard let intentState = ItemIntentState(rawValue: intentText) else {
            throw PersistenceMappingError.invalidEnum(field: "ItemEntity.intentState", value: intentText)
        }

        return Item(
            id: id,
            sessionId: sessionId,
            sourceUrl: try required(entity.sourceUrl, entity: "ItemEntity", field: "sourceUrl"),
            productName: entity.productName,
            priceSnapshot: try moneySnapshot(from: entity),
            thumbnailImage: thumbnailImage(from: entity),
            note: entity.note,
            intentState: intentState,
            captures: captures,
            createdAt: try required(entity.createdAt, entity: "ItemEntity", field: "createdAt"),
            updatedAt: try required(entity.updatedAt, entity: "ItemEntity", field: "updatedAt")
        )
    }

    static func apply(_ capture: Capture, to entity: CaptureEntity) {
        entity.id = capture.id.uuidString
        entity.itemId = capture.itemId.uuidString
        entity.imageRemoteUrl = capture.imageRef.remoteUrl
        entity.imageLocalPath = capture.imageRef.localPath
        entity.capturedAt = capture.capturedAt
        entity.memo = capture.memo
    }

    static func capture(from entity: CaptureEntity) throws -> Capture {
        Capture(
            id: try uuid(entity.id, field: "CaptureEntity.id"),
            itemId: try uuid(entity.itemId, field: "CaptureEntity.itemId"),
            imageRef: ImageRef(
                remoteUrl: try required(entity.imageRemoteUrl, entity: "CaptureEntity", field: "imageRemoteUrl"),
                localPath: entity.imageLocalPath
            ),
            capturedAt: try required(entity.capturedAt, entity: "CaptureEntity", field: "capturedAt"),
            memo: entity.memo
        )
    }

    static func apply(_ decision: Decision, to entity: DecisionEntity) {
        entity.id = decision.id.uuidString
        entity.sessionId = decision.sessionId.uuidString
        entity.itemId = decision.itemId.uuidString
        entity.decidedAt = decision.decidedAt
    }

    static func decision(from entity: DecisionEntity) throws -> Decision {
        Decision(
            id: try uuid(entity.id, field: "DecisionEntity.id"),
            sessionId: try uuid(entity.sessionId, field: "DecisionEntity.sessionId"),
            itemId: try uuid(entity.itemId, field: "DecisionEntity.itemId"),
            decidedAt: try required(entity.decidedAt, entity: "DecisionEntity", field: "decidedAt")
        )
    }

    static func apply(_ viewState: SessionViewState, to entity: SessionViewStateEntity) {
        entity.sessionId = viewState.sessionId.uuidString
        entity.lastWebUrl = viewState.lastWebUrl
        entity.bottomSheetState = viewState.bottomSheetState.rawValue
        entity.lastOpenedAt = viewState.lastOpenedAt
    }

    static func viewState(from entity: SessionViewStateEntity) throws -> SessionViewState {
        let stateText = try required(
            entity.bottomSheetState,
            entity: "SessionViewStateEntity",
            field: "bottomSheetState"
        )
        guard let bottomSheetState = BottomSheetState(rawValue: stateText) else {
            throw PersistenceMappingError.invalidEnum(
                field: "SessionViewStateEntity.bottomSheetState",
                value: stateText
            )
        }

        return SessionViewState(
            sessionId: try uuid(entity.sessionId, field: "SessionViewStateEntity.sessionId"),
            lastWebUrl: entity.lastWebUrl,
            bottomSheetState: bottomSheetState,
            lastOpenedAt: try required(entity.lastOpenedAt, entity: "SessionViewStateEntity", field: "lastOpenedAt")
        )
    }

    private static func moneySnapshot(from entity: ItemEntity) throws -> MoneySnapshot? {
        switch (entity.priceAmount, entity.priceCurrency) {
        case (nil, nil):
            return nil
        case (let amountText?, let currency?):
            guard let amount = Decimal(string: amountText) else {
                throw PersistenceMappingError.invalidDecimal(field: "ItemEntity.priceAmount", value: amountText)
            }
            return MoneySnapshot(amount: amount, currency: currency, rawText: entity.priceRawText)
        default:
            let itemId = entity.id ?? "<missing>"
            throw PersistenceMappingError.incompleteMoneySnapshot(itemId: itemId)
        }
    }

    private static func thumbnailImage(from entity: ItemEntity) -> ImageRef? {
        guard let remoteUrl = entity.thumbnailRemoteUrl else { return nil }
        return ImageRef(remoteUrl: remoteUrl, localPath: entity.thumbnailLocalPath)
    }

    private static func required<T>(_ value: T?, entity: String, field: String) throws -> T {
        guard let value else {
            throw PersistenceMappingError.missingRequiredField(entity: entity, field: field)
        }
        return value
    }

    private static func uuid(_ value: String?, field: String) throws -> UUID {
        guard let value else {
            throw PersistenceMappingError.missingRequiredField(entity: field, field: "value")
        }
        guard let uuid = UUID(uuidString: value) else {
            throw PersistenceMappingError.invalidUUID(field: field, value: value)
        }
        return uuid
    }
}
