//
//  CleanupPasscode.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public final class CleanupPasscode: Initializer {
    private let lock: Lock// = Lock(securedStorage: SecuredPasswordStorage & SecuredStorage)
    private let keystore: Keystore

    public init(keystore: Keystore, lock: Lock) {
        self.keystore = keystore
        self.lock = lock
    }

    public func perform() {
        //We should clean passcode if there is no wallets. This step is required for app reinstall.
        if !keystore.hasWallets {
            lock.clear()
        }
    }
}
