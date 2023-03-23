//
//  Erc875Transfer.swift
//  Go23WalletFoundation
//
//  Created by Vladyslav Shepitko on 08.11.2022.
//

import Foundation
import BigInt

public struct Erc875Transfer: ContractMethod {
    let contractAddress: Go23Wallet.Address
    let recipient: Go23Wallet.Address
    let indices: [UInt16]

    public init(contractAddress: Go23Wallet.Address, recipient: Go23Wallet.Address, indices: [UInt16]) {
        self.contractAddress = contractAddress
        self.recipient = recipient
        self.indices = indices
    }

    public func encodedABI() throws -> Data {
        let parameters: [Any] = [recipient, indices.map({ BigUInt($0) })]
        let arrayType: ABIType
        if contractAddress.isLegacy875Contract {
            arrayType = ABIType.uint(bits: 16)
        } else {
            arrayType = ABIType.uint(bits: 256)
        }
        let functionEncoder = Function(name: "transfer", parameters: [.address, .dynamicArray(arrayType)])
        let encoder = ABIEncoder()
        try encoder.encode(function: functionEncoder, arguments: parameters)

        return encoder.data
    }
}
