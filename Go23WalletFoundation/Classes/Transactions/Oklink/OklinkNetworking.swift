//
//  OklinkNetworking.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation
import Go23WalletCore
import Combine
import SwiftyJSON

//NOTE: as api dosn't return localized operation contract, symbol and decimal for transfer transactions, fetch them from rpc node
public class OklinkApiNetworking: ApiNetworking {
    private static var allHTTPHeaderFields: HTTPHeaders = .init([
        "Content-type": "application/json",
        "client": Bundle.main.bundleIdentifier ?? "",
        "client-build": Bundle.main.buildNumber ?? "",
    ])

    private let server: RPCServer
    private let baseUrl: URL = URL(string: "https://www.oklink.com")!
    private let apiKey: String?
    private let transporter: ApiTransporter
    private let paginationFilter = TransactionPaginationFilter()
    private let ercTokenProvider: TokenProviderType
    private let transactionBuilder: TransactionBuilder

    public init(server: RPCServer,
                apiKey: String?,
                transporter: ApiTransporter,
                ercTokenProvider: TokenProviderType,
                transactionBuilder: TransactionBuilder) {

        self.transactionBuilder = transactionBuilder
        self.ercTokenProvider = ercTokenProvider
        self.server = server
        self.apiKey = apiKey
        self.transporter = transporter
    }

    public func normalTransactions(walletAddress: Go23Wallet.Address,
                                   pagination: TransactionsPagination,
                                   sortOrder: GetTransactions.SortOrder?) -> AnyPublisher<TransactionsResponse<TransactionInstance>, PromiseError> {

        let request = TransactionsRequest(
            baseUrl: baseUrl,
            walletAddress: walletAddress,
            page: pagination.page,
            limit: pagination.limit,
            apiKey: apiKey ?? "",
            chainShortName: server.okLinkChainShortName,
            protocolType: .transaction,
            headers: OklinkApiNetworking.allHTTPHeaderFields)

        let decoder = NormalTransactionListDecoder(pagination: pagination, paginationFilter: paginationFilter)

        return transporter.dataTaskPublisher(request)
            .tryMap { try decoder.decode(data: $0.data) }
            .mapError { PromiseError(error: $0) }
            .flatMap { response in
                self.buildTransactions(transactions: response.transactions)
                    .map {
                        return TransactionsResponse<TransactionInstance>(
                            transactions: Covalent.ToNativeTransactionMapper.mergeTransactionOperationsIntoSingleTransaction($0),
                            pagination: response.pagination)
                    }
            }.eraseToAnyPublisher()
    }

    private func buildTransactions(transactions: [NormalTransaction]) -> AnyPublisher<[TransactionInstance], PromiseError> {
        let publishers = transactions.map { transactionBuilder.buildTransaction(from: $0) }

        return Publishers.MergeMany(publishers)
           .collect()
           .map { $0.compactMap { $0 } }
           .setFailureType(to: PromiseError.self)
           .eraseToAnyPublisher()
    }

