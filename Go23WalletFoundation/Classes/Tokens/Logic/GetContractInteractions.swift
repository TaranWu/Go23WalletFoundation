//
// Created by James Sangalli on 6/6/18.
// Copyright © 2018 Stormbird PTE. LTD.
//

import Foundation
import PromiseKit
import SwiftyJSON
import Combine
import Go23WalletCore

class GetContractInteractions {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getContractList(walletAddress: Go23Wallet.Address, server: RPCServer, startBlock: Int? = nil, erc20: Bool) -> AnyPublisher<UniqueNonEmptyContracts, PromiseError> {
        let request = GetContractList(walletAddress: walletAddress, server: server, startBlock: startBlock, erc20: erc20)
        return networkService
            .dataTaskPublisher(request)
            .receive(on: DispatchQueue.global())
            .tryMap { UniqueNonEmptyContracts(json: try JSON(data: $0.data)) }
            .mapError { PromiseError.some(error: $0) }
            .eraseToAnyPublisher()
    }
}

extension GetContractInteractions {
    private struct GetContractList: URLRequestConvertible {
        let walletAddress: Go23Wallet.Address
        let server: RPCServer
        let startBlock: Int?
        let erc20: Bool

        func asURLRequest() throws -> URLRequest {
            let etherscanURL: URL
            if erc20 {
                if let url = server.getEtherscanURLForTokenTransactionHistory(for: walletAddress, startBlock: startBlock) {
                    etherscanURL = url
                } else {
                    throw URLError(.badURL)
                }
            } else {
                if let url = server.getEtherscanURLForGeneralTransactionHistory(for: walletAddress, startBlock: startBlock) {
                    etherscanURL = url
                } else {
                    throw URLError(.badURL)
                }
            }

            return try URLRequest(url: etherscanURL, method: .get)
        }
    }
}

class TransactionsNetworkProvider {
    private let walletAddress: Go23Wallet.Address
    private let server: RPCServer
    private var networkService: NetworkService
    private var transactionBuilder: TransactionBuilder

    init(session: WalletSession,
         networkService: NetworkService,
         transactionBuilder: TransactionBuilder) {
        
        self.walletAddress = session.account.address
        self.transactionBuilder = transactionBuilder
        self.networkService = networkService
        self.server = session.server
    }

