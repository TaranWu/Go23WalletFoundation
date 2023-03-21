//
//  Erc20SupportsInterfaceMethodCall.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation

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

    func response(from resultObject: Any) throws -> Bool {
        guard let dictionary = resultObject as? [String: AnyObject] else {
            throw CastError(actualValue: resultObject, expectedType: [String: AnyObject].self)
        }

        guard let supported = dictionary["0"] as? Bool else {
            throw CastError(actualValue: dictionary["0"], expectedType: Bool.self)
        }

        return supported
    }
}
