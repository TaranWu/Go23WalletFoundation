// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt
import Go23WalletCore
import Go23WalletOpenSea

protocol BalanceViewModelType {
    var amountFull: String { get }
    var amountShort: String { get }
    var symbol: String { get }
    var valueDecimal: Decimal { get }
    var amountInFiat: Double? { get }

    var value: BigInt { get }
    var balance: [TokenBalanceValue] { get }

    var ticker: CoinTicker? { get }
}

extension BalanceViewModelType {
    var isZero: Bool { value.isZero }
}

public struct BalanceViewModel: BalanceViewModelType {
    public let amountFull: String
    public let amountShort: String
    public let symbol: String
    public let valueDecimal: Decimal
    public let amountInFiat: Double?
    
    public let value: BigInt
    public let balance: [TokenBalanceValue]

    public let ticker: CoinTicker?
}

extension BalanceViewModel: Hashable { }

extension BalanceViewModel {
    init(balance: BalanceViewModelType) {
        self.amountFull = balance.amountFull
        self.amountShort = balance.amountShort
        self.symbol = balance.symbol
        self.valueDecimal = balance.valueDecimal
        self.amountInFiat = balance.amountInFiat
        self.value = balance.value
        self.balance = balance.balance
        self.ticker = balance.ticker
    }
}
