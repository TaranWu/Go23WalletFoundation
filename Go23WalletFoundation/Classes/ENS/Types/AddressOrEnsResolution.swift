//
//  AddressOrEnsResolution.swift
//  Go23Wallet
//
//  Created by Taran.
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
