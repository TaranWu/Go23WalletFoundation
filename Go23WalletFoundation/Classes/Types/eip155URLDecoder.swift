//
//  eip155URLCoder.swift
//  DerbyWallet
//
//  Created by Vladyslav Shepitko on 12.11.2021.
//

import Foundation 

public typealias Eip155URL = (tokenType: TokenInterfaceType?, server: RPCServer?, path: String)

public struct Eip155URLCoder {
    static let key = "eip155"

    /// Decoding function for urls like `eip155:1/erc721:0xb7F7F6C52F2e2fdb1963Eab30438024864c313F6/2430`
    public static func decode(from string: String) -> Eip155URL? {
        let components = string.components(separatedBy: ":")
        guard components.count >= 3, components[0].contains(Eip155URLCoder.key) else { return .none }
        let chainAndTokenTypeComponents = components[1].components(separatedBy: "/")
        guard chainAndTokenTypeComponents.count == 2 else { return .none }
        let server = chainAndTokenTypeComponents[0].optionalDecimalValue.flatMap({ RPCServer(chainID: $0.intValue) })

        return (tokenType: TokenInterfaceType(rawValue: chainAndTokenTypeComponents[1]), server: server, path: components[2])
    }

    public static func decodeRPC(from string: String) -> RPCServer? {
        let components = string.components(separatedBy: ":")
        guard components.count >= 2, components[0].contains(Eip155URLCoder.key) else { return .none }
        return components[1].optionalDecimalValue.flatMap({ RPCServer(chainID: $0.intValue) })
    }

    ///"eip155:42:0x9E7aAF819E8f227B766E71FAc2DD018A36a0969A"
    public static func encode(rpcServer: RPCServer, address: DerbyWallet.Address? = nil) -> String {
        let elements: [String] = [Eip155URLCoder.key, String(rpcServer.chainID), address?.eip55String].compactMap { $0 }
        return elements.joined(separator: ":")
    }
}

extension RPCServer {

    public var eip155: String {
        return Eip155URLCoder.encode(rpcServer: self)
    }

    public static func decodeEip155Array(values: Set<String>) -> [RPCServer] {
        return values.compactMap { str in
            if let server = Eip155URLCoder.decodeRPC(from: str) {
                return server
            } else if let value = Int(str, radix: 10) {
                return RPCServer(chainID: value)
            } else {
                return nil
            }
        }
    }
}

