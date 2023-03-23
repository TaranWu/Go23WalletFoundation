//
//  Erc20NameMethodCall.swift
//  Go23WalletFoundation
//
//  Created by Vladyslav Shepitko on 17.01.2023.
//

import Foundation
import Go23Web3Swift
import Go23WalletAddress

struct Erc20NameMethodCall: ContractMethodCall {
    typealias Response = String

    let contract: Go23Wallet.Address
    let name: String = "name"
    let abi: String = Web3.Utils.erc20ABI

    init(contract: Go23Wallet.Address) {
        self.contract = contract
    }

    func response(from dictionary: [String: Any]) throws -> String {
        guard let name = dictionary["0"] as? String else {
            throw CastError(actualValue: dictionary["0"], expectedType: String.self)
        }
        return name
    }
}
