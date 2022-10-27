//
//  TokenEntriesProvider.swift
//  DerbyWalletFoundation
//
//  Created by Tatan.
//

import Foundation
import Combine
import DerbyWalletCore

/// Provides tokens groups
public protocol TokenEntriesProvider {
    func tokenEntries() -> AnyPublisher<[TokenEntry], PromiseError>
}
