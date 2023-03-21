//
//  ExecuteOnceOnly.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public typealias ExecuteOnceOnlyClosure = (() -> Void)

public class ExecuteOnceOnly {

    private var didFire: Bool

    public init() {
        didFire = false
    }

    public func once(completion: ExecuteOnceOnlyClosure) {
        guard !didFire else { return }
        completion()
        didFire = true
    }

}
