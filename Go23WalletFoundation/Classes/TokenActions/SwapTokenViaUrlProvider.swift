//
//  SwapTokenViaUrlProvider.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public protocol SwapTokenViaUrlProvider: TokenActionProvider {
    var analyticsName: String { get }

    func rpcServer(forToken token: TokenActionsIdentifiable) -> RPCServer?
    func url(token: TokenActionsIdentifiable) -> URL?
}
