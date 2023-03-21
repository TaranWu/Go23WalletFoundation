//
//  Repeat.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public func repeatTimes(_ times: Int, block: () -> Void) {
    for _ in 0..<times {
        block()
    }
}
