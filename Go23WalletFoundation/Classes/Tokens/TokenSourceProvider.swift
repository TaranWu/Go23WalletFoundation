//
//  TokenSourceProvider.swift
//  Go23Wallet
//
//  Created by Vladyslav Shepitko on 08.07.2022.
//

import Foundation
import Combine

public protocol TokenSourceProvider: TokensState, TokenAutoDetectable {
    var session: WalletSession { get }

    func start()
    func refresh()
    func refreshBalance(for tokens: [Token])
}
