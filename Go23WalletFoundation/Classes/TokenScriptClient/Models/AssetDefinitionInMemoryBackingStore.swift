// Copyright © 2018 Stormbird PTE. LTD.

import Foundation

public class AssetDefinitionInMemoryBackingStore: AssetDefinitionBackingStore {
    private var xmls = [DerbyWallet.Address: String]()

    public weak var delegate: AssetDefinitionBackingStoreDelegate?
    public var badTokenScriptFileNames: [TokenScriptFileIndices.FileName] {
        return .init()
    }
    public var conflictingTokenScriptFileNames: (official: [TokenScriptFileIndices.FileName], overrides: [TokenScriptFileIndices.FileName], all: [TokenScriptFileIndices.FileName]) {
        return (official: [], overrides: [], all: [])
    }

    public var contractsWithTokenScriptFileFromOfficialRepo: [DerbyWallet.Address] {
        return .init()
    }
    public init() { }
    public subscript(contract: DerbyWallet.Address) -> String? {
        get {
            return xmls[contract]
        }
        set(xml) {
            //TODO validate XML signature first
            xmls[contract] = xml
        }
    }

    public func lastModifiedDateOfCachedAssetDefinitionFile(forContract contract: DerbyWallet.Address) -> Date? {
        return nil
    }

    public func forEachContractWithXML(_ body: (DerbyWallet.Address) -> Void) {
        xmls.forEach { contract, _ in
            body(contract)
        }
    }

    public func isOfficial(contract: DerbyWallet.Address) -> Bool {
        return false
    }

    public func isCanonicalized(contract: DerbyWallet.Address) -> Bool {
        return true
    }

    public func hasConflictingFile(forContract contract: DerbyWallet.Address) -> Bool {
        return false
    }

    public func hasOutdatedTokenScript(forContract contract: DerbyWallet.Address) -> Bool {
        return false
    }

    public func getCacheTokenScriptSignatureVerificationType(forXmlString xmlString: String) -> TokenScriptSignatureVerificationType? {
        return nil
    }

    public func writeCacheTokenScriptSignatureVerificationType(_ verificationType: TokenScriptSignatureVerificationType, forContract contract: DerbyWallet.Address, forXmlString xmlString: String) {
        //do nothing
    }

    public func deleteFileDownloadedFromOfficialRepoFor(contract: DerbyWallet.Address) {
        xmls[contract] = nil
    }
}
