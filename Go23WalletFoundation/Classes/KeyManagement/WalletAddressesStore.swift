//
//  WalletStore.swift
//  DerbyWallet
//
//  Created by Vladyslav Shepitko on 21.01.2022.
//

import Foundation
import Combine

public protocol WalletAddressesStoreMigration {
    func migrate(to store: WalletAddressesStore) -> WalletAddressesStore
}

public protocol WalletAddressesStore: WalletAddressesStoreMigration {
    var watchAddresses: [String] { get set }
    var ethereumAddressesWithPrivateKeys: [String] { get set }
    var ethereumAddressesWithSeed: [String] { get set }
    var ethereumAddressesProtectedByUserPresence: [String] { get set }
    var hasWallets: Bool { get }
    var wallets: [Wallet] { get }
    var hasMigratedFromKeystoreFiles: Bool { get }
    var recentlyUsedWallet: Wallet? { get set }
    var walletsPublisher: AnyPublisher<Set<Wallet>, Never> { get }
    var didAddWalletPublisher: AnyPublisher<DerbyWallet.Address, Never> { get }
    var didRemoveWalletPublisher: AnyPublisher<Wallet, Never> { get }

    mutating func removeAddress(_ account: Wallet)
    mutating func addToListOfWatchEthereumAddresses(_ address: DerbyWallet.Address)
    mutating func addToListOfEthereumAddressesWithPrivateKeys(_ address: DerbyWallet.Address)
    mutating func addToListOfEthereumAddressesWithSeed(_ address: DerbyWallet.Address)
    mutating func addToListOfEthereumAddressesProtectedByUserPresence(_ address: DerbyWallet.Address)
}

extension WalletAddressesStore {

    public func migrate(to store: WalletAddressesStore) -> WalletAddressesStore {
        var migrateStore = store
        migrateStore.watchAddresses = watchAddresses
        migrateStore.ethereumAddressesWithPrivateKeys = ethereumAddressesWithPrivateKeys
        migrateStore.ethereumAddressesWithSeed = ethereumAddressesWithSeed
        migrateStore.ethereumAddressesProtectedByUserPresence = ethereumAddressesProtectedByUserPresence

        return migrateStore
    }
}
