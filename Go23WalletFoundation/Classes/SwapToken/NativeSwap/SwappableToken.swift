// Copyright © 2022 Stormbird PTE. LTD.

import Foundation

public struct SwappableToken: Decodable, Equatable {
    private enum Keys: String, CodingKey {
        case chainId
        case address
    }

    private struct ParsingError: Error {
        let fieldName: Keys
    }

    let address: DerbyWallet.Address
    let server: RPCServer

    init(address: DerbyWallet.Address, server: RPCServer) {
        self.address = address
        self.server = server
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        let addressString = try container.decode(String.self, forKey: .address)
        let chainId = try container.decode(Int.self, forKey: .chainId)

        address = try DerbyWallet.Address(string: addressString) ?? { throw ParsingError(fieldName: .address) }()
        server = RPCServer(chainID: chainId)
    }
}
