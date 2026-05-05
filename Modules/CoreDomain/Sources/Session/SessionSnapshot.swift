//
//  SessionSnapshot.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

public struct SessionSnapshot: Equatable {
    public let session: Session
    public let viewState: SessionViewState?

    public init(session: Session, viewState: SessionViewState? = nil) {
        self.session = session
        self.viewState = viewState
    }
}
