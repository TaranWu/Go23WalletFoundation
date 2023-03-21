//
//  Erc20Approve.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import BigInt

public struct Erc20Approve: ContractMethod {
    let spender: Go23Wallet.Address
    let value: BigUInt

    public init(spender: Go23Wallet.Address, value: BigUInt) {
        self.spender = spender
        self.value = value
    }

    public func encodedABI() throws -> Data {
        let function = Function(name: "approve", parameters: [ABIType.address, ABIType.uint(bits: 256)])
        //Note: be careful here with the BigUInt and BigInt, the type needs to be exact
        let encoder = ABIEncoder()
        try encoder.encode(function: function, arguments: [spender, value])

        return encoder.data
    }
}
