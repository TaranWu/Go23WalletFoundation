//
//  ContractMethodCall.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation

public protocol ContractMethodCall: CustomStringConvertible {
    associatedtype Response

    var contract: Go23Wallet.Address { get }
    var abi: String { get }
    var name: String { get }
    var parameters: [AnyObject] { get }
    /// Special flag for token script
    var shouldDelayIfCached: Bool { get }

    func response(from resultObject: Any) throws -> Response
}

extension ContractMethodCall {
    var parameters: [AnyObject] { return [] }
    var shouldDelayIfCached: Bool { return false }

    public var description: String {
        return "contract: \(contract), name: \(name), parameters: \(parameters)"
    }
}
