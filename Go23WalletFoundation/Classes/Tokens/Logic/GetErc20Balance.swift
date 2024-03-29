// Copyright © 2019 Stormbird PTE. LTD.

import Foundation
import BigInt
import Combine
import Go23Web3Swift
import Go23WalletCore

final class GetErc20Balance {
    private var inFlightPublishers: [String: AnyPublisher<BigUInt, SessionTaskError>] = [:]
    private let queue = DispatchQueue(label: "org.Go23Wallet.swift.getErc20Balance")
    private let blockchainProvider: BlockchainProvider

    init(blockchainProvider: BlockchainProvider) {
        self.blockchainProvider = blockchainProvider
    }

    func getErc20Balance(for address: Go23Wallet.Address, contract: Go23Wallet.Address) -> AnyPublisher<BigUInt, SessionTaskError> {
        Just(contract)
            .setFailureType(to: SessionTaskError.self)
            .receive(on: queue)
            .flatMap { [weak self, queue, blockchainProvider] contract -> AnyPublisher<BigUInt, SessionTaskError> in
                let key = "\(address.eip55String)-\(contract.eip55String)"

                if let publisher = self?.inFlightPublishers[key] {
                    return publisher
                } else {
                    let publisher = blockchainProvider
                        .call(Erc20BalanceOfMethodCall(contract: contract, address: address))
                        .receive(on: queue)
                        .handleEvents(receiveCompletion: { _ in self?.inFlightPublishers[key] = .none })
                        .share()
                        .eraseToAnyPublisher()

                    self?.inFlightPublishers[key] = publisher

                    return publisher
                }
            }.eraseToAnyPublisher()
    }
}
