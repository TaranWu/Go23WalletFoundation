//
//  BlockByNumberRequest.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import Go23Web3Swift
import BigInt
import Go23JSONRPCKit

struct BlockByNumberRequest: Go23JSONRPCKit.Request {
    typealias Response = Block

    let number: BigUInt
    var fullTransactions: Bool = false
    var method: String {
        return "eth_getBlockByNumber"
    }

    var parameters: Any? {
        return [String(number, radix: 16).add0x, fullTransactions]
    }

    func response(from resultObject: Any) throws -> Response {
        do {
            let data = try Data(json: resultObject)
            return try JSONDecoder().decode(Block.self, from: data)
        } catch {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
