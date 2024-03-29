// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Go23WalletAddress

public enum WalletType: Equatable, Hashable, CustomStringConvertible {
    case real(Go23Wallet.Address)
    case watch(Go23Wallet.Address)
    case hardware(Go23Wallet.Address)

    public var description: String {
        switch self {
        case .real(let address):
            return ".real(\(address.eip55String))"
        case .watch(let address):
            return ".watch(\(address.eip55String))"
        case .hardware(let address):
            return ".hardware(\(address.eip55String))"
        }
    }
}

public enum WalletOrigin: Int {
    case privateKey
    case hd
    case hardware
    case watch
}

public struct Wallet: Equatable, CustomStringConvertible {
    public let type: WalletType
    public let origin: WalletOrigin

    public var address: Go23Wallet.Address {
        switch type {
        case .real(let account):
            return account
        case .watch(let address):
            return address
        case .hardware(let address):
            return address
        }
    }

    public var allowBackup: Bool {
        switch type {
        case .real:
            return true
        case .watch, .hardware:
            return false
        }
    }

    public var description: String {
        type.description
    }

    public init(address: Go23Wallet.Address, origin: WalletOrigin) {
        switch origin {
        case .privateKey, .hd:
            self.type = .real(address)
        case .hardware:
            self.type = .hardware(address)
        case .watch:
            self.type = .watch(address)
        }
        self.origin = origin
    }
}

extension Wallet: Hashable { }
