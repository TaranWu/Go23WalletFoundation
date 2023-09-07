//
//  ContractMethod.swift
//  Go23WalletFoundation
//
//  Created by Vladyslav Shepitko on 07.11.2022.
//

import Foundation
import Go23Web3Swift
import BigInt

public protocol ContractMethod {
    func encodedABI() throws -> Data
}
