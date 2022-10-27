// Copyright SIX DAY LLC. All rights reserved.

import Foundation

public struct TokenUpdate {
    let address: DerbyWallet.Address
    let server: RPCServer
    let name: String
    let symbol: String
    let decimals: Int
    let tokenType: TokenType
    var primaryKey: String {
         return TokenObject.generatePrimaryKey(fromContract: address, server: server)
    }
}
