//
//  ContractToImportStorage.swift
//  Go23WalletFoundation
//
//  Created by Vladyslav Shepitko on 10.11.2022.
//

import Foundation
import Go23WalletAddress

//TODO: Update with priority field for being able to order operation
struct ContractToImport: Codable {
    let name: String
    let contract: Go23Wallet.Address
    let server: RPCServer
    let onlyIfThereIsABalance: Bool
}

protocol ContractToImportStorage {
    var contractsToDetect: [ContractToImport] { get }
}

struct ContractToImportFileStorage: ContractToImportStorage {
    var contractsToDetect: [ContractToImport]

    init(server: RPCServer, fileName: String = "tokensToImport") {
        contractsToDetect = ContractToImportFileStorage.functional.loadContractsToDetect(fileName: fileName, server: server)
    }
}

extension ContractToImportFileStorage {
    enum functional {}
}

extension ContractToImportFileStorage.functional {
    static func loadContractsToDetect(fileName: String, server: RPCServer) -> [ContractToImport] {
        guard let bundlePath = Bundle.main.path(forResource: fileName, ofType: "json") else {
            return []
        }

        do {
            guard let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) else {
                return []
            }
            let decodedTokenEntries = try JSONDecoder().decode([ContractToImport].self, from: jsonData)
            var data: [ContractToImport] = []

            for each in decodedTokenEntries {
                guard each.server == server else { continue }
                data += [each]
            }
            return data
        } catch {
            return []
        }
    }
}
