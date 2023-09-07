// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import Go23WalletAddress

public protocol AssetDefinitionBackingStore: AnyObject {
    var delegate: AssetDefinitionBackingStoreDelegate? { get set }
    var badTokenScriptFileNames: [TokenScriptFileIndices.FileName] { get }
    var conflictingTokenScriptFileNames: (official: [TokenScriptFileIndices.FileName], overrides: [TokenScriptFileIndices.FileName], all: [TokenScriptFileIndices.FileName]) { get }
    var contractsWithTokenScriptFileFromOfficialRepo: [Go23Wallet.Address] { get }

    subscript(contract: Go23Wallet.Address) -> String? { get set }
    func lastModifiedDateOfCachedAssetDefinitionFile(forContract contract: Go23Wallet.Address) -> Date?
    func forEachContractWithXML(_ body: (Go23Wallet.Address) -> Void)
    func isOfficial(contract: Go23Wallet.Address) -> Bool
    func isCanonicalized(contract: Go23Wallet.Address) -> Bool
    func hasConflictingFile(forContract contract: Go23Wallet.Address) -> Bool
    func hasOutdatedTokenScript(forContract contract: Go23Wallet.Address) -> Bool
    func getCacheTokenScriptSignatureVerificationType(forXmlString xmlString: String) -> TokenScriptSignatureVerificationType?
    func writeCacheTokenScriptSignatureVerificationType(_ verificationType: TokenScriptSignatureVerificationType, forContract contract: Go23Wallet.Address, forXmlString xmlString: String)
    func deleteFileDownloadedFromOfficialRepoFor(contract: Go23Wallet.Address)
}

public protocol AssetDefinitionBackingStoreDelegate: AnyObject {
    func invalidateAssetDefinition(forContractAndServer contractAndServer: AddressAndOptionalRPCServer)
    func badTokenScriptFilesChanged(in: AssetDefinitionBackingStore)
}
