//
//  TokenToSwap.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public struct TokenToSwap {
    public let address: Go23Wallet.Address
    public let server: RPCServer
    public let symbol: String
    public let decimals: Int
}

extension TokenToSwap: Equatable, Codable {
    init(token: Token) {
        address = token.contractAddress
        server = token.server
        symbol = token.symbol
        decimals = token.decimals
    }

    init(tokenFromQuate token: SwapQuote.Token) {
        address = token.address
        server = RPCServer(chainID: token.chainId)
        symbol = token.symbol
        decimals = token.decimals
    }
}
