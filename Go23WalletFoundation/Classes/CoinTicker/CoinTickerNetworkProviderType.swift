//
//  CoinTickerNetworkProviderType.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import Combine
import Go23WalletCore

public protocol CoinTickerNetworkProviderType {
    func fetchSupportedTickerIds() -> AnyPublisher<[TickerId], PromiseError>
    func fetchTickers(for tickerIds: [TickerIdString], currency: Currency) -> AnyPublisher<[CoinTicker], PromiseError>
    func fetchChartHistory(for period: ChartHistoryPeriod, tickerId: String, currency: Currency) -> AnyPublisher<ChartHistory, PromiseError>
}
