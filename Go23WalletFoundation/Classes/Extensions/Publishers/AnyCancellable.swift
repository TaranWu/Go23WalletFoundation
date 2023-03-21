//
//  AnyCancellable.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation
import Combine

extension Set where Element: AnyCancellable {
    public mutating func cancellAll() {
        for each in self {
            each.cancel()
        }

        removeAll()
    }
}
