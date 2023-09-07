//
//  InMemoryTickerIdsFetcher.swift
//  Go23Wallet
//
//  Created by Vladyslav Shepitko on 14.06.2022.
//

import Foundation
import Combine
import CombineExt
import Go23WalletCore

public class InMemoryTickerIdsFetcher: TickerIdsFetcher {
    private let storage: TickerIdsStorage

    public init(storage: TickerIdsStorage) {
        self.storage = storage
    }

    /// Returns already defined, stored associated with token ticker id
    public func tickerId(for token: TokenMappedToTicker) -> AnyPublisher<TickerIdString?, Never> {
        if let id = token.knownCoinGeckoTickerId {
            return .just(id)
        } else {
            let tickerId = storage.knownTickerId(for: token)
            return .just(tickerId)
        }
    }
}
