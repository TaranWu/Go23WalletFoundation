//
//  GetGasPrice.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation
import BigInt
import APIKit
import Go23JSONRPCKit
import Combine
import Go23WalletCore

public typealias APIKitSession = APIKit.Session
public typealias SessionTaskError = APIKit.SessionTaskError
public typealias JSONRPCError = Go23JSONRPCKit.JSONRPCError

extension SessionTaskError {
    init(error: Error) {
        if let e = error as? SessionTaskError {
            self = e
        } else {
            self = .responseError(error)
        }
    }

    public var unwrapped: Error {
        switch self {
        case .connectionError(let e):
            return e
        case .requestError(let e):
            return e
        case .responseError(let e):
            return e
        }
    }
}

final class GetGasPrice {
    private let analytics: AnalyticsLogger
    private let server: RPCServer
    private let params: BlockchainParams

    init(server: RPCServer, params: BlockchainParams, analytics: AnalyticsLogger) {
        self.server = server
        self.params = params
        self.analytics = analytics
    }

    func getGasEstimates() -> AnyPublisher<BigUInt, SessionTaskError> {
        let request = EtherServiceRequest(server: server, batch: BatchFactory().create(GasPriceRequest()))
        let maxPrice: BigUInt = GasPriceConfiguration.maxPrice(forServer: server)
        let defaultPrice: BigUInt = GasPriceConfiguration.defaultPrice(forServer: server)

        return APIKitSession
            .sendPublisher(request, server: server, analytics: analytics)
    }
}
