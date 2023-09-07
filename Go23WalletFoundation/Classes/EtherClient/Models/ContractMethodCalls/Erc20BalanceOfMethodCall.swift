//
//  Erc20BalanceOfMethodCall.swift
//  Go23WalletFoundation
//
//  Created by Vladyslav Shepitko on 17.01.2023.
//

import Foundation
import Go23Web3Swift
import BigInt
import Go23WalletAddress

struct Erc20BalanceOfMethodCall: ContractMethodCall {
    typealias Response = BigUInt

    let contract: Go23Wallet.Address
    let name: String = "balanceOf"
    let abi: String = Web3.Utils.erc20ABI
    var parameters: [AnyObject] { [address.eip55String] as [AnyObject] }

    private let address: Go23Wallet.Address

    init(contract: Go23Wallet.Address, address: Go23Wallet.Address) {
        self.contract = contract
        self.address = address
    }

    func response(from dictionary: [String: Any]) throws -> BigUInt {
        guard let balanceOfUnknownType = dictionary["0"], let balance = BigUInt(String(describing: balanceOfUnknownType)) else {
            throw CastError(actualValue: dictionary["0"], expectedType: BigUInt.self)
        }
        return balance
    }
}
