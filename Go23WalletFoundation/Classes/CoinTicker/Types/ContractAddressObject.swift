//
//  ContractAddressObject.swift
//  Go23WalletFoundation
//
//  Created by Vladyslav Shepitko on 05.09.2022.
//

import Foundation
import RealmSwift
import Go23WalletAddress

class ContractAddressObject: Object {
    static func generatePrimaryKey(fromContract contract: Go23Wallet.Address, server: RPCServer) -> String {
        return "\(contract.eip55String)-\(server.chainID)"
    }

    @objc dynamic var primaryKey: String = ""
    @objc dynamic var chainId: Int = 0
    @objc dynamic var contract: String = ""

    var server: RPCServer {
        return .init(chainID: chainId)
    }

    var contractAddress: Go23Wallet.Address {
        return Go23Wallet.Address(uncheckedAgainstNullAddress: contract)!
    }

    convenience init(contract: Go23Wallet.Address = Constants.nullAddress, server: RPCServer) {
        self.init()
        self.primaryKey = TokenObject.generatePrimaryKey(fromContract: contract, server: server)
        self.contract = contract.eip55String
        self.chainId = server.chainID
    }

    override static func primaryKey() -> String? {
        return "primaryKey"
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ContractAddressObject else { return false }
        //NOTE: to improve perfomance seems like we can use check for primary key instead of checking contracts
        return object.contractAddress == contractAddress && object.server == server
    }
}
