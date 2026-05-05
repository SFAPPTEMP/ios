//
//  SessionRepository.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import Foundation

public protocol SessionRepository {
    func save(_ snapshot: SessionSnapshot) async throws
    func loadSession(id: UUID) async throws -> SessionSnapshot?
}