    public func erc20TokenTransferTransactions(walletAddress: Go23Wallet.Address,
                                               pagination: TransactionsPagination,
                                               sortOrder: GetTransactions.SortOrder?) -> AnyPublisher<TransactionsResponse<TransactionInstance>, PromiseError> {

        let request = TransactionsRequest(
            baseUrl: baseUrl,
            walletAddress: walletAddress,
            page: pagination.page,
            limit: pagination.limit,
            apiKey: apiKey ?? "",
            chainShortName: server.okLinkChainShortName,
            protocolType: .erc20,
            headers: OklinkApiNetworking.allHTTPHeaderFields)

        let decoder = TransactionListDecoder(pagination: pagination, paginationFilter: paginationFilter)

        return transporter.dataTaskPublisher(request)
            .tryMap { try decoder.decode(data: $0.data) }
            .mapError { PromiseError(error: $0) }
            .flatMap { response -> AnyPublisher<TransactionsResponse<TransactionInstance>, PromiseError> in
                let contracts = response.transactions.compactMap { Go23Wallet.Address(uncheckedAgainstNullAddress: $0.tokenContractAddress) }
                return self.fetchMissingOperationData(contracts: Array(Set(contracts)))
                    .setFailureType(to: PromiseError.self)
                    .map { operations -> TransactionsResponse<TransactionInstance> in
                        let transactions = self.map(erc20TokenTransferTransactions: response.transactions, operations: operations)
                        let mergedTransactions = Covalent.ToNativeTransactionMapper.mergeTransactionOperationsIntoSingleTransaction(transactions)
                        return TransactionsResponse<TransactionInstance>(transactions: mergedTransactions, pagination: response.pagination)
                    }.eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }

    public func erc721TokenTransferTransactions(walletAddress: Go23Wallet.Address,
                                                pagination: TransactionsPagination,
                                                sortOrder: GetTransactions.SortOrder?) -> AnyPublisher<TransactionsResponse<TransactionInstance>, PromiseError> {
        
        let request = TransactionsRequest(
            baseUrl: baseUrl,
            walletAddress: walletAddress,
            page: pagination.page,
            limit: pagination.limit,
            apiKey: apiKey ?? "",
            chainShortName: server.okLinkChainShortName,
            protocolType: .erc721,
            headers: OklinkApiNetworking.allHTTPHeaderFields)

        let decoder = TransactionListDecoder(pagination: pagination, paginationFilter: paginationFilter)

        return transporter.dataTaskPublisher(request)
            .tryMap { try decoder.decode(data: $0.data) }
            .mapError { PromiseError(error: $0) }
            .flatMap { response -> AnyPublisher<TransactionsResponse<TransactionInstance>, PromiseError> in
                let contracts = response.transactions.compactMap { Go23Wallet.Address(uncheckedAgainstNullAddress: $0.tokenContractAddress) }
                return self.fetchMissingOperationData(contracts: Array(Set(contracts)))
                    .setFailureType(to: PromiseError.self)
                    .map { operations -> TransactionsResponse<TransactionInstance> in
                        let transactions = self.map(erc721TokenTransferTransactions: response.transactions, operations: operations)
                        let mergedTransactions = Covalent.ToNativeTransactionMapper.mergeTransactionOperationsIntoSingleTransaction(transactions)
                        return TransactionsResponse<TransactionInstance>(transactions: mergedTransactions, pagination: response.pagination)
                    }.eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }

    public func erc1155TokenTransferTransaction(walletAddress: Go23Wallet.Address,
                                                pagination: TransactionsPagination,
                                                sortOrder: GetTransactions.SortOrder?) -> AnyPublisher<TransactionsResponse<TransactionInstance>, PromiseError> {

        let request = TransactionsRequest(
            baseUrl: baseUrl,
            walletAddress: walletAddress,
            page: pagination.page,
            limit: pagination.limit,
            apiKey: apiKey ?? "",
            chainShortName: server.okLinkChainShortName,
            protocolType: .erc1155,
            headers: OklinkApiNetworking.allHTTPHeaderFields)

        let decoder = TransactionListDecoder(pagination: pagination, paginationFilter: paginationFilter)

        return transporter.dataTaskPublisher(request)
            .tryMap { try decoder.decode(data: $0.data) }
            .mapError { PromiseError(error: $0) }
            .flatMap { response -> AnyPublisher<TransactionsResponse<TransactionInstance>, PromiseError> in
                let contracts = response.transactions.compactMap { Go23Wallet.Address(uncheckedAgainstNullAddress: $0.tokenContractAddress) }
                return self.fetchMissingOperationData(contracts: Array(Set(contracts)))
                    .setFailureType(to: PromiseError.self)
                    .map { operations -> TransactionsResponse<TransactionInstance> in
                        let transactions = self.map(erc1155TokenTransferTransactions: response.transactions, operations: operations)
                        let mergedTransactions = Covalent.ToNativeTransactionMapper.mergeTransactionOperationsIntoSingleTransaction(transactions)
                        return TransactionsResponse<TransactionInstance>(transactions: transactions, pagination: response.pagination)
                    }.eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }

    private func map(erc20TokenTransferTransactions transactions: [Oklink.Transaction],
                     operations: [Go23Wallet.Address: LocalizedOperation]) -> [TransactionInstance] {

        return transactions.compactMap { tx -> TransactionInstance? in
            guard let contract = Go23Wallet.Address(uncheckedAgainstNullAddress: tx.tokenContractAddress) else { return nil }
            let operation = operations[contract]

            let localizedOperation = LocalizedOperationObjectInstance(
                from: tx.from,
                to: tx.to,
                contract: contract,
                type: OperationType.erc20TokenTransfer.rawValue,
                value: String(tx.amount),
                tokenId: "",
                symbol: operation?.symbol ?? tx.transactionSymbol,
                name: operation?.name ?? "",
                decimals: operation?.decimals ?? 18)

            return TransactionInstance(
                id: tx.hash,
                server: server,
                blockNumber: tx.height,
                transactionIndex: 0,
                from: tx.from,
                to: tx.to,
                value: "0",
                gas: "0",
                gasPrice: "0",
                gasUsed: "0",
                nonce: "0",
                date: Date(timeIntervalSince1970: tx.transactionTime / 100),
                localizedOperations: [localizedOperation],
                state: TransactionState(state: tx.state),
                isErc20Interaction: true)
        }
    }

    private func map(erc721TokenTransferTransactions transactions: [Oklink.Transaction],
                     operations: [Go23Wallet.Address: LocalizedOperation]) -> [TransactionInstance] {

        return transactions.compactMap { tx -> TransactionInstance? in
            guard let contract = Go23Wallet.Address(uncheckedAgainstNullAddress: tx.tokenContractAddress) else { return nil }
            let operation = operations[contract]

            let localizedOperation = LocalizedOperationObjectInstance(
                from: tx.from,
                to: tx.to,
                contract: contract,
                type: OperationType.erc721TokenTransfer.rawValue,
                value: String(tx.amount),
                tokenId: tx.tokenId,
                symbol: operation?.symbol ?? tx.transactionSymbol,
                name: operation?.name ?? "",
                decimals: operation?.decimals ?? 0)

            return TransactionInstance(
                id: tx.hash,
                server: server,
                blockNumber: tx.height,
                transactionIndex: 0,
                from: tx.from,
                to: tx.to,
                value: "0",
                gas: "0",
                gasPrice: "0",
                gasUsed: "0",
                nonce: "0",
                date: Date(timeIntervalSince1970: tx.transactionTime / 100),
                localizedOperations: [localizedOperation],
                state: TransactionState(state: tx.state),
                isErc20Interaction: true)
        }
    }

    private func map(erc1155TokenTransferTransactions transactions: [Oklink.Transaction],
                     operations: [Go23Wallet.Address: LocalizedOperation]) -> [TransactionInstance] {

        return transactions.compactMap { tx -> TransactionInstance? in
            guard let contract = Go23Wallet.Address(uncheckedAgainstNullAddress: tx.tokenContractAddress) else { return nil }
            let operation = operations[contract]

            let localizedOperation = LocalizedOperationObjectInstance(
                from: tx.from,
                to: tx.to,
                contract: contract,
                type: OperationType.erc1155TokenTransfer.rawValue,
                value: String(tx.amount),
                tokenId: tx.tokenId,
                //TODO: tokenValue: tx.tokenValue,
                symbol: operation?.symbol ?? tx.transactionSymbol,
                name: operation?.name ?? "",
                decimals: operation?.decimals ?? 0)

            return TransactionInstance(
                id: tx.hash,
                server: server,
                blockNumber: tx.height,
                transactionIndex: 0,
                from: tx.from,
                to: tx.to,
                value: "0",
                gas: "0",
                gasPrice: "0",
                gasUsed: "0",
                nonce: "0",
                date: Date(timeIntervalSince1970: tx.transactionTime / 100),
                localizedOperations: [localizedOperation],
                state: TransactionState(state: tx.state),
                isErc20Interaction: true)
        }
    }

    private typealias LocalizedOperation = (name: String, decimals: Int, symbol: String)
    private func fetchMissingOperationData(contracts: [Go23Wallet.Address]) -> AnyPublisher<[Go23Wallet.Address: LocalizedOperation], Never> {
        let publishers = contracts.map { contract in
            let p1 = ercTokenProvider.getContractName(for: contract)
            let p2 = ercTokenProvider.getDecimals(for: contract)
            let p3 = ercTokenProvider.getContractSymbol(for: contract)

            return Publishers.CombineLatest3(p1, p2, p3)
                .map { (contract: contract, name: $0.0, decimals: $0.1, symbol: $0.2) }
                .map { Optional($0) }
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }

        return Publishers.MergeMany(publishers)
            .collect()
            .map { $0.compactMap { $0 } }
            .map { data -> [Go23Wallet.Address: LocalizedOperation] in
                var values: [Go23Wallet.Address: LocalizedOperation] = [:]
                for each in data { values[each.contract] = (name: each.name, decimals: each.decimals, symbol: each.symbol) }

                return values
            }.eraseToAnyPublisher()
    }
    
}

fileprivate extension TransactionState {
    init(state: Oklink.TransactionState) {
        switch state {
        case .fail:
            self = .error
        case .pending:
            self = .pending
        case .success:
            self = .completed
        }
    }
}

extension OklinkApiNetworking {

    struct TransactionListDecoder {
        let pagination: TransactionsPagination
        let paginationFilter: TransactionPaginationFilter

        func decode(data: Data) throws -> TransactionsResponse<Oklink.Transaction> {
            guard
                let json = try? JSON(data: data),
                let response = Oklink.TransactionListResponse<Oklink.Transaction>(json: json)
            else { throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "")) }

            guard let transactionsData = response.data.first else { return .init(transactions: [], pagination: pagination) }

            let data = paginationFilter.process(transactions: transactionsData.transactionList, pagination: pagination)

            return .init(transactions: data.transactions, pagination: data.pagination)
        }
    }

    struct NormalTransactionListDecoder {
        let pagination: TransactionsPagination
        let paginationFilter: TransactionPaginationFilter

        func decode(data: Data) throws -> TransactionsResponse<NormalTransaction> {
            guard
                let json = try? JSON(data: data),
                let response = Oklink.TransactionListResponse<Oklink.Transaction>(json: json)
            else { throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "")) }

            guard let transactionsData = response.data.first else { return .init(transactions: [], pagination: pagination) }

            let transactions = transactionsData.transactionList.map { NormalTransaction(okLinkTransaction: $0) }
            let data = paginationFilter.process(transactions: transactions, pagination: pagination)

            return .init(transactions: data.transactions, pagination: data.pagination)
        }
    }

    struct TransactionsRequest: URLRequestConvertible {
        let baseUrl: URL
        let walletAddress: Go23Wallet.Address
        let page: Int
        let limit: Int
        let apiKey: String
        let chainShortName: String
        let protocolType: Oklink.ProtocolType
        let headers: HTTPHeaders

        func asURLRequest() throws -> URLRequest {
            guard var components: URLComponents = .init(url: baseUrl, resolvingAgainstBaseURL: false) else {
                throw URLError(.badURL)
            }
            components.path = "/api/v5/explorer/address/transaction-list"
            
            let url = try components.asURL()
            var headers = headers
            headers.add(name: "Ok-Access-Key", value: apiKey)
            let request = try URLRequest(url: url, method: .get, headers: headers)

            return try URLEncoding().encode(request, with: [
                "address": walletAddress.eip55String,
                "protocolType": protocolType.rawValue,
                "chainShortName": chainShortName,
                "page": "\(page)",
                "limit": "\(limit)"
            ])
        }
    }
}

private extension RPCServer {
    var okLinkChainShortName: String {
        switch self {
        case .xDai: return ""
        case .artis_sigma1: return ""
        case .artis_tau1: return ""
        case .binance_smart_chain: return ""
        case .binance_smart_chain_testnet: return ""
        case .heco: return ""
        case .heco_testnet: return ""
        case .main, .callisto, .classic, .goerli: return ""
        case .fantom: return ""
        case .fantom_testnet: return ""
        case .avalanche: return ""
        case .avalanche_testnet: return ""
        case .polygon: return ""
        case .mumbai_testnet: return ""
        case .optimistic: return ""
        case .cronosMainnet: return ""
        case .cronosTestnet: return ""
        case .custom(let custom): return ""
        case .arbitrum: return ""
        case .palm: return ""
        case .palmTestnet: return ""
        case .klaytnCypress: return ""
        case .klaytnBaobabTestnet: return ""
        case .ioTeX: return ""
        case .ioTeXTestnet: return ""
        case .optimismGoerli: return ""
        case .arbitrumGoerli: return ""
        case .okx: return "OKC"
        }
    }
}
