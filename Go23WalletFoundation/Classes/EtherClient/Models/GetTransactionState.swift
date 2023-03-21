//
//  GetTransactionState.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import PromiseKit
import Go23JSONRPCKit
import APIKit

public final class GetTransactionState {
    private let server: RPCServer
    private let analytics: AnalyticsLogger

    public init(server: RPCServer, analytics: AnalyticsLogger) {
        self.server = server
        self.analytics = analytics
    }

    public func getTransactionsState(hash: String) -> Promise<TransactionState> {
        let request = EtherServiceRequest(server: server, batch: BatchFactory().create(TransactionReceiptRequest(hash: hash)))
        let promise = firstly {
            APIKitSession.send(request, server: server, analytics: analytics)
        }.map { TransactionState(status: $0.status) }

        return promise
    }

}
