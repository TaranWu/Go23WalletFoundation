// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import Go23JSONRPCKit

struct BlockNumberRequest: Go23JSONRPCKit.Request {
    typealias Response = Int

    var method: String {
        return "eth_blockNumber"
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? String, let value = BigInt(response.drop0x, radix: 16) {
            return numericCast(value)
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
