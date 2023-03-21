//
//  AnyContractMethodCall.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation

struct AnyContractMethodCall: ContractMethodCall {
    typealias Response = [String: Any]

    let contract: Go23Wallet.Address
    let name: String
    let abi: String
    let parameters: [AnyObject]

    init(contract: Go23Wallet.Address, functionName: String, abiString: String, parameters: [AnyObject]) {
        self.contract = contract
        self.name = functionName
        self.abi = abiString
        self.parameters = parameters
    }

    func response(from resultObject: Any) throws -> [String: Any] {
        guard let dictionary = resultObject as? [String: Any] else {
            throw CastError(actualValue: resultObject, expectedType: [String: AnyObject].self)
        }

        return dictionary
    }
}
