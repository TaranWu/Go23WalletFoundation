//
//  FungiblesTransactionAmount.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public struct FungiblesTransactionAmount {
    public var value: String
    public let shortValue: String?
    public let isAllFunds: Bool

    public init(value: String, shortValue: String?, isAllFunds: Bool) {
        self.value = value
        self.shortValue = shortValue
        self.isAllFunds = isAllFunds
    }
}
