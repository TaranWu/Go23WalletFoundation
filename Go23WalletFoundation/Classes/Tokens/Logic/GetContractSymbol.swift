// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import PromiseKit

public class GetContractSymbol {
    private let server: RPCServer

    public init(forServer server: RPCServer) {
        self.server = server
    }

    public func getSymbol(for contract: DerbyWallet.Address) -> Promise<String> {
        let functionName = "symbol"
        return callSmartContract(withServer: server, contract: contract, functionName: functionName, abiString: Web3.Utils.erc20ABI).map { symbolsResult -> String in
            if let symbol = symbolsResult["0"] as? String {
                return symbol
            } else {
                throw createSmartContractCallError(forContract: contract, functionName: functionName)
            }
        }
    }
}
