//
//  ConfigureApp.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation
import Go23WalletOpenSea
import Go23WalletENS

public class ConfigureApp: Initializer {
    public init() {}
    public func perform() {
        ENS.isLoggingEnabled = true
        Go23WalletOpenSea.OpenSea.isLoggingEnabled = true
    }
}
