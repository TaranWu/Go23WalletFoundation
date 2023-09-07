//
//  GetGasLimit.swift
//  DerbyWallet
//
//  Created by Vladyslav Shepitko on 18.08.2022.
//

import Foundation
import APIKit
import BigInt
import Go23JSONRPCKit
import PromiseKit

public final class GetGasLimit {
    private let account: Wallet
    private let server: RPCServer
    private let analytics: AnalyticsLogger

    public init(account: Wallet, server: RPCServer, analytics: AnalyticsLogger) {
        self.account = account
        self.server = server
        self.analytics = analytics
    }

    public func getGasLimit(value: BigInt, toAddress: DerbyWallet.Address?, data: Data) -> Promise<BigInt> {
        let transactionType: EstimateGasRequest.TransactionType
        if let toAddress = toAddress {
            transactionType = .normal(to: toAddress)
        } else {
            transactionType = .contractDeployment
        }

        let request = EstimateGasRequest(from: account.address, transactionType: transactionType, value: value, data: data)

        return firstly {
            APIKitSession.send(EtherServiceRequest(server: server, batch: BatchFactory().create(request)), server: server, analytics: analytics)
        }.map { gasLimit -> BigInt in
            return BigInt(gasLimit.drop0x, radix: 16) ?? BigInt()
        }
    }
}
