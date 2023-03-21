// Copyright © 2018 Stormbird PTE. LTD.

import Go23WalletAddress

///Use an enum as a namespace until Swift has proper namespaces
public typealias Go23Wallet = Go23WalletAddress.Go23Wallet

extension Go23Wallet.Address {
    public var isLegacy875Contract: Bool {
        let contractString = eip55String
        return Constants.legacy875Addresses.contains { $0.sameContract(as: contractString) }
    }

    public var isLegacy721Contract: Bool {
        return Constants.legacy721Addresses.contains(self)
    }

    //Useful for special case for FIFA tickets
    public var isFifaTicketContract: Bool {
        return self == Constants.ticketContractAddress || self == Constants.ticketContractAddressRopsten
    }

    public var isUEFATicketContract: Bool {
        return self == Constants.uefaMainnet.0
    }
}
