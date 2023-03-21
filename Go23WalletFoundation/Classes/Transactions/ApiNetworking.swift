//
//  ApiNetworking.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import Combine
import Go23WalletCore

public struct TransactionsResponse<T> {
    public let transactions: [T]
    public let pagination: TransactionsPagination

    public init(transactions: [T], pagination: TransactionsPagination) {
        self.transactions = transactions
        self.pagination = pagination
    }
}

public protocol ApiNetworking {
    func normalTransactions(walletAddress: Go23Wallet.Address,
                            pagination: TransactionsPagination,
                            sortOrder: GetTransactions.SortOrder?) -> AnyPublisher<TransactionsResponse<TransactionInstance>, PromiseError>

    func erc20TokenTransferTransactions(walletAddress: Go23Wallet.Address,
                                        pagination: TransactionsPagination,
                                        sortOrder: GetTransactions.SortOrder?) -> AnyPublisher<TransactionsResponse<TransactionInstance>, PromiseError>

    func erc721TokenTransferTransactions(walletAddress: Go23Wallet.Address,
                                         pagination: TransactionsPagination,
                                         sortOrder: GetTransactions.SortOrder?) -> AnyPublisher<TransactionsResponse<TransactionInstance>, PromiseError>

    func erc1155TokenTransferTransaction(walletAddress: Go23Wallet.Address,
                                         pagination: TransactionsPagination,
                                         sortOrder: GetTransactions.SortOrder?) -> AnyPublisher<TransactionsResponse<TransactionInstance>, PromiseError>
}
