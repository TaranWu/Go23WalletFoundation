// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Go23JSONRPCKit
import BigInt

struct EstimateGasRequest: Go23JSONRPCKit.Request {
    typealias Response = String

    enum TransactionType {
        case normal(to: DerbyWallet.Address)
        case contractDeployment
    }

    private var to: DerbyWallet.Address? {
        switch transactionType {
        case .normal(let to):
            return to
        case .contractDeployment:
            return nil
        }
    }

    let from: DerbyWallet.Address
    let transactionType: TransactionType
    let value: BigInt
    let data: Data

    var method: String {
        return "eth_estimateGas"
    }

    var parameters: Any? {
        //Explicit type declaration to speed up build time. 160msec -> <100ms, as of Xcode 11.7
        var results: [[String: String]] = [
            [
                "from": from.description,
                "value": "0x" + String(value, radix: 16),
                "data": data.hexEncoded,
            ],
        ]
        if let to: DerbyWallet.Address = to {
            results[0]["to"] = to.eip55String
        }
        return results
    }

    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
