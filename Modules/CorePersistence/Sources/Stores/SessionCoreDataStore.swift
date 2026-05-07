//
//  SessionCoreDataStore.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import CoreData
import Foundation

import CoreDomain

final class SessionCoreDataStore {
    private let stack: ClipyCoreDataStack

    init(stack: ClipyCoreDataStack) {
        self.stack = stack
    }

    func save(_ snapshot: SessionSnapshot) async throws {
        try await stack.performBackgroundTask { context in
            try Self.save(snapshot, in: context)
        }
    }

    func loadSession(id: UUID) async throws -> SessionSnapshot? {
        let context = stack.viewContext

        return try await context.perform {
            try Self.loadSession(id: id, in: context)
        }
    }
}

private extension SessionCoreDataStore {
    static func save(_ snapshot: SessionSnapshot, in context: NSManagedObjectContext) throws {
        let session = snapshot.session
        let sessionEntity = try fetchOrCreateSessionEntity(
            id: session.id.uuidString,
            in: context
        )
        SessionEntityMapper.apply(session, to: sessionEntity)

        try replaceChildEntities(for: session, in: context)

        if let viewState = snapshot.viewState {
            let viewStateEntity = try fetchOrCreateViewStateEntity(
                sessionId: viewState.sessionId.uuidString,
                in: context
            )
            SessionEntityMapper.apply(viewState, to: viewStateEntity)
        } else {
            try deleteViewState(sessionId: session.id.uuidString, in: context)
        }

        try context.save()
    }

    static func loadSession(id: UUID, in context: NSManagedObjectContext) throws -> SessionSnapshot? {
        guard let sessionEntity = try fetchSessionEntity(id: id.uuidString, in: context) else {
            return nil
        }

        let itemEntities = try fetchItemEntities(sessionId: id.uuidString, in: context)
        let capturesByItemId = try fetchCapturesByItemId(
            itemIds: itemEntities.compactMap(\.id),
            in: context
        )
        let items = try itemEntities.map { entity in
            try SessionEntityMapper.item(
                from: entity,
                captures: capturesByItemId[entity.id ?? "", default: []]
            )
        }
        let decisions = try fetchDecisionEntities(sessionId: id.uuidString, in: context)
            .map { try SessionEntityMapper.decision(from: $0) }
        let session = try SessionEntityMapper.session(
            from: sessionEntity,
            items: items,
            decisions: decisions
        )
        let viewState = try fetchViewStateEntity(sessionId: id.uuidString, in: context)
            .map { try SessionEntityMapper.viewState(from: $0) }

        return SessionSnapshot(session: session, viewState: viewState)
    }

    static func replaceChildEntities(for session: Session, in context: NSManagedObjectContext) throws {
        let sessionId = session.id.uuidString
        let existingItemIds = try fetchItemEntities(sessionId: sessionId, in: context).compactMap(\.id)
        try deleteCaptures(itemIds: existingItemIds, in: context)
        try deleteItems(sessionId: sessionId, in: context)
        try deleteDecisions(sessionId: sessionId, in: context)

        for item in session.items {
            let itemEntity = ItemEntity(context: context)
            SessionEntityMapper.apply(item, to: itemEntity)

            for capture in item.captures {
                let captureEntity = CaptureEntity(context: context)
                SessionEntityMapper.apply(capture, to: captureEntity)
            }
        }

        for decision in session.decisions {
            let decisionEntity = DecisionEntity(context: context)
            SessionEntityMapper.apply(decision, to: decisionEntity)
        }
    }

    static func fetchOrCreateSessionEntity(id: String, in context: NSManagedObjectContext) throws -> SessionEntity {
        if let entity = try fetchSessionEntity(id: id, in: context) {
            return entity
        }
        return SessionEntity(context: context)
    }

    static func fetchSessionEntity(id: String, in context: NSManagedObjectContext) throws -> SessionEntity? {
        let request = SessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    static func fetchOrCreateViewStateEntity(
        sessionId: String,
        in context: NSManagedObjectContext
    ) throws -> SessionViewStateEntity {
        if let entity = try fetchViewStateEntity(sessionId: sessionId, in: context) {
            return entity
        }
        return SessionViewStateEntity(context: context)
    }

    static func fetchViewStateEntity(
        sessionId: String,
        in context: NSManagedObjectContext
    ) throws -> SessionViewStateEntity? {
        let request = SessionViewStateEntity.fetchRequest()
        request.predicate = NSPredicate(format: "sessionId == %@", sessionId)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    static func fetchItemEntities(sessionId: String, in context: NSManagedObjectContext) throws -> [ItemEntity] {
        let request = ItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "sessionId == %@", sessionId)
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: true),
            NSSortDescriptor(key: "id", ascending: true)
        ]
        return try context.fetch(request)
    }

    static func fetchCapturesByItemId(
        itemIds: [String],
        in context: NSManagedObjectContext
    ) throws -> [String: [Capture]] {
        guard !itemIds.isEmpty else { return [:] }

        let request = CaptureEntity.fetchRequest()
        request.predicate = NSPredicate(format: "itemId IN %@", itemIds)
        request.sortDescriptors = [
            NSSortDescriptor(key: "capturedAt", ascending: true),
            NSSortDescriptor(key: "id", ascending: true)
        ]

        let captures = try context.fetch(request).map { try SessionEntityMapper.capture(from: $0) }
        return Dictionary(grouping: captures, by: { $0.itemId.uuidString })
    }

    static func fetchDecisionEntities(sessionId: String, in context: NSManagedObjectContext) throws -> [DecisionEntity] {
        let request = DecisionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "sessionId == %@", sessionId)
        request.sortDescriptors = [
            NSSortDescriptor(key: "decidedAt", ascending: true),
            NSSortDescriptor(key: "id", ascending: true)
        ]
        return try context.fetch(request)
    }

    static func deleteItems(sessionId: String, in context: NSManagedObjectContext) throws {
        let request = ItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "sessionId == %@", sessionId)
        try context.fetch(request).forEach(context.delete)
    }

    static func deleteCaptures(itemIds: [String], in context: NSManagedObjectContext) throws {
        guard !itemIds.isEmpty else { return }

        let request = CaptureEntity.fetchRequest()
        request.predicate = NSPredicate(format: "itemId IN %@", itemIds)
        try context.fetch(request).forEach(context.delete)
    }

    static func deleteDecisions(sessionId: String, in context: NSManagedObjectContext) throws {
        let request = DecisionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "sessionId == %@", sessionId)
        try context.fetch(request).forEach(context.delete)
    }

    static func deleteViewState(sessionId: String, in context: NSManagedObjectContext) throws {
        if let entity = try fetchViewStateEntity(sessionId: sessionId, in: context) {
            context.delete(entity)
        }
    }
}
