// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import PromiseKit

public class GetContractName {
    private let server: RPCServer

    public init(forServer server: RPCServer) {
        self.server = server
    }

    public func getName(for contract: DerbyWallet.Address) -> Promise<String> {
        let functionName = "name"
        return callSmartContract(withServer: server, contract: contract, functionName: functionName, abiString: Web3.Utils.erc20ABI).map { nameResult -> String in
            if let name = nameResult["0"] as? String {
                return name
            } else {
                throw createSmartContractCallError(forContract: contract, functionName: functionName)
            }
        }
    }
}
