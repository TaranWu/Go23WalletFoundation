// Copyright © 2019 Stormbird PTE. LTD.

import Foundation
import Go23WalletENS
import Combine
import Go23WalletAddress

class EnsReverseResolver {
    private let storage: EnsRecordsStorage
    private let server: RPCServer
    private lazy var ens = ENS(delegate: ensDelegate, chainId: server.chainID)
    private let ensDelegate: ENSDelegateImpl

    init(storage: EnsRecordsStorage, blockchainProvider: BlockchainProvider) {
        self.server = blockchainProvider.server
        self.storage = storage
        self.ensDelegate = ENSDelegateImpl(blockchainProvider: blockchainProvider)
    }

    //TODO make calls from multiple callers at the same time for the same address more efficient
    func getENSNameFromResolver(for address: Go23Wallet.Address) -> AnyPublisher<String, SmartContractError> {
        if let cachedResult = cachedEnsValue(for: address) {
            return .just(cachedResult)
        }

        return ens.getName(fromAddress: address)
            .handleEvents(receiveOutput: { [server, storage] name in
                let key = EnsLookupKey(nameOrAddress: address.eip55String, server: server)
                storage.addOrUpdate(record: .init(key: key, value: .ens(name)))
            }).eraseToAnyPublisher()
    }
}

extension EnsReverseResolver: CachedEnsResolutionServiceType {
    func cachedEnsValue(for address: Go23Wallet.Address) -> String? {
        let key = EnsLookupKey(nameOrAddress: address.eip55String, server: server)
        switch storage.record(for: key, expirationTime: Constants.Ens.recordExpiration)?.value {
        case .ens(let ens):
            return ens
        case .none, .record, .address:
            return nil
        }
    }
}
