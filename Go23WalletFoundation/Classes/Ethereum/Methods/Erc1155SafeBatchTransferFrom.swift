//
//  Erc1155SafeBatchTransferFrom.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation

public struct Erc1155SafeBatchTransferFrom: ContractMethod {
    let recipient: Go23Wallet.Address
    let account: Go23Wallet.Address
    let tokenIdsAndValues: [TokenSelection]

    public init(recipient: Go23Wallet.Address, account: Go23Wallet.Address, tokenIdsAndValues: [TokenSelection]) {
        self.recipient = recipient
        self.account = account
        self.tokenIdsAndValues = tokenIdsAndValues
    }

    public func encodedABI() throws -> Data {
        let tokenIds = tokenIdsAndValues.compactMap { $0.tokenId }
        let values = tokenIdsAndValues.compactMap { $0.value }
        let function = Function(name: "safeBatchTransferFrom", parameters: [
            .address,
            .address,
            .array(.uint(bits: 256), tokenIds.count),
            .array(.uint(bits: 256), values.count),
            .dynamicBytes
        ])

        let parameters: [Any] = [
            account,
            recipient,
            tokenIds,
            values,
            Data()
        ]
        let encoder = ABIEncoder()
        try encoder.encode(function: function, arguments: parameters)

        return encoder.data
    }
}
