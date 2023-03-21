//
//  File.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import BigInt

public struct Erc721SafeTransferFrom: ContractMethod {
    let recipient: Go23Wallet.Address
    let account: Go23Wallet.Address
    let tokenId: BigUInt

    public init(recipient: Go23Wallet.Address, account: Go23Wallet.Address, tokenId: BigUInt) {
        self.recipient = recipient
        self.account = account
        self.tokenId = tokenId
    }

    public func encodedABI() throws -> Data {
        let function = Function(name: "safeTransferFrom", parameters: [.address, .address, .uint(bits: 256)])
        let encoder = ABIEncoder()
        try encoder.encode(function: function, arguments: [account, recipient, tokenId])

        return encoder.data
    }
}

public struct Erc721TransferFrom: ContractMethod {
    let recipient: Go23Wallet.Address
    let tokenId: BigUInt

    public init(recipient: Go23Wallet.Address, tokenId: BigUInt) {
        self.recipient = recipient
        self.tokenId = tokenId
    }

    public func encodedABI() throws -> Data {
        let function: Function = Function(name: "transfer", parameters: [.address, .uint(bits: 256)])
        let encoder = ABIEncoder()
        try encoder.encode(function: function, arguments: [recipient, tokenId])

        return encoder.data
    }
}
