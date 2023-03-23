//
//  TransactionReceiptRequest.swift
//  Go23WalletFoundation
//
//  Created by Vladyslav Shepitko on 28.10.2022.
//

import Foundation
import Go23Web3Swift
import BigInt
import Go23JSONRPCKit

struct TransactionReceiptRequest: Go23JSONRPCKit.Request {
    typealias Response = TransactionReceipt

    let hash: String

    var method: String {
        return "eth_getTransactionReceipt"
    }

    var parameters: Any? {
        return [hash]
    }

    func response(from resultObject: Any) throws -> Response {
        do {
            let data = try Data(json: resultObject)
            return try JSONDecoder().decode(TransactionReceipt.self, from: data)
        } catch {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
