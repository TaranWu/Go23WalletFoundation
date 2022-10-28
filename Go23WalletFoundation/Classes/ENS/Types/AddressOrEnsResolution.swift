//
//  AddressOrEnsResolution.swift
//  DerbyWallet
//
//  Created by Vladyslav Shepitko on 27.01.2022.
//

import Foundation 
import Go23WalletCore

public enum AddressOrEnsResolution {
    case invalidInput
    case resolved(AddressOrEnsName?)

    var value: String? {
        switch self {
        case .invalidInput:
            return nil
        case .resolved(let optional):
            return optional?.stringValue
        }
    }
}

public typealias BlockieAndAddressOrEnsResolution = (image: BlockiesImage?, resolution: AddressOrEnsResolution)
