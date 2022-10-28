//
//  ConfigureApp.swift
//  DerbyWallet
//
//  Created by Vladyslav Shepitko on 09.05.2022.
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
