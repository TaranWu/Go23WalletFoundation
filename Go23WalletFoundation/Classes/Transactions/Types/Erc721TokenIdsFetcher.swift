// Copyright © 2021 Stormbird PTE. LTD.

import Foundation
import Combine
import Go23WalletAddress

public protocol Erc721TokenIdsFetcher: AnyObject {
    func tokenIdsForErc721Token(contract: Go23Wallet.Address, forServer: RPCServer, inAccount account: Go23Wallet.Address) -> AnyPublisher<[String], Never>
}
