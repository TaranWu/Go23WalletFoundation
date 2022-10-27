//
//  RequesterViewModel.swift
//  DerbyWallet
//
//  Created by Tatan.
//

import Foundation

public protocol RequesterViewModel {
    var requester: Requester { get }
    var viewModels: [Any] { get }
}

extension RequesterViewModel {
    public var iconUrl: URL? { return requester.iconUrl }
}
