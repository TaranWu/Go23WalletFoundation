//
//  ENSDelegateImpl.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation
import Go23WalletENS
import PromiseKit
import Combine

class ENSDelegateImpl: ENSDelegate {
    private let blockchainProvider: BlockchainProvider

    init(blockchainProvider: BlockchainProvider) {
        self.blockchainProvider = blockchainProvider
    }

    func getInterfaceSupported165(chainId: Int, hash: String, contract: Go23Wallet.Address) -> AnyPublisher<Bool, Go23WalletENS.SmartContractError> {
        return IsInterfaceSupported165(blockchainProvider: blockchainProvider)
            .getInterfaceSupported165(hash: hash, contract: contract)
            .mapError { e in SmartContractError.embeded(e) }
            .eraseToAnyPublisher()
    }

    func callSmartContract(withChainId chainId: ChainId, contract: Go23Wallet.Address, functionName: String, abiString: String, parameters: [AnyObject]) -> AnyPublisher<[String: Any], SmartContractError> {

        return blockchainProvider
            .call(AnyContractMethodCall(contract: contract, functionName: functionName, abiString: abiString, parameters: parameters))
            .mapError { e in SmartContractError.embeded(e) }
            .eraseToAnyPublisher()
    }

    func getSmartContractCallData(withChainId chainId: ChainId, contract: Go23Wallet.Address, functionName: String, abiString: String, parameters: [AnyObject]) -> Data? {
        do {
            return try AnyContractMethod(method: functionName, abi: abiString, params: parameters).encodedABI()
        } catch {
            return nil
        }
    }
}
