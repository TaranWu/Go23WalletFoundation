//
//  HoneySwapERC20Token.swift
//  Go23Wallet
//
//  Created by Vladyslav Shepitko on 19.02.2021.
//

import Foundation
import Go23WalletAddress

extension HoneySwap {

    struct TokensResponse: Decodable {
        let tokens: [ERC20Token]
    }

    struct ERC20Token: Decodable {
        private enum AnyError: Error {
            case invalidAddress
        }

        private enum Keys: String, CodingKey {
            case symbol
            case name
            case address
            case decimals
        }

        let symbol: String
        let name: String
        let address: Go23Wallet.Address
        let decimal: Int

        init(symbol: String, name: String, address: Go23Wallet.Address, decimal: Int) {
            self.symbol = symbol
            self.name = name
            self.address = address
            self.decimal = decimal
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)

            let addressValue = try container.decode(String.self, forKey: .address)

            if let value = Go23Wallet.Address(uncheckedAgainstNullAddress: addressValue) {
                address = value
                symbol = try container.decode(String.self, forKey: .symbol)
                name = try container.decode(String.self, forKey: .name)
                decimal = try container.decode(Int.self, forKey: .decimals)
            } else {
                throw AnyError.invalidAddress
            }
        }
    }
}
