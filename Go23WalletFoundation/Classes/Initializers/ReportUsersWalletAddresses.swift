//
//  ReportUsersWalletAddresses.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation
import Combine

public final class ReportUsersWalletAddresses: Initializer {
    private let keystore: Keystore
    private var cancelable = Set<AnyCancellable>()
    
    public init(keystore: Keystore) {
        self.keystore = keystore
    }

    public func perform() {
        //NOTE: make 2 sec delay to avoid load on launch
        keystore.walletsPublisher
            .delay(for: .seconds(2), scheduler: RunLoop.main)
            .sink { crashlytics.track(wallets: Array($0)) }
            .store(in: &cancelable)
    }
}
