// Copyright © 2021 Stormbird PTE. LTD.

import Foundation
import Go23JSONRPCKit

public struct EthCallRequest: Go23JSONRPCKit.Request {
    public typealias Response = String

    let from: Go23Wallet.Address?
    let to: Go23Wallet.Address?
    let value: String?
    let data: String

    public init(from: Go23Wallet.Address?, to: Go23Wallet.Address?, value: String?, data: String) {
        self.from = from
        self.to = to
        self.value = value
        self.data = data
    }

    public var method: String {
        return "eth_call"
    }

    public var parameters: Any? {
        //Explicit type declaration to speed up build time. 160msec -> <100ms, as of Xcode 11.7
        var payload: [String: Any] = [
            "data": data
        ]
        if let to = to {
            payload["to"] = to.eip55String
        }
        if let from = from {
            payload["from"] = from.eip55String
        }
        if let value = value {
            payload["value"] = value
        }
        let results: [Any] = [
            payload,
            "latest",
        ]
        return results
    }

    public func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
