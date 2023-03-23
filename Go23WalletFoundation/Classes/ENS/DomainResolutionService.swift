//
//  DomainResolutionServiceType.swift
//  Go23Wallet
//
//  Created by Vladyslav Shepitko on 27.01.2022.
//

import Foundation
import Combine
import Go23WalletENS
import Go23WalletCore
import Go23WalletAddress

public class DomainResolutionService {
    private let storage: EnsRecordsStorage
    private let blockiesGenerator: BlockiesGenerator
    private lazy var getEnsAddressResolver = EnsResolver(storage: storage, blockchainProvider: blockchainProvider)
    private lazy var unstoppableDomainsV2Resolver = UnstoppableDomainsV2Resolver(server: blockchainProvider.server, storage: storage, networkService: networkService)
    private lazy var ensReverseLookupResolver = EnsReverseResolver(storage: storage, blockchainProvider: blockchainProvider)
    private let networkService: NetworkService
    private let blockchainProvider: BlockchainProvider

    public init(blockiesGenerator: BlockiesGenerator, storage: EnsRecordsStorage, networkService: NetworkService, blockchainProvider: BlockchainProvider) {
        self.blockchainProvider = blockchainProvider
        self.blockiesGenerator = blockiesGenerator
        self.storage = storage
        self.networkService = networkService
    }
}

extension DomainResolutionService: DomainResolutionServiceType {
    public func resolveAddress(string value: String) -> AnyPublisher<Go23Wallet.Address, PromiseError> {

        let services: [CachebleAddressResolutionServiceType] = [
            getEnsAddressResolver,
            unstoppableDomainsV2Resolver
        ]

        if let cached = services.compactMap({ $0.cachedAddressValue(for: value) }).first {
            return .just(cached)
        }

        return Just(value)
            .setFailureType(to: SmartContractError.self)
            .flatMap { [getEnsAddressResolver] value in
                getEnsAddressResolver.getENSAddressFromResolver(for: value)
            }.catch { [unstoppableDomainsV2Resolver] _ -> AnyPublisher<Go23Wallet.Address, PromiseError> in
                unstoppableDomainsV2Resolver.resolveAddress(forName: value)
            }.receive(on: RunLoop.main)//We want to be sure it's on main
            .eraseToAnyPublisher()
    }

    public func resolveEnsAndBlockie(address: Go23Wallet.Address) -> AnyPublisher<BlockieAndAddressOrEnsResolution, PromiseError> {

        func getBlockieImage(for ens: String) -> AnyPublisher<BlockieAndAddressOrEnsResolution, PromiseError> {
            return blockiesGenerator.getBlockieOrEnsAvatarImage(address: address, ens: ens)
                .map { image -> BlockieAndAddressOrEnsResolution in
                    return (image, .resolved(.ensName(ens)))
                }.catch { _ -> AnyPublisher<BlockieAndAddressOrEnsResolution, PromiseError> in
                    return .just((nil, .resolved(.ensName(ens))))
                }.eraseToAnyPublisher()
        }

        return resolveEns(address: address)
            .flatMap { getBlockieImage(for: $0) }
            .eraseToAnyPublisher()
    }

    public func resolveAddressAndBlockie(string: String) -> AnyPublisher<BlockieAndAddressOrEnsResolution, PromiseError> {

        func getBlockieImage(for addr: Go23Wallet.Address) -> AnyPublisher<BlockieAndAddressOrEnsResolution, PromiseError> {
            return blockiesGenerator.getBlockieOrEnsAvatarImage(address: addr, ens: string)
                .map { image -> BlockieAndAddressOrEnsResolution in
                    return (image, .resolved(.address(addr)))
                }.catch { _ -> AnyPublisher<BlockieAndAddressOrEnsResolution, PromiseError> in
                    return .just((nil, .resolved(.address(addr))))
                }.eraseToAnyPublisher()
        }

        return resolveAddress(string: string)
            .flatMap { getBlockieImage(for: $0) }
            .eraseToAnyPublisher()
    }

    public func resolveEns(address: Go23Wallet.Address) -> AnyPublisher<EnsName, PromiseError> {
        let services: [CachedEnsResolutionServiceType] = [
            ensReverseLookupResolver,
            unstoppableDomainsV2Resolver
        ]

        if let cached = services.compactMap({ $0.cachedEnsValue(for: address) }).first {
            return .just(cached)
        }

        return Just(address)
            .setFailureType(to: SmartContractError.self)
            .flatMap { [ensReverseLookupResolver] address in
                ensReverseLookupResolver.getENSNameFromResolver(for: address)
            }.catch { [unstoppableDomainsV2Resolver] _ -> AnyPublisher<String, PromiseError> in
                unstoppableDomainsV2Resolver.resolveDomain(address: address)
            }.receive(on: RunLoop.main)//We want to be sure it's on main
            .eraseToAnyPublisher()
    }
}
