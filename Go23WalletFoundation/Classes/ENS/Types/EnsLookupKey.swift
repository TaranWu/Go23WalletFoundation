//
//  EnsLookupKey.swift
//  DerbyWallet
//
//  Created by Vladyslav Shepitko on 06.06.2022.
//

import Foundation
import DerbyWalletENS

public struct EnsLookupKey: Hashable, CustomStringConvertible {
    public let nameOrAddress: String
    public let server: RPCServer
    public let record: EnsTextRecordKey?

    public init(nameOrAddress: String, server: RPCServer) {
        //Lowercase for case-insensitive lookups
        self.nameOrAddress = nameOrAddress.lowercased()
        self.server = server
        self.record = nil
    }

    public init(nameOrAddress: String, server: RPCServer, record: EnsTextRecordKey) {
        //Lowercase for case-insensitive lookups
        self.nameOrAddress = nameOrAddress.lowercased()
        self.server = server
        self.record = record
    }

    public var description: String {
        return [nameOrAddress, String(server.chainID), record?.rawValue].compactMap { $0 }.joined(separator: "-")
    }
}
