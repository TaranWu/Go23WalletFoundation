// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import RealmSwift

class DeletedContract: Object {
    @objc dynamic var primaryKey: String = ""
    @objc dynamic var chainId: Int = 0
    @objc dynamic var contract: String = ""

    convenience init(contractAddress: Go23Wallet.Address, server: RPCServer) {
        self.init()
        self.contract = contractAddress.eip55String
        self.chainId = server.chainID
        self.primaryKey = "\(self.contract)-\(server.chainID)"
    }

    override static func primaryKey() -> String? {
        return "primaryKey"
    }

    var server: RPCServer {
        return RPCServer(chainID: chainId)
    }
    
    var contractAddress: Go23Wallet.Address {
        return Go23Wallet.Address(uncheckedAgainstNullAddress: contract)!
    }
}
