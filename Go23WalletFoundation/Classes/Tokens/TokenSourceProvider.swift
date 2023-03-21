//
//  TokenSourceProvider.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation
import Combine

public protocol TokenSourceProvider: TokensState, TokenAutoDetectable {
    var session: WalletSession { get }

    func start()
    func refresh()
    func refreshBalance(for tokens: [Token])
}
