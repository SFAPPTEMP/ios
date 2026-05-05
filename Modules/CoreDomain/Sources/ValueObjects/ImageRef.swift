//
//  ImageRef.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

public struct ImageRef: Equatable {
    public let remoteUrl: String
    public let localPath: String?

    public init(
        remoteUrl: String,
        localPath: String? = nil
    ) {
        self.remoteUrl = remoteUrl
        self.localPath = localPath
    }
}
