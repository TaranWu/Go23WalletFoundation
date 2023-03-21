//
//  DomainResolutionServiceType.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation 
import Combine
import Go23WalletCore

public protocol DomainResolutionServiceType {
    func resolveAddress(string value: String) -> AnyPublisher<Go23Wallet.Address, PromiseError>
    func resolveEns(address: Go23Wallet.Address) -> AnyPublisher<EnsName, PromiseError>
    func resolveEnsAndBlockie(address: Go23Wallet.Address) -> AnyPublisher<BlockieAndAddressOrEnsResolution, PromiseError>
    func resolveAddressAndBlockie(string: String) -> AnyPublisher<BlockieAndAddressOrEnsResolution, PromiseError>
}

public protocol CachebleAddressResolutionServiceType {
    func cachedAddressValue(for name: String) -> Go23Wallet.Address?
}

public protocol CachedEnsResolutionServiceType {
    func cachedEnsValue(for address: Go23Wallet.Address) -> String?
}
