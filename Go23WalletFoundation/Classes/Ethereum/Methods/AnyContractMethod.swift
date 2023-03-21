//
//  AnyContractMethod.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import Go23Web3Swift

public struct AnyContractMethod: ContractMethod {
    let method: String
    let abi: String
    let params: [AnyObject]

    public init(method: String, abi: String, params: [AnyObject]) {
        self.method = method
        self.abi = abi
        self.params = params
    }

    public func encodedABI() throws -> Data {
        let contract = try Contract(abi: abi)
        return try contract.methodData(method, parameters: params)
    }
}
