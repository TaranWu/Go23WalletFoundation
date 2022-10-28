// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Go23JSONRPCKit

struct SendRawTransactionRequest: Go23JSONRPCKit.Request {
    typealias Response = String

    let signedTransaction: String

    var method: String {
        return "eth_sendRawTransaction"
    }

    var parameters: Any? {
        return [
            signedTransaction,
        ]
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
