//
//  SwitchChainRequestConfiguration.swift
//  DerbyWallet
//
//  Created by Tatan.
//

import Foundation

public enum SwitchChainRequestConfiguration {
    case promptAndSwitchToExistingServerInBrowser(existingServer: RPCServer)
    case promptAndAddAndActivateServer(customChain: WalletAddEthereumChainObject, customChainId: Int)
    case promptAndActivateExistingServer(existingServer: RPCServer)
}

public enum SwitchChainRequestResponse {
    case action(Int)
    case canceled
}
