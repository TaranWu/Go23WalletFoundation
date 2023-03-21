//
//  Erc20BalanceViewModel.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation
import BigInt
import Go23WalletOpenSea

protocol BalanceRepresentable {
    var balanceNft: [TokenBalanceValue] { get }
    var valueBI: BigInt { get }
    var type: TokenType { get }
    var decimals: Int { get }
    var symbol: String { get }
    var server: RPCServer { get }
}

struct Erc20BalanceViewModel: BalanceViewModelType {
    private let _balance: BalanceRepresentable
    var ticker: CoinTicker?

    init(balance: BalanceRepresentable, ticker: CoinTicker?) {
        self._balance = balance
        self.ticker = ticker
    }

    var balance: [TokenBalanceValue] { return [] }
    var value: BigInt { _balance.valueBI }
    var valueDecimal: Decimal { Decimal(bigInt: value, decimals: _balance.decimals) ?? .zero }

    var amountString: String {
        guard !isZero else { return "0.00 \(_balance.symbol)" }
        let value = EtherNumberFormatter.plain.string(from: _balance.valueBI, decimals: _balance.decimals).droppedTrailingZeros
        return "\(value) \(_balance.symbol)"
    }

    var currencyAmount: String? {
        guard let ticker = ticker else { return nil }

        return NumberFormatter.fiat(currency: ticker.currency).string(double: valueDecimal.doubleValue * ticker.price_usd)
    }

    var amountInFiat: Double? {
        guard let ticker = ticker else { return nil }
        return valueDecimal.doubleValue * ticker.price_usd
    }

    var amountFull: String { return EtherNumberFormatter.plain.string(from: _balance.valueBI, decimals: _balance.decimals).droppedTrailingZeros }
    var amountShort: String { return EtherNumberFormatter.short.string(from: _balance.valueBI, decimals: _balance.decimals).droppedTrailingZeros }
    var symbol: String { return _balance.symbol }
}
