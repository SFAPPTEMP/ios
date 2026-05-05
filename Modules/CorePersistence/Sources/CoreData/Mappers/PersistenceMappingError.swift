//
//  PersistenceMappingError.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import Foundation

enum PersistenceMappingError: Error, LocalizedError, Equatable {
    case missingRequiredField(entity: String, field: String)
    case invalidUUID(field: String, value: String)
    case invalidEnum(field: String, value: String)
    case invalidDecimal(field: String, value: String)
    case incompleteMoneySnapshot(itemId: String)

    var errorDescription: String? {
        switch self {
        case .missingRequiredField(let entity, let field):
            return "필수 필드가 비어 있습니다: \(entity).\(field)"
        case .invalidUUID(let field, let value):
            return "UUID 값이 올바르지 않습니다: \(field)=\(value)"
        case .invalidEnum(let field, let value):
            return "enum 값이 올바르지 않습니다: \(field)=\(value)"
        case .invalidDecimal(let field, let value):
            return "Decimal 값이 올바르지 않습니다: \(field)=\(value)"
        case .incompleteMoneySnapshot(let itemId):
            return "MoneySnapshot 필드가 완전하지 않습니다: itemId=\(itemId)"
        }
    }
}
