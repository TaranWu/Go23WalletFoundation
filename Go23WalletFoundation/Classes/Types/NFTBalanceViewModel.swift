//
//  NFTBalanceViewModel.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation
import BigInt 

struct NFTBalanceViewModel: BalanceViewModelType {
    private let _balance: BalanceRepresentable

    var ticker: CoinTicker?

    init(balance: BalanceRepresentable, ticker: CoinTicker?) {
        self._balance = balance
        self.ticker = ticker
    }

    var balance: [TokenBalanceValue] {
        return _balance.balanceNft
    }

    var value: BigInt { return _balance.valueBI }
    var valueDecimal: Decimal { Decimal(bigInt: value, decimals: _balance.decimals) ?? .zero }
    var amountString: String { return "\(nonZeroBalance) \(_balance.symbol)" }
    var currencyAmount: String? { return nil }
    var amountInFiat: Double? { return nil }
    var amountFull: String { return "\(nonZeroBalance)" }
    var amountShort: String { return "\(nonZeroBalance)" }
    var symbol: String { return _balance.symbol }

    private var nonZeroBalance: Int {
        let actualBalance = Array(_balance.balanceNft.filter { isNonZeroBalance($0.balance, tokenType: _balance.type) })
        return actualBalance.count
    }
    
}
