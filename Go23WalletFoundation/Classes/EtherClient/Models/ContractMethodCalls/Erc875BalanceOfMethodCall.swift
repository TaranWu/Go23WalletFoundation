//
//  Erc875BalanceOfMethodCall.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation

struct Erc875BalanceOfMethodCall: ContractMethodCall {
    typealias Response = [String]

    private let function = GetERC875Balance()
    private let address: Go23Wallet.Address

    let contract: Go23Wallet.Address
    var name: String { function.name }
    var abi: String { function.abi }
    var parameters: [AnyObject] { [address.eip55String] as [AnyObject] }

    init(contract: Go23Wallet.Address, address: Go23Wallet.Address) {
        self.address = address
        self.contract = contract
    }

    func response(from resultObject: Any) throws -> [String] {
        guard let dictionary = resultObject as? [String: AnyObject] else {
            throw CastError(actualValue: resultObject, expectedType: [String: AnyObject].self)
        }
        return Erc875BalanceOfMethodCall.adapt(dictionary)
    }

    private static func adapt(_ values: Any?) -> [String] {
        guard let array = values as? [Data] else { return [] }
        return array.map { each in
            let value = each.toHexString()
            return "0x\(value)"
        }
    }
}
