//
// Created by James Sangalli on 8/11/18.
//
import Foundation
import Go23WalletENS
import Combine

public class EnsResolver {
    private let storage: EnsRecordsStorage
    private let server: RPCServer
    private lazy var ens = ENS(delegate: ensDelegate, chainId: server.chainID)
    private let ensDelegate: ENSDelegateImpl

    public init(storage: EnsRecordsStorage, blockchainProvider: BlockchainProvider) {
        self.server = blockchainProvider.server
        self.ensDelegate = ENSDelegateImpl(blockchainProvider: blockchainProvider)
        self.storage = storage
    }

    public func getENSAddressFromResolver(for name: String) -> AnyPublisher<Go23Wallet.Address, SmartContractError> {
        if let cachedResult = cachedAddressValue(for: name) {
            return .just(cachedResult)
        }

        return ens.getENSAddress(fromName: name)
            .handleEvents(receiveOutput: { [server, storage] address in
                let key = EnsLookupKey(nameOrAddress: name, server: server)
                storage.addOrUpdate(record: .init(key: key, value: .address(address)))
            }).eraseToAnyPublisher()
    }
}

extension EnsResolver: CachebleAddressResolutionServiceType {
    public func cachedAddressValue(for name: String) -> Go23Wallet.Address? {
        let key = EnsLookupKey(nameOrAddress: name, server: self.server)
        switch storage.record(for: key, expirationTime: Constants.Ens.recordExpiration)?.value {
        case .address(let address):
            return address
        case .none, .record, .ens:
            return nil
        }
    }
}
