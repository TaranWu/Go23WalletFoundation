//
//  ConfigureApp.swift
//  DerbyWallet
//
//  Created by Vladyslav Shepitko on 09.05.2022.
//

import Foundation
import DerbyWalletOpenSea
import DerbyWalletENS

public class ConfigureApp: Initializer {
    public init() {}
    public func perform() {
        ENS.isLoggingEnabled = true
        DerbyWalletOpenSea.OpenSea.isLoggingEnabled = true
    }
}
