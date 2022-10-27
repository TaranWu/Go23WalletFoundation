//
//  RemoteTokenEntriesProvider.swift
//  DerbyWalletFoundation
//
//  Created by Tatan.
//

import Foundation
import Combine
import CombineExt
import DerbyWalletCore

//TODO: Future impl for remote TokenEntries provider
public final class RemoteTokenEntriesProvider: TokenEntriesProvider {
    public func tokenEntries() -> AnyPublisher<[TokenEntry], PromiseError> {
        return .just([])
            .share()
            .eraseToAnyPublisher()
    }
}
