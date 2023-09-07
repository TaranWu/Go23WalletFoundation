// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import PromiseKit

public class GetContractDecimals {
    private let server: RPCServer

    public init(forServer server: RPCServer) {
        self.server = server
    }

    public func getDecimals(for contract: DerbyWallet.Address) -> Promise<UInt8> {
        let functionName = "decimals"
        return callSmartContract(withServer: server, contract: contract, functionName: functionName, abiString: Web3.Utils.erc20ABI).map { dictionary -> UInt8 in
            if let decimalsWithUnknownType = dictionary["0"] {
                let string = String(describing: decimalsWithUnknownType)
                if let decimals = UInt8(string) {
                    return decimals
                } else {
                    throw createSmartContractCallError(forContract: contract, functionName: functionName)
                }
            } else {
                throw createSmartContractCallError(forContract: contract, functionName: functionName)
            }
        }
    }
}
