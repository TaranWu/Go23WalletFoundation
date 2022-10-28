// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Go23JSONRPCKit

struct GasPriceRequest: Go23JSONRPCKit.Request {
    typealias Response = String

    var method: String {
        return "eth_gasPrice"
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
