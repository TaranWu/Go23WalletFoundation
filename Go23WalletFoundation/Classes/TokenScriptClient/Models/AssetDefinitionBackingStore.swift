// Copyright © 2018 Stormbird PTE. LTD.

import Foundation

public protocol AssetDefinitionBackingStore {
    var delegate: AssetDefinitionBackingStoreDelegate? { get set }
    var badTokenScriptFileNames: [TokenScriptFileIndices.FileName] { get }
    var conflictingTokenScriptFileNames: (official: [TokenScriptFileIndices.FileName], overrides: [TokenScriptFileIndices.FileName], all: [TokenScriptFileIndices.FileName]) { get }
    var contractsWithTokenScriptFileFromOfficialRepo: [DerbyWallet.Address] { get }

    subscript(contract: DerbyWallet.Address) -> String? { get set }
    func lastModifiedDateOfCachedAssetDefinitionFile(forContract contract: DerbyWallet.Address) -> Date?
    func forEachContractWithXML(_ body: (DerbyWallet.Address) -> Void)
    func isOfficial(contract: DerbyWallet.Address) -> Bool
    func isCanonicalized(contract: DerbyWallet.Address) -> Bool
    func hasConflictingFile(forContract contract: DerbyWallet.Address) -> Bool
    func hasOutdatedTokenScript(forContract contract: DerbyWallet.Address) -> Bool
    func getCacheTokenScriptSignatureVerificationType(forXmlString xmlString: String) -> TokenScriptSignatureVerificationType?
    func writeCacheTokenScriptSignatureVerificationType(_ verificationType: TokenScriptSignatureVerificationType, forContract contract: DerbyWallet.Address, forXmlString xmlString: String)
    func deleteFileDownloadedFromOfficialRepoFor(contract: DerbyWallet.Address)
}

public protocol AssetDefinitionBackingStoreDelegate: AnyObject {
    func invalidateAssetDefinition(forContractAndServer contractAndServer: AddressAndOptionalRPCServer)
    func badTokenScriptFilesChanged(in: AssetDefinitionBackingStore)
}
