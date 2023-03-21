//
//  GetErc20Allowance.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import BigInt
import Combine
import Go23Web3Swift

class GetErc20Allowance {
    private let blockchainProvider: BlockchainProvider

    public init(blockchainProvider: BlockchainProvider) {
        self.blockchainProvider = blockchainProvider
    }

    public func hasEnoughAllowance(tokenAddress: Go23Wallet.Address, owner: Go23Wallet.Address, spender: Go23Wallet.Address, amount: BigUInt) -> AnyPublisher<(hasEnough: Bool, shortOf: BigUInt), SessionTaskError> {
        if tokenAddress == Constants.nativeCryptoAddressInDatabase {
            return .just((true, 0))
        }

        return blockchainProvider
            .call(Erc20AllowanceMethodCall(contract: tokenAddress, owner: owner, spender: spender))
            .map { allowance -> (Bool, BigUInt) in
                if allowance >= amount {
                    return (true, 0)
                } else {
                    return (false, amount - allowance)
                }
            }.receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
