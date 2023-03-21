//
//  Erc1155SafeTransferFrom.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation

public struct Erc1155SafeTransferFrom: ContractMethod {
    let recipient: Go23Wallet.Address
    let account: Go23Wallet.Address
    let tokenIdAndValue: TokenSelection

    public init(recipient: Go23Wallet.Address, account: Go23Wallet.Address, tokenIdAndValue: TokenSelection) {
        self.recipient = recipient
        self.account = account
        self.tokenIdAndValue = tokenIdAndValue
    }

    public func encodedABI() throws -> Data {
        let function = Function(name: "safeTransferFrom", parameters: [.address, .address, .uint(bits: 256), .uint(bits: 256), .dynamicBytes])
        let parameters: [Any] = [
            account,
            recipient,
            tokenIdAndValue.tokenId,
            tokenIdAndValue.value,
            Data()
        ]
        let encoder = ABIEncoder()
        try encoder.encode(function: function, arguments: parameters)

        return encoder.data
    }
}
