//
//  EnjinNetworking.swift
//  Go23Wallet
//
//  Created by Vladyslav Shepitko on 27.04.2022.
//

import Foundation
import Go23WalletCore
import Apollo
import Combine
import Go23WalletAddress

final class EnjinNetworking {

    typealias BalancesPublisher = AnyPublisher<[GetEnjinBalancesQuery.Data.EnjinBalance], PromiseError>
    typealias TokensPublisher = AnyPublisher<EnjinTokensResponse, PromiseError>
    typealias TokenPublisher = AnyPublisher<EnjinToken, PromiseError>

    private lazy var graphqlClient: ApolloClient = {
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        let provider = NetworkInterceptorProvider(store: store, client: URLSessionClient())
        let transport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: Constants.Enjin.apiUrl)

        return ApolloClient(networkTransport: transport, store: store)
    }()

    func getEnjinBalances(owner: Go23Wallet.Address,
                          offset: Int,
                          balances: [GetEnjinBalancesQuery.Data.EnjinBalance] = [],
                          limit: Int = 50) -> BalancesPublisher {

        return getEnjinBalances(owner: owner, offset: offset)
            .flatMap { [weak self] result -> BalancesPublisher in
                guard let strongSelf = self else { return .empty() }

                if result.isEmpty {
                    return .just(balances)
                } else {
                    return strongSelf.getEnjinBalances(owner: owner, offset: offset + 1, balances: balances + result)
                }
            }.eraseToAnyPublisher()
    }

    func getEnjinTokens(balances: [EnjinBalance], owner: Go23Wallet.Address) -> TokensPublisher {
        if balances.isEmpty {
            return .just(EnjinTokensResponse(owner: owner, tokens: []))
        }

        let promises = balances.map { getEnjinToken(balance: $0) }

        return Publishers.MergeMany(promises).collect()
            .map { EnjinTokensResponse(owner: owner, tokens: $0) }
            .eraseToAnyPublisher()
    }

    private func getEnjinBalances(owner: Go23Wallet.Address,
                                  offset: Int,
                                  limit: Int = 50) -> BalancesPublisher {

        BalancesPublisher.create { [graphqlClient] seal in
            let cancellable = graphqlClient.fetch(query: GetEnjinBalancesQuery(ethAddress: owner.eip55String, page: offset, limit: limit)) { response in
                switch response {
                case .failure(let error):
                    seal.send(completion: .failure(PromiseError(error: error)))
                case .success(let graphQLResult):
                    let balances = (graphQLResult.data?.enjinBalances ?? []).compactMap { $0 }
                    seal.send(balances)
                    seal.send(completion: .finished)
                }
            }

            return AnyCancellable {
                cancellable.cancel()
            }
        }
    }

    private func getEnjinToken(balance: EnjinBalance) -> TokenPublisher {
        return TokenPublisher.create { [graphqlClient] seal in
            let cancellable = graphqlClient.fetch(query: GetEnjinTokenQuery(id: balance.tokenId)) { response in
                switch response {
                case .failure(let error):
                    seal.send(completion: .failure(PromiseError(error: error)))
                case .success(let graphQLResult):
                    guard let token = graphQLResult.data?.enjinToken.flatMap({ EnjinToken(token: $0, balance: balance) }) else {
                        let error = EnjinError(localizedDescription: "Enjin token \(balance) not found")
                        seal.send(completion: .failure(PromiseError(error: error)))
                        return
                    }

                    seal.send(token)
                    seal.send(completion: .finished)
                }
            }

            return AnyCancellable {
                cancellable.cancel()
            }
        }
    }
}

final private class NetworkInterceptorProvider: InterceptorProvider {
    // These properties will remain the same throughout the life of the `InterceptorProvider`, even though they
    // will be handed to different interceptors.
    private let store: ApolloStore
    private let client: URLSessionClient
    private let enjinUserManagementInterceptor: EnjinUserManagementInterceptor

    init(store: ApolloStore, client: URLSessionClient) {
        self.store = store
        self.client = client
        self.enjinUserManagementInterceptor = EnjinUserManagementInterceptor(store: store, client: client)
    }

    func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        return [
            MaxRetryInterceptor(),
            CacheReadInterceptor(store: store),
            enjinUserManagementInterceptor,
            NetworkFetchInterceptor(client: client),
            ResponseCodeInterceptor(),
            JSONResponseParsingInterceptor(cacheKeyForObject: store.cacheKeyForObject),
            AutomaticPersistedQueryInterceptor(),
            CacheWriteInterceptor(store: store)
        ]
    }
}

