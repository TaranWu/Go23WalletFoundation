//
//  Erc20AllowanceMethodCall.swift
//  Go23WalletFoundation
//
//  Created by Vladyslav Shepitko on 17.01.2023.
//

import Foundation
import Go23Web3Swift
import BigInt

struct Erc20AllowanceMethodCall: ContractMethodCall {
    typealias Response = BigUInt

    let owner: Go23Wallet.Address
    let spender: Go23Wallet.Address
    let contract: Go23Wallet.Address
    let name: String = "allowance"
    let abi: String = Web3.Utils.erc20ABI
    var parameters: [AnyObject] { [owner.eip55String, spender.eip55String] as [AnyObject] }

    init(contract: Go23Wallet.Address, owner: Go23Wallet.Address, spender: Go23Wallet.Address) {
        self.contract = contract
        self.owner = owner
        self.spender = spender
    }

    func response(from dictionary: [String: Any]) throws -> BigUInt {
        guard let allowance = dictionary["0"] as? BigUInt else {
            throw CastError.init(actualValue: dictionary["0"], expectedType: BigUInt.self)
        }

        return allowance
    }
}
