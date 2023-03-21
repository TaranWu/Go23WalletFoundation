//
//  KnownTickerIdObject.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import RealmSwift

class KnownTickerIdObject: Object {
    @objc dynamic var primaryKey: String = ""
    @objc dynamic var chainId: Int = 0
    @objc dynamic var contract: String = ""
    @objc dynamic var tickerIdString: String = ""

    var server: RPCServer {
        return .init(chainID: chainId)
    }

    var contractAddress: Go23Wallet.Address {
        return Go23Wallet.Address(uncheckedAgainstNullAddress: contract)!
    }

    convenience init(key: AssignedCoinTickerId) {
        self.init()
        self.primaryKey = ContractAddressObject.generatePrimaryKey(fromContract: key.primaryToken.address, server: key.primaryToken.server)
        self.chainId = key.primaryToken.server.chainID
        self.contract = key.primaryToken.address.eip55String
        self.tickerIdString = key.tickerId
    }

    convenience init(server: RPCServer, contractAddress: Go23Wallet.Address, tickerIdString: TickerIdString) {
        self.init()
        self.primaryKey = ContractAddressObject.generatePrimaryKey(fromContract: contractAddress, server: server)
        self.chainId = server.chainID
        self.contract = contractAddress.eip55String
        self.tickerIdString = tickerIdString
    }

    override static func primaryKey() -> String? {
        return "primaryKey"
    }

    override static func ignoredProperties() -> [String] {
        return ["server", "contractAddress"]
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? KnownTickerIdObject else { return false }
        return object.primaryKey == primaryKey
    }
}
