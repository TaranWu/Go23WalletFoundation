// Copyright © 2019 Stormbird PTE. LTD.

import Foundation
import BigInt
import PromiseKit

public class GetErc20Balance {
    private let server: RPCServer
    private let queue: DispatchQueue?

    public init(forServer server: RPCServer, queue: DispatchQueue? = nil) {
        self.server = server
        self.queue = queue
    }

    public func getBalance(for address: DerbyWallet.Address, contract: DerbyWallet.Address) -> Promise<BigInt> {
        let functionName = "balanceOf"
        return callSmartContract(withServer: server, contract: contract, functionName: functionName, abiString: Web3.Utils.erc20ABI, parameters: [address.eip55String] as [AnyObject], queue: queue).map(on: queue, { balanceResult in
            if let balanceWithUnknownType = balanceResult["0"] {
                let string = String(describing: balanceWithUnknownType)
                if let balance = BigInt(string) {
                    return balance
                } else {
                    throw createSmartContractCallError(forContract: contract, functionName: functionName)
                }
            } else {
                throw createSmartContractCallError(forContract: contract, functionName: functionName)
            }
        })
    }
}
