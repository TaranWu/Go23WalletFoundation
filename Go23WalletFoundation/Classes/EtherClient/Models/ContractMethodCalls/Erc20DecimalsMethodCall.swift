//
//  Erc20DecimalsMethodCall.swift
//  Go23WalletFoundation
//
//  Created by Vladyslav Shepitko on 17.01.2023.
//

import Foundation
import Go23Web3Swift
import Go23WalletAddress

struct Erc20DecimalsMethodCall: ContractMethodCall {
    typealias Response = Int

    let contract: Go23Wallet.Address
    var name: String = "decimals"
    var abi: String = Web3.Utils.erc20ABI
    var parameters: [AnyObject] { [] }

    init(contract: Go23Wallet.Address) {
        self.contract = contract
    }

    func response(from dictionary: [String: Any]) throws -> Int {
        guard let decimalsOfUnknownType = dictionary["0"], let decimals = Int(String(describing: decimalsOfUnknownType)) else {
            throw CastError(actualValue: dictionary["0"], expectedType: Int.self)
        }

        return decimals
    }
}
