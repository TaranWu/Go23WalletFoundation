// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

public struct ErcToken {
    public let contract: Go23Wallet.Address
    public let server: RPCServer
    public let name: String
    public let symbol: String
    public let decimals: Int
    public let type: TokenType
    public let value: BigInt
    public let balance: NonFungibleBalance

    public init(contract: Go23Wallet.Address, server: RPCServer, name: String, symbol: String, decimals: Int, type: TokenType, value: BigInt, balance: NonFungibleBalance) {
        self.contract = contract
        self.server = server
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.type = type
        self.value = value
        self.balance = balance
    }
}
