// Copyright © 2021 Stormbird PTE. LTD.

import Foundation
import PromiseKit

public protocol Erc721TokenIdsFetcher: AnyObject {
    func tokenIdsForErc721Token(contract: DerbyWallet.Address, forServer: RPCServer, inAccount account: DerbyWallet.Address) -> Promise<[String]>
}
