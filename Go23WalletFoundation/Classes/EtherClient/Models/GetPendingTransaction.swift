//
//  GetPendingTransaction.swift
//  Go23Wallet
//
//  Created by Vladyslav Shepitko on 20.08.2022.
//

import Foundation
import APIKit
import Go23JSONRPCKit
import PromiseKit
import Combine

public final class GetPendingTransaction {
    private let server: RPCServer
    private let analytics: AnalyticsLogger

    public init(server: RPCServer, analytics: AnalyticsLogger) {
        self.server = server
        self.analytics = analytics
    }

    public func getPendingTransaction(hash: String) -> Promise<EthereumTransaction?> {
        let request = GetTransactionRequest(hash: hash)
        return APIKitSession.send(EtherServiceRequest(server: server, batch: BatchFactory().create(request)), server: server, analytics: analytics)
    }

    //TODO log `Analytics.WebApiErrors.rpcNodeRateLimited` when appropriate too
    public func getPendingTransaction(server: RPCServer, hash: String) -> AnyPublisher<EthereumTransaction?, SessionTaskError> {
        let request = GetTransactionRequest(hash: hash)
        
        return Session.sendPublisher(EtherServiceRequest(server: server, batch: BatchFactory().create(request)), server: server, analytics: analytics)
    }
}
