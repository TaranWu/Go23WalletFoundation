// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import Go23WalletAddress

public class AssetDefinitionDiskBackingStoreWithOverrides: AssetDefinitionBackingStore {
    private let officialStore = AssetDefinitionDiskBackingStore()
    //TODO make this be a `let`
    private var overridesStore: AssetDefinitionBackingStore
    public weak var delegate: AssetDefinitionBackingStoreDelegate?
    public static let overridesDirectoryName = "assetDefinitionsOverrides"

    public var badTokenScriptFileNames: [TokenScriptFileIndices.FileName] {
        return officialStore.badTokenScriptFileNames + overridesStore.badTokenScriptFileNames
    }

    public var conflictingTokenScriptFileNames: (official: [TokenScriptFileIndices.FileName], overrides: [TokenScriptFileIndices.FileName], all: [TokenScriptFileIndices.FileName]) {
        let official = officialStore.conflictingTokenScriptFileNames.all
        let overrides = overridesStore.conflictingTokenScriptFileNames.all
        return (official: official, overrides: overrides, all: official + overrides)
    }

    public var contractsWithTokenScriptFileFromOfficialRepo: [Go23Wallet.Address] {
        return officialStore.contractsWithTokenScriptFileFromOfficialRepo
    }

    public init(overridesStore: AssetDefinitionBackingStore? = nil) {
        if let overridesStore = overridesStore {
            self.overridesStore = overridesStore
        } else {
            let store = AssetDefinitionDiskBackingStore(directoryName: AssetDefinitionDiskBackingStoreWithOverrides.overridesDirectoryName)
            self.overridesStore = store
            store.watchDirectoryContents { [weak self] contractAndServer in
                self?.delegate?.invalidateAssetDefinition(forContractAndServer: contractAndServer)
            }
        }

        self.officialStore.delegate = self
        self.overridesStore.delegate = self
    }

    public subscript(contract: Go23Wallet.Address) -> String? {
        get {
            return overridesStore[contract] ?? officialStore[contract]
        }
        set(xml) {
            officialStore[contract] = xml
        }
    }

    public func isOfficial(contract: Go23Wallet.Address) -> Bool {
        if overridesStore[contract] != nil {
            return false
        }
        return officialStore.isOfficial(contract: contract)
    }

    public func isCanonicalized(contract: Go23Wallet.Address) -> Bool {
        if overridesStore[contract] != nil {
            return overridesStore.isCanonicalized(contract: contract)
        } else {
            return officialStore.isCanonicalized(contract: contract)
        }
    }

    public func hasConflictingFile(forContract contract: Go23Wallet.Address) -> Bool {
        let official = officialStore.hasConflictingFile(forContract: contract)
        let overrides = overridesStore.hasConflictingFile(forContract: contract)
        if overrides {
            return true
        } else {
            return official
        }
    }

    public func hasOutdatedTokenScript(forContract contract: Go23Wallet.Address) -> Bool {
        if overridesStore[contract] != nil {
            return overridesStore.hasOutdatedTokenScript(forContract: contract)
        } else {
            return officialStore.hasOutdatedTokenScript(forContract: contract)
        }
    }

    public func lastModifiedDateOfCachedAssetDefinitionFile(forContract contract: Go23Wallet.Address) -> Date? {
        //Even with an override, we just want to fetch the latest official version. Doesn't imply we'll use the official version
        return officialStore.lastModifiedDateOfCachedAssetDefinitionFile(forContract: contract)
    }

    public func forEachContractWithXML(_ body: (Go23Wallet.Address) -> Void) {
        var overriddenContracts = [Go23Wallet.Address]()
        overridesStore.forEachContractWithXML { contract in
            overriddenContracts.append(contract)
            body(contract)
        }
        officialStore.forEachContractWithXML { contract in
            if !overriddenContracts.contains(contract) {
                body(contract)
            }
        }
    }

    public func getCacheTokenScriptSignatureVerificationType(forXmlString xmlString: String) -> TokenScriptSignatureVerificationType? {
        return overridesStore.getCacheTokenScriptSignatureVerificationType(forXmlString: xmlString) ?? officialStore.getCacheTokenScriptSignatureVerificationType(forXmlString: xmlString)
    }

    ///The implementation assumes that we never verifies the signature files in the official store when there's an override available
    public func writeCacheTokenScriptSignatureVerificationType(_ verificationType: TokenScriptSignatureVerificationType, forContract contract: Go23Wallet.Address, forXmlString xmlString: String) {
        if let xml = overridesStore[contract], xml == xmlString {
            overridesStore.writeCacheTokenScriptSignatureVerificationType(verificationType, forContract: contract, forXmlString: xmlString)
            return
        }
        if let xml = officialStore[contract], xml == xmlString {
            officialStore.writeCacheTokenScriptSignatureVerificationType(verificationType, forContract: contract, forXmlString: xmlString)
            return
        }
    }

    public func deleteFileDownloadedFromOfficialRepoFor(contract: Go23Wallet.Address) {
        officialStore.deleteFileDownloadedFromOfficialRepoFor(contract: contract)
    }
}

extension AssetDefinitionDiskBackingStoreWithOverrides: AssetDefinitionBackingStoreDelegate {
    public func invalidateAssetDefinition(forContractAndServer contractAndServer: AddressAndOptionalRPCServer) {
        delegate?.invalidateAssetDefinition(forContractAndServer: contractAndServer)
    }

    public func badTokenScriptFilesChanged(in: AssetDefinitionBackingStore) {
        delegate?.badTokenScriptFilesChanged(in: self)
    }
}
