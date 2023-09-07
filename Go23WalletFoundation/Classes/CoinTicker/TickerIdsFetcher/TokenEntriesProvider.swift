//
//  TokenEntriesProvider.swift
//  Go23WalletFoundation
//
//  Created by Vladyslav Shepitko on 05.09.2022.
//

import Foundation
import Combine
import Go23WalletCore

/// Provides tokens groups
public protocol TokenEntriesProvider {
    func tokenEntries() -> AnyPublisher<[TokenEntry], PromiseError>
}
