//
//  CoreDataSessionRepository.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import Foundation

import CoreDomain

public final class CoreDataSessionRepository: SessionRepository {
    private let store: SessionCoreDataStore

    public init(stack: ClipyCoreDataStack) {
        store = SessionCoreDataStore(stack: stack)
    }

    public func save(_ snapshot: SessionSnapshot) async throws {
        try await store.save(snapshot)
    }

    public func loadSession(id: UUID) async throws -> SessionSnapshot? {
        try await store.loadSession(id: id)
    }
}
