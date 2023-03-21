//
//  ContractMethod.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import Go23Web3Swift
import BigInt

public protocol ContractMethod {
    func encodedABI() throws -> Data
}
