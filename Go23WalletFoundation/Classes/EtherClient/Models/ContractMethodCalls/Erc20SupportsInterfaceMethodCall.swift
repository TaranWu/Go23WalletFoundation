//
//  Erc20SupportsInterfaceMethodCall.swift
//  Go23WalletFoundation
//
//  Created by Vladyslav Shepitko on 17.01.2023.
//

import Foundation
import Go23WalletAddress

struct Erc20SupportsInterfaceMethodCall: ContractMethodCall {
    typealias Response = Bool

    private let function = GetInterfaceSupported165Encode()
    private let hash: String

    let contract: Go23Wallet.Address
    var name: String { function.name }
    var abi: String { function.abi }
    var parameters: [AnyObject] { [hash] as [AnyObject] }

    init(contract: Go23Wallet.Address, hash: String) {
        self.contract = contract
        self.hash = hash
    }

    func response(from dictionary: [String: Any]) throws -> Bool {
        guard let supported = dictionary["0"] as? Bool else {
            throw CastError(actualValue: dictionary["0"], expectedType: Bool.self)
        }

        return supported
    }
}
