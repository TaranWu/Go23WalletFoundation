//
//  CoinGeckoTickersFetcher.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Combine
import Foundation
import Go23WalletCore

public final class CoinGeckoTickersFetcher: BaseCoinTickersFetcher, CoinTickersFetcherProvider {
    public convenience init(storage: CoinTickersStorage & ChartHistoryStorage & TickerIdsStorage, networkService: NetworkService) {
        let networkProvider: CoinTickerNetworkProviderType
        if isRunningTests() {
            networkProvider = FakeCoinGeckoNetworkProvider()
        } else {
            networkProvider = CoinGeckoNetworkProvider(networkService: networkService)
        }

        let supportedTickerIdsFetcher = SupportedTickerIdsFetcher(networkProvider: networkProvider, storage: storage, config: Config())
        let fileTokenEntriesProvider = FileTokenEntriesProvider()

        let tickerIdsFetcher: TickerIdsFetcher = TickerIdsFetcherImpl(providers: [
            InMemoryTickerIdsFetcher(storage: storage),
            supportedTickerIdsFetcher,
            Go23RemoteTickerIdsFetcher(provider: fileTokenEntriesProvider, tickerIdsFetcher: supportedTickerIdsFetcher)
        ])

        self.init(networkProvider: networkProvider, storage: storage, tickerIdsFetcher: tickerIdsFetcher)
    }
}
