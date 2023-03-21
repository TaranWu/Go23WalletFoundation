// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import PromiseKit
import Go23Web3Swift
import Go23WalletCore
import Combine

final class GetContractName {
    private let blockchainProvider: BlockchainProvider
    private var inFlightPromises: [String: AnyPublisher<String, SessionTaskError>] = [:]
    private let queue = DispatchQueue(label: "org.Go23Wallet.swift.getContractName")

    init(blockchainProvider: BlockchainProvider) {
        self.blockchainProvider = blockchainProvider
    }

    func getName(for contract: Go23Wallet.Address) -> AnyPublisher<String, SessionTaskError> {
        return Just(contract)
            .receive(on: queue)
            .setFailureType(to: SessionTaskError.self)
            .flatMap { [weak self, queue, blockchainProvider] contract -> AnyPublisher<String, SessionTaskError> in
                let key = contract.eip55String

                if let promise = self?.inFlightPromises[key] {
                    return promise
                } else {
                    let promise = blockchainProvider
                        .call(Erc20NameMethodCall(contract: contract))
                        .receive(on: queue)
                        .handleEvents(receiveCompletion: { _ in self?.inFlightPromises[key] = .none })
                        .share()
                        .eraseToAnyPublisher()

                    self?.inFlightPromises[key] = promise

                    return promise
                }
            }.eraseToAnyPublisher()
    }
}
