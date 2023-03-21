// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import Combine
import Go23Web3Swift
import Go23WalletCore

final class GetContractDecimals {
    private var inFlightPromises: [String: AnyPublisher<Int, SessionTaskError>] = [:]
    private let queue = DispatchQueue(label: "org.Go23Wallet.swift.getContractDecimals")

    private let blockchainProvider: BlockchainProvider

    init(blockchainProvider: BlockchainProvider) {
        self.blockchainProvider = blockchainProvider
    }

    func getDecimals(for contract: Go23Wallet.Address) -> AnyPublisher<Int, SessionTaskError> {
        return Just(contract)
            .receive(on: queue)
            .setFailureType(to: SessionTaskError.self)
            .flatMap { [weak self, queue, blockchainProvider] contract -> AnyPublisher<Int, SessionTaskError> in
                let key = contract.eip55String

                if let promise = self?.inFlightPromises[key] {
                    return promise
                } else {
                    let promise = blockchainProvider
                        .call(Erc20DecimalsMethodCall(contract: contract))
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
