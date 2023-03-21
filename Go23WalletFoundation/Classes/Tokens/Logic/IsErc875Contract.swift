// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import Combine

public class IsErc875Contract {
    private let blockchainProvider: BlockchainProvider

    public init(blockchainProvider: BlockchainProvider) {
        self.blockchainProvider = blockchainProvider
    }

    public func getIsERC875Contract(for contract: Go23Wallet.Address) -> AnyPublisher<Bool, SessionTaskError> {
        blockchainProvider
            .call(Erc875IsStormBirdContractMethodCall(contract: contract))
    }
}
