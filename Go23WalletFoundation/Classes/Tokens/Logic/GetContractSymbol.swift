// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import PromiseKit
import Go23Web3Swift
import Go23WalletCore
import Combine

final class GetContractSymbol {
    private var inFlightPromises: [String: AnyPublisher<String, SessionTaskError>] = [:]
    private let queue = DispatchQueue(label: "org.Go23Wallet.swift.getContractSymbol")

    private let blockchainProvider: BlockchainProvider

    init(blockchainProvider: BlockchainProvider) {
        self.blockchainProvider = blockchainProvider
    }

    func getSymbol(for contract: Go23Wallet.Address) -> AnyPublisher<String, SessionTaskError> {
        return Just(contract)
            .receive(on: queue)
            .setFailureType(to: SessionTaskError.self)
            .flatMap { [weak self, queue, blockchainProvider] contract -> AnyPublisher<String, SessionTaskError> in
                let key = contract.eip55String

                if let promise = self?.inFlightPromises[key] {
                    return promise
                } else {
                    let promise = blockchainProvider
                        .call(Erc20SymbolMethodCall(contract: contract))
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
