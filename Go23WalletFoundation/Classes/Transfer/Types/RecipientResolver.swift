//
//  RecipientResolver.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation
import Combine
import CombineExt

public class RecipientResolver {
    public enum Row: Int, CaseIterable {
        case address
        case ens
    }

    public let address: Go23Wallet.Address?
    public var ensName: String?

    public var hasResolvedEnsName: Bool {
        if let value = ensName {
            return !value.trimmed.isEmpty
        }
        return false
    }
    private let domainResolutionService: DomainResolutionServiceType

    public init(address: Go23Wallet.Address?, domainResolutionService: DomainResolutionServiceType) {
        self.address = address
        self.domainResolutionService = domainResolutionService
    } 

    public func resolveRecipient() -> AnyPublisher<Void, Never> {
        guard let address = address else {
            return .just(())
        }

        return domainResolutionService.resolveEns(address: address)
            .map { ens -> EnsName? in return ens }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { [weak self] in self?.ensName = $0 })
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public var value: String? {
        return address?.eip55String
    }
}
