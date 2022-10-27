//
//  WalletStorage.swift
//  DerbyWallet
//
//  Created by Vladyslav Shepitko on 22.06.2022.
//

import Foundation
import DerbyWalletCore

public protocol WalletStorage {
    func name(for address: DerbyWallet.Address) -> String?
    func addOrUpdate(name: String?, for address: DerbyWallet.Address)
}

public class FileWalletStorage: NSObject, WalletStorage {
    private let storage: Storage<[DerbyWallet.Address: String]>

    public init(config: Config = .init()) {
        storage = .init(fileName: "wallet_names", defaultValue: [:])
        super.init()
        FileWalletStorage.migrateWalletNamesFromUserDefaults(config: config, into: self)
    }

    public func name(for address: DerbyWallet.Address) -> String? {
        storage.value[address]
    }

    public func addOrUpdate(name: String?, for address: DerbyWallet.Address) {
        if let name = name, name.nonEmpty {
            storage.value[address] = name
        } else {
            storage.value[address] = .none
        }
    }
}

private extension FileWalletStorage {
    static func migrateWalletNamesFromUserDefaults(config: Config, into storage: WalletStorage) {
        //NOTE: migrate old names from user defaults to file storage
        if !config.walletNames.isEmpty {
            for wallet in config.walletNames.keys {
                storage.addOrUpdate(name: config.walletNames[wallet], for: wallet)
            }

            config.removeAllWalletNames()
        }
    }
}
