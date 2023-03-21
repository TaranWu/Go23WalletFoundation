//
//  Erc20SymbolMethodCall.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import Go23Web3Swift

struct Erc20SymbolMethodCall: ContractMethodCall {
    typealias Response = String

    let contract: Go23Wallet.Address
    let name: String = "symbol"
    let abi: String = Web3.Utils.erc20ABI

    init(contract: Go23Wallet.Address) {
        self.contract = contract
    }

    func response(from resultObject: Any) throws -> String {
        guard let dictionary = resultObject as? [String: AnyObject] else {
            throw CastError(actualValue: resultObject, expectedType: [String: AnyObject].self)
        }

        guard let name = dictionary["0"] as? String else {
            throw CastError(actualValue: dictionary["0"], expectedType: String.self)
        }
        return name
    }
}
