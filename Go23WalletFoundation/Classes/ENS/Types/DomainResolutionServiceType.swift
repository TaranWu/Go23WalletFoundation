//
//  DomainResolutionServiceType.swift
//  Go23Wallet
//
//  Created by Vladyslav Shepitko on 30.08.2022.
//

import Foundation 
import Combine
import Go23WalletCore
import Go23WalletAddress

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
