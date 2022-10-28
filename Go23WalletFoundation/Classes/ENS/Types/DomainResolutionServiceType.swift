//
//  DomainResolutionServiceType.swift
//  DerbyWallet
//
//  Created by Vladyslav Shepitko on 30.08.2022.
//

import Foundation 
import Combine
import Go23WalletCore

public protocol DomainResolutionServiceType {
    func resolveAddress(string value: String) -> AnyPublisher<DerbyWallet.Address, PromiseError>
    func resolveEns(address: DerbyWallet.Address) -> AnyPublisher<EnsName, PromiseError>
    func resolveEnsAndBlockie(address: DerbyWallet.Address) -> AnyPublisher<BlockieAndAddressOrEnsResolution, PromiseError>
    func resolveAddressAndBlockie(string: String) -> AnyPublisher<BlockieAndAddressOrEnsResolution, PromiseError>
}

public protocol CachebleAddressResolutionServiceType {
    func cachedAddressValue(for name: String) -> DerbyWallet.Address?
}

public protocol CachedEnsResolutionServiceType {
    func cachedEnsValue(for address: DerbyWallet.Address) -> String?
}
