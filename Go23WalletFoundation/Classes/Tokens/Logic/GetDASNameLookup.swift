//
//  GetDASNameLookup.swift
//  DerbyWallet
//
//  Created by Vladyslav Shepitko on 08.10.2021.
//

import JSONRPCKit
import APIKit
import PromiseKit

public final class GetDASNameLookup {
    public enum DASNameLookupError: Error {
        case ethRecordNotFound
        case invalidInput
    }

    private static let ethAddressKey = "address.eth"

    private let server: RPCServer
    private let analytics: AnalyticsLogger

    public init(server: RPCServer, analytics: AnalyticsLogger) {
        self.server = server
        self.analytics = analytics
    }

    public static func isValid(value: String) -> Bool {
        return value.trimmed.hasSuffix(".bit")
    }

    public func resolve(rpcURL: URL, rpcHeaders: [String: String], value: String) -> Promise<DerbyWallet.Address> {
        guard GetDASNameLookup.isValid(value: value) else {
            return .init(error: DASNameLookupError.invalidInput)
        }

        let request = EtherServiceRequest(rpcURL: rpcURL, rpcHeaders: rpcHeaders, batch: BatchFactory().create(DASLookupRequest(value: value)))
        return APIKitSession.send(request, server: server, analytics: analytics).map { response -> DerbyWallet.Address in
            if let record = response.records.first(where: { $0.key == GetDASNameLookup.ethAddressKey }), let address = DerbyWallet.Address(string: record.value) {
                return address
            } else if response.records.isEmpty, let ownerAddress = response.ownerAddress {
                return ownerAddress
            } else {
            }
            throw DASNameLookupError.ethRecordNotFound
        }
    }
}
