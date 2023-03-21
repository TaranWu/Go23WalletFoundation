//
//  Erc721BalanceOfMethodCall.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import Go23Web3Swift
import BigInt

struct Erc721BalanceOfMethodCall: ContractMethodCall {
    typealias Response = [String]

    private let function = GetERC721Balance()
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

        let balance = Erc721BalanceOfMethodCall.adapt(dictionary["0"] as Any)
        if balance >= Int.max {
            throw CastError(actualValue: dictionary["0"], expectedType: Int.self)
        } else {
            return [String](repeating: "0", count: Int(balance))
        }
    }

    private static func adapt(_ value: Any) -> BigUInt {
        if let value = value as? BigUInt {
            return value
        } else {
            return BigUInt(0)
        }
    }
}
