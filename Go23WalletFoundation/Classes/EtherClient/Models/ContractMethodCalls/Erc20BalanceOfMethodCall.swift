//
//  Erc20BalanceOfMethodCall.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import Go23Web3Swift
import BigInt

struct Erc20BalanceOfMethodCall: ContractMethodCall {
    typealias Response = BigInt

    let contract: Go23Wallet.Address
    let name: String = "balanceOf"
    let abi: String = Web3.Utils.erc20ABI
    var parameters: [AnyObject] { [address.eip55String] as [AnyObject] }

    private let address: Go23Wallet.Address

    init(contract: Go23Wallet.Address, address: Go23Wallet.Address) {
        self.contract = contract
        self.address = address
    }

    func response(from resultObject: Any) throws -> BigInt {
        guard let dictionary = resultObject as? [String: AnyObject] else {
            throw CastError(actualValue: resultObject, expectedType: BigInt.self)
        }

        guard let balanceOfUnknownType = dictionary["0"], let balance = BigInt(String(describing: balanceOfUnknownType)) else {
            throw CastError(actualValue: dictionary["0"], expectedType: BigInt.self)
        }
        return balance
    }
}
