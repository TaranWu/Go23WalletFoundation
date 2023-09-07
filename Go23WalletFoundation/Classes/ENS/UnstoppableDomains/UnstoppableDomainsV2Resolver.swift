//
//  UnstoppableDomainsV2Resolver.swift
//  Go23Wallet
//
//  Created by Vladyslav Shepitko on 27.01.2022.
//

import Foundation
import Combine
import SwiftyJSON
import Go23WalletENS
import Go23WalletCore
import Go23WalletAddress

struct UnstoppableDomainsV2ApiError: Error {
    var localizedDescription: String
}

final class UnstoppableDomainsV2Resolver {
    private let server: RPCServer
    private let storage: EnsRecordsStorage
    private let networkProvider: UnstoppableDomainsV2NetworkProvider

    init(server: RPCServer, storage: EnsRecordsStorage, networkService: NetworkService) {
        self.server = server
        self.storage = storage
        self.networkProvider = .init(networkService: networkService)
    }

    func resolveAddress(forName name: String) -> AnyPublisher<Go23Wallet.Address, PromiseError> {
        if let value = Go23Wallet.Address(string: name) {
            return .just(value)
        }

        if let value = self.cachedAddressValue(for: name) {
            return .just(value)
        }

        return Just(name)
            .setFailureType(to: PromiseError.self)
            .flatMap { [networkProvider] name -> AnyPublisher<Go23Wallet.Address, PromiseError> in
                return networkProvider.resolveAddress(forName: name)
                    .handleEvents(receiveOutput: { address in
                        let key = EnsLookupKey(nameOrAddress: name, server: self.server)
                        self.storage.addOrUpdate(record: .init(key: key, value: .address(address)))
                    }).share()
                    .eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }

    func resolveDomain(address: Go23Wallet.Address) -> AnyPublisher<String, PromiseError> {
        if let value = self.cachedEnsValue(for: address) {
            return .just(value)
        }

        return Just(address)
            .setFailureType(to: PromiseError.self)
            .flatMap { [networkProvider] address -> AnyPublisher<String, PromiseError> in
                return networkProvider.resolveDomain(address: address)
                    .handleEvents(receiveOutput: { domain in
                        let key = EnsLookupKey(nameOrAddress: address.eip55String, server: self.server)
                        self.storage.addOrUpdate(record: .init(key: key, value: .ens(domain)))
                    }).share()
                    .eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
}

extension UnstoppableDomainsV2Resolver: CachebleAddressResolutionServiceType {

    func cachedAddressValue(for name: String) -> Go23Wallet.Address? {
        let key = EnsLookupKey(nameOrAddress: name, server: server)
        switch storage.record(for: key, expirationTime: Constants.Ens.recordExpiration)?.value {
        case .address(let address):
            return address
        case .record, .ens, .none:
            return nil
        }
    }
}

extension UnstoppableDomainsV2Resolver: CachedEnsResolutionServiceType {

    func cachedEnsValue(for address: Go23Wallet.Address) -> String? {
        let key = EnsLookupKey(nameOrAddress: address.eip55String, server: server)
        switch storage.record(for: key, expirationTime: Constants.Ens.recordExpiration)?.value {
        case .ens(let ens):
            return ens
        case .record, .address, .none:
            return nil
        }
    }
}

extension UnstoppableDomainsV2Resolver {

    enum DecodingError: Error {
        case domainNotFound
        case ownerNotFound
        case idNotFound
        case errorMessageNotFound
        case errorCodeNotFound
    }

    struct AddressResolution {
        struct Meta {
            let networkId: Int?
            let domain: String
            let owner: Go23Wallet.Address?
            let blockchain: String?
            let registry: String?

            init(json: JSON) throws {
                guard let domain = json["domain"].string else {
                    throw DecodingError.domainNotFound
                }
                self.domain = domain
                self.owner = json["owner"].string.flatMap { value in
                    Go23Wallet.Address(uncheckedAgainstNullAddress: value)
                }
                networkId = json["networkId"].int
                blockchain = json["blockchain"].string
                registry = json["registry"].string
            }
        }

        struct Response {
            let meta: Meta

            init(json: JSON) throws {
                meta = try Meta(json: json["meta"])
            }
        }
    }

    struct DomainResolution {
        struct Response {
            struct Pagination {
                let perPage: Int
                let nextStartingAfter: String?
                let sortBy: String
                let sortDirection: String
                let hasMore: Bool

                init(json: JSON) {
                    perPage = json["perPage"].intValue
                    nextStartingAfter = json["nextStartingAfter"].string
                    sortBy = json["sortBy"].stringValue
                    sortDirection = json["sortDirection"].stringValue
                    hasMore = json["hasMore"].boolValue
                }
            }

            struct ResponseData {
                struct Attributes {
                    let meta: AddressResolution.Meta

                    init(json: JSON) throws {
                        meta = try AddressResolution.Meta(json: json["meta"])
                    }
                }

                struct Records {
                    let values: [String: String]

                    init(json: JSON) throws {
                        var values: [String: String] = [:]
                        for key in Constants.unstoppableDomainsRecordKeys {
                            guard let value = json[key].string else { continue }
                            values[key] = value
                        }

                        self.values = values
                    }
                }

                let id: String
                let attributes: Attributes
                let records: Records

                init(json: JSON) throws {
                    guard let id = json["id"].string else {
                        throw DecodingError.idNotFound
                    }
                    self.id = id
                    attributes = try Attributes(json: json["attributes"])
                    records = try Records(json: json["records"])
                }
            }

            let data: [ResponseData]
            let meta: Pagination

            init(json: JSON) throws {
                data = json["data"].arrayValue.compactMap { json in
                    try? ResponseData(json: json)
                }
                meta = Pagination(json: json["meta"])
            }
        }
    }
}
