//
//  Erc721GetBalancesMethodCall.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import Go23Web3Swift
import BigInt

struct Erc721GetBalancesMethodCall: ContractMethodCall {
    typealias Response = [String]

    private let function = GetERC721ForTicketsBalance()
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

        return Erc721GetBalancesMethodCall.adapt(dictionary["0"])
    }

    private static func adapt(_ values: Any?) -> [String] {
        guard let array = values as? [BigUInt] else { return [] }
        return array.filter({ $0 != BigUInt(0) }).map { each in
            let value = each.serialize().hex()
            return "0x\(value)"
        }
    }
}
