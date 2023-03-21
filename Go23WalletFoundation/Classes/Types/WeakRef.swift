//
//  WeakRef.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public class WeakRef<T: AnyObject> {
    public weak var object: T?
    public init(object: T) {
        self.object = object
    }
}
