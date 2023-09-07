// Copyright © 2021 Stormbird PTE. LTD.

import Foundation
import Go23JSONRPCKit

struct ChainIdRequest: Go23JSONRPCKit.Request {
    typealias Response = Int
    var method: String {
        return "eth_chainId"
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? String, let chainId = Int(chainId0xString: response) {
            return chainId
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
