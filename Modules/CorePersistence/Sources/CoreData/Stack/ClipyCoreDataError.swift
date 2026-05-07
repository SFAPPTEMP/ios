//
//  ClipyCoreDataError.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import Foundation

public enum ClipyCoreDataError: Error, LocalizedError {
    case modelNotFound(String)
    case modelLoadFailed(URL)
    case storeLoadFailed(Error)
    case applicationSupportNotFound
    case directoryCreationFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .modelNotFound(let modelName):
            return "CoreData model을 찾을 수 없습니다: \(modelName)"
        case .modelLoadFailed(let url):
            return "CoreData model을 로드할 수 없습니다: \(url.path)"
        case .storeLoadFailed(let error):
            return "CoreData store 로딩 실패: \(error.localizedDescription)"
        case .applicationSupportNotFound:
            return "Application Support 디렉토리를 찾을 수 없습니다."
        case .directoryCreationFailed(let error):
            return "Application Support 디렉토리 생성 실패: \(error.localizedDescription)"
        }
    }
}
