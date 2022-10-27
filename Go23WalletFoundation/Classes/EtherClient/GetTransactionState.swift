//
//  GetTransactionState.swift
//  DerbyWalletFoundation
//
//  Created by Vladyslav Shepitko on 15.09.2022.
//

import Foundation
import PromiseKit

public final class GetTransactionState {
    public init() { }

    public func getTransactionsState(server: RPCServer, hash: String) -> Promise<TransactionState> {
        guard let web3 = try? getCachedWeb3(forServer: server, timeout: 6) else {
            return .init(error: PMKError.cancelled)
        }

        return Web3.Eth(provider: web3.provider, web3: web3)
            .getTransactionReceiptPromise(hash)
            .map { TransactionState(status: $0.status) }
    }
}

extension TransactionState {
    init(status: Web3.TransactionReceipt.TXStatus) {
        switch status {
        case .ok:
            self = .completed
        case .failed:
            self = .failed
        case .notYetProcessed:
            self = .pending
        }
    }
}
