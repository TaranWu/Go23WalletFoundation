// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt
import Go23WalletAddress

public struct UnsignedTransaction {
    public let value: BigUInt
    public let account: Go23Wallet.Address
    public let to: Go23Wallet.Address?
    public let nonce: Int
    public let data: Data
    public let gasPrice: BigUInt
    public let gasLimit: BigUInt
    public let server: RPCServer
    public let transactionType: TransactionType

    public init(value: BigUInt,
                account: Go23Wallet.Address,
                to: Go23Wallet.Address?,
                nonce: Int,
                data: Data,
                gasPrice: BigUInt,
                gasLimit: BigUInt,
                server: RPCServer,
                transactionType: TransactionType) {
        
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

    public func updating(nonce: Int) -> UnsignedTransaction {
        return UnsignedTransaction(
            value: value,
            account: account,
            to: to,
            nonce: nonce,
            data: data,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            server: server,
            transactionType: transactionType)
    }

}
