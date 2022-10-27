// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

public struct UnsignedTransaction {
    public let value: BigInt
    public let account: DerbyWallet.Address
    public let to: DerbyWallet.Address?
    public let nonce: Int
    public let data: Data
    public let gasPrice: BigInt
    public let gasLimit: BigInt
    public let server: RPCServer
    public let transactionType: TransactionType

    public init(value: BigInt, account: DerbyWallet.Address, to: DerbyWallet.Address?, nonce: Int, data: Data, gasPrice: BigInt, gasLimit: BigInt, server: RPCServer, transactionType: TransactionType) {
        self.value = value
        self.account = account
        self.to = to
        self.nonce = nonce
        self.data = data
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.server = server
        self.transactionType = transactionType
    }
}