    func getErc20Transactions(startBlock: Int? = nil) -> AnyPublisher<([TransactionInstance], Int), PromiseError> {
        return getErc20Transactions(walletAddress: walletAddress, server: server, startBlock: startBlock)
            .flatMap { transactions -> AnyPublisher<([TransactionInstance], Int), PromiseError> in
                let (result, minBlockNumber, maxBlockNumber) = GetContractInteractions.functional.extractBoundingBlockNumbers(fromTransactions: transactions)
                return self.backFillTransactionGroup(result, startBlock: minBlockNumber, endBlock: maxBlockNumber)
                    .map { ($0, maxBlockNumber) }
                    .eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }

    func getErc721Transactions(startBlock: Int? = nil) -> AnyPublisher<([TransactionInstance], Int), PromiseError> {
        return getErc721Transactions(walletAddress: walletAddress, server: server, startBlock: startBlock)
            .flatMap { transactions -> AnyPublisher<([TransactionInstance], Int), PromiseError> in
                let (result, minBlockNumber, maxBlockNumber) = GetContractInteractions.functional.extractBoundingBlockNumbers(fromTransactions: transactions)
                return self.backFillTransactionGroup(result, startBlock: minBlockNumber, endBlock: maxBlockNumber)
                    .map { ($0, maxBlockNumber) }
                    .eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }

    func getTransactions(startBlock: Int, endBlock: Int = 999_999_999, sortOrder: GetTransactions.SortOrder) -> AnyPublisher<[TransactionInstance], PromiseError> {
        return networkService
            .dataTaskPublisher(GetTransactions(server: server, address: walletAddress, startBlock: startBlock, endBlock: endBlock, sortOrder: sortOrder))
            .receive(on: DispatchQueue.global())
            .mapError { PromiseError(error: $0) }
            .flatMap { [transactionBuilder] result -> AnyPublisher<[TransactionInstance], PromiseError> in
                if result.response.statusCode == 404 {
                    return .fail(.some(error: URLError(URLError.Code(rawValue: 404)))) // Clearer than a JSON deserialization error when it's a 404
                }

                do {
                    let promises = try JSONDecoder().decode(ArrayResponse<NormalTransaction>.self, from: result.data)
                        .result.map { transactionBuilder.buildTransaction(from: $0) }

                    return Publishers.MergeMany(promises)
                        .collect()
                        .map { $0.compactMap { $0 } }
                        .setFailureType(to: PromiseError.self)
                        .eraseToAnyPublisher()
                } catch {
                    return .fail(.some(error: error))
                }
            }.eraseToAnyPublisher()
    }

    //TODO: rename this since it might include ERC721 (blockscout and compatible like Polygon's). Or can we make this really fetch ERC20, maybe by filtering the results?
    private func getErc20Transactions(walletAddress: Go23Wallet.Address, server: RPCServer, startBlock: Int? = nil) -> AnyPublisher<[TransactionInstance], PromiseError> {
        return networkService
            .dataTaskPublisher(GetErc20TransactionsRequest(startBlock: startBlock, server: server, walletAddress: walletAddress))
            .receive(on: DispatchQueue.global())
            .tryMap { GetContractInteractions.functional.decodeTransactions(json: JSON($0.data), server: server) }
            .mapError { PromiseError.some(error: $0) }
            .eraseToAnyPublisher()
    }

    private func getErc721Transactions(walletAddress: Go23Wallet.Address, server: RPCServer, startBlock: Int? = nil) -> AnyPublisher<[TransactionInstance], PromiseError> {
        return networkService
            .dataTaskPublisher(GetErc721TransactionsRequest(startBlock: startBlock, server: server, walletAddress: walletAddress))
            .receive(on: DispatchQueue.global())
            .tryMap { GetContractInteractions.functional.decodeTransactions(json: JSON($0.data), server: server) }
            .mapError { PromiseError.some(error: $0) }
            .eraseToAnyPublisher()
    }

    private func backFillTransactionGroup(_ transactions: [TransactionInstance], startBlock: Int, endBlock: Int) -> AnyPublisher<[TransactionInstance], PromiseError> {
        guard !transactions.isEmpty else { return .just([]) }

        return getTransactions(startBlock: startBlock, endBlock: endBlock, sortOrder: .asc)
            .map { filledTransactions -> [TransactionInstance] in
                var results: [TransactionInstance] = .init()
                for each in transactions {
                    //ERC20 transactions are expected to have operations because of the API we use to retrieve them from
                    guard !each.localizedOperations.isEmpty else { continue }
                    if var transaction = filledTransactions.first(where: { $0.blockNumber == each.blockNumber }) {
                        transaction.isERC20Interaction = true
                        transaction.localizedOperations = each.localizedOperations
                        results.append(transaction)
                    } else {
                        results.append(each)
                    }
                }
                return results
            }.eraseToAnyPublisher()
    }
}

extension TransactionsNetworkProvider {
    private struct GetErc20TransactionsRequest: URLRequestConvertible {
        let startBlock: Int?
        let server: RPCServer
        let walletAddress: Go23Wallet.Address

        func asURLRequest() throws -> URLRequest {
            guard let url = server.getEtherscanURLForTokenTransactionHistory(for: walletAddress, startBlock: startBlock) else { throw URLError(.badURL) }
            return try URLRequest(url: url, method: .get)
        }
    }

    private struct GetErc721TransactionsRequest: URLRequestConvertible {
        let startBlock: Int?
        let server: RPCServer
        let walletAddress: Go23Wallet.Address

        func asURLRequest() throws -> URLRequest {
            guard let url = server.getEtherscanURLForERC721TransactionHistory(for: walletAddress, startBlock: startBlock) else { throw URLError(.badURL) }
            return try URLRequest(url: url, method: .get)
        }
    }
}

extension GetContractInteractions {
    class functional {}
}

extension GetContractInteractions.functional {

    static func extractBoundingBlockNumbers(fromTransactions transactions: [TransactionInstance]) -> (transactions: [TransactionInstance], min: Int, max: Int) {
        let blockNumbers = transactions.map(\.blockNumber)
        if let minBlockNumber = blockNumbers.min(), let maxBlockNumber = blockNumbers.max() {
            return (transactions: transactions, min: minBlockNumber, max: maxBlockNumber)
        } else {
            return (transactions: [], min: 0, max: 0)
        }
    }

    static func decodeTransactions(json: JSON, server: RPCServer) -> [TransactionInstance] {
        let filteredResult: [(String, JSON)] = json["result"].filter { $0.1["to"].stringValue.hasPrefix("0x") }

        let transactions: [TransactionInstance] = filteredResult.map { result in
            let transactionJson = result.1
            //Blockscout (and compatible like Polygon's) includes ERC721 transfers
            let operationType: OperationType
            //TODO check have tokenID + no "value", cos those might be ERC1155?
            if let tokenId = transactionJson["tokenID"].string, !tokenId.isEmpty {
                operationType = .erc721TokenTransfer
            } else {
                operationType = .erc20TokenTransfer
            }

            let localizedTokenObj = LocalizedOperationObjectInstance(
                    from: transactionJson["from"].stringValue,
                    to: transactionJson["to"].stringValue,
                    contract: Go23Wallet.Address(uncheckedAgainstNullAddress: transactionJson["contractAddress"].stringValue),
                    type: operationType.rawValue,
                    value: transactionJson["value"].stringValue,
                    tokenId: transactionJson["tokenID"].stringValue,
                    symbol: transactionJson["tokenSymbol"].stringValue,
                    name: transactionJson["tokenName"].stringValue,
                    decimals: transactionJson["tokenDecimal"].intValue)

            return TransactionInstance(
                    id: transactionJson["hash"].stringValue,
                    server: server,
                    blockNumber: transactionJson["blockNumber"].intValue,
                    transactionIndex: transactionJson["transactionIndex"].intValue,
                    from: transactionJson["from"].stringValue,
                    to: transactionJson["to"].stringValue,
                    //Must not set the value of the ERC20 token transferred as the native crypto value transferred
                    value: "0",
                    gas: transactionJson["gas"].stringValue,
                    gasPrice: transactionJson["gasPrice"].stringValue,
                    gasUsed: transactionJson["gasUsed"].stringValue,
                    nonce: transactionJson["nonce"].stringValue,
                    date: Date(timeIntervalSince1970: transactionJson["timeStamp"].doubleValue),
                    localizedOperations: [localizedTokenObj],
                    //The API only returns successful transactions
                    state: .completed,
                    isErc20Interaction: true)
        }
        return mergeTransactionOperationsIntoSingleTransaction(transactions)
    }

    static func mergeTransactionOperationsIntoSingleTransaction(_ transactions: [TransactionInstance]) -> [TransactionInstance] {
        var results: [TransactionInstance] = .init()
        for each in transactions {
            if let index = results.firstIndex(where: { $0.blockNumber == each.blockNumber }) {
                var found = results[index]
                found.localizedOperations.append(contentsOf: each.localizedOperations)
                results[index] = found
            } else {
                results.append(each)
            }
        }
        return results
    }
}
