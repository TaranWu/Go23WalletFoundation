//
//  CachedERC1155ContractDictionary.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public class CachedERC1155ContractDictionary {
    private let fileUrl: URL
    private var baseDictionary: [Go23Wallet.Address: Bool] = [Go23Wallet.Address: Bool]()
    private let encoder: JSONEncoder

    public init?(fileName: String) {
        do {
            var url: URL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            url.appendPathComponent(fileName)
            self.fileUrl = url
            self.encoder = JSONEncoder()
            if FileManager.default.fileExists(atPath: url.path) {
                readFromFileUrl()
            }
        } catch {
            return nil
        }
    }

    public func isERC1155Contract(for address: Go23Wallet.Address) -> Bool? {
        return baseDictionary[address]
    }

    public func setContract(for address: Go23Wallet.Address, _ result: Bool) {
        baseDictionary[address] = result
        writeToFileUrl()
    }

    public func remove() {
        do {
            try FileManager.default.removeItem(at: fileUrl)
        } catch {
            // Do nothing
        }
    }

    private func writeToFileUrl() {
        do {
            let data = try encoder.encode(baseDictionary)
            if let jsonString = String(data: data, encoding: .utf8) {
                try jsonString.write(to: fileUrl, atomically: true, encoding: .utf8)
            }
        } catch {
        }
    }

    private func readFromFileUrl() {
        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: fileUrl)
            let jsonData = try decoder.decode([Go23Wallet.Address: Bool].self, from: data)
            baseDictionary = jsonData
        } catch {
            baseDictionary = [Go23Wallet.Address: Bool]()
        }
    }

}
