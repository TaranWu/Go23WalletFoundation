// Copyright © 2019 Stormbird PTE. LTD.

import Foundation
import Go23WalletAddress

//TODO this should probably be part of Go23Wallet.Address functionality instead, but narrowing the scope of the current change when we added this
public enum AddressOrEnsName: Equatable {
    case address(Go23Wallet.Address)
    case ensName(String)

    public init(address: Go23Wallet.Address) {
        self = .address(address)
    }

    public init?(ensName: String) {
        let optionalResult: AddressOrEnsName?
        if ensName.contains(".") {
            optionalResult = .ensName(ensName)
        } else {
            optionalResult = nil
        }
        if let result = optionalResult {
            self = result
        } else {
            return nil
        }
    }

    public init?(string: String) {
        let optionalResult: AddressOrEnsName?
        if let address = Go23Wallet.Address(string: string) {
            optionalResult = .address(address)
        } else {
            optionalResult = AddressOrEnsName(ensName: string)
        }
        if let result = optionalResult {
            self = result
        } else {
            return nil
        }
    }

    public var stringValue: String {
        switch self {
        case .address(let address):
            return address.eip55String
        case .ensName(let string):
            return string
        }
    }

    public var contract: Go23Wallet.Address? {
        switch self {
        case .address(let address):
            return address
        case .ensName:
            return nil
        }
    }

    //TODO reduce usage
    public func sameContract(as contract: String) -> Bool {
        switch self {
        case .address(let address):
            return address.eip55String.drop0x.lowercased() == contract.drop0x.lowercased()
        case .ensName:
            return false
        }
    }
}
