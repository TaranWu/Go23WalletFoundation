// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

public struct UnconfirmedTransaction {
    public struct TokenIdAndValue {
        public let tokenId: BigUInt
        public let value: BigUInt
        
        public init(tokenId: BigUInt, value: BigUInt) {
            self.tokenId = tokenId
            self.value = value
        }
    }

    public let transactionType: TransactionType
    public let value: BigInt
    public let recipient: DerbyWallet.Address?
    public let contract: DerbyWallet.Address?
    public let data: Data?
    public let gasLimit: BigInt?
    public let tokenId: BigUInt?
    public let tokenIdsAndValues: [TokenIdAndValue]?
    public let gasPrice: BigInt?
    public let nonce: BigInt?
    // these are not the v, r, s value of a signed transaction
    // but are the v, r, s value of a signed ERC875 order
    // TODO: encapsulate it in the data field
    //TODO who uses this?
    public let valuev: UInt8?
    public let valuer: String?
    public let values: String?
    public let expiry: BigUInt?
    public let indices: [UInt16]?

    public init(
        transactionType: TransactionType,
        value: BigInt,
        recipient: DerbyWallet.Address?,
        contract: DerbyWallet.Address?,
        data: Data?,
        tokenId: BigUInt? = nil,
        tokenIdsAndValues: [TokenIdAndValue]? = nil,
        indices: [UInt16]? = nil,
        gasLimit: BigInt? = nil,
        gasPrice: BigInt? = nil,
        nonce: BigInt? = nil
    ) {
        self.transactionType = transactionType
        self.value = value
        self.recipient = recipient
        self.contract = contract
        self.data = data
        self.tokenId = tokenId
        self.tokenIdsAndValues = tokenIdsAndValues
        self.indices = indices
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.nonce = nonce
        self.valuev = nil
        self.valuer = nil
        self.values = nil
        self.expiry = nil
    }
}
