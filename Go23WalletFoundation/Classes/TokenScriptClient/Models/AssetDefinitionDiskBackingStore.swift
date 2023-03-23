// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import Go23WalletAddress

public class AssetDefinitionDiskBackingStore: AssetDefinitionBackingStore {
    public static let officialDirectoryName = "assetDefinitions"
    public static let fileExtension = "tsml"

    private let documentsDirectory = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    private let assetDefinitionsDirectoryName: String
    lazy var directory = documentsDirectory.appendingPathComponent(assetDefinitionsDirectoryName)
    private let isOfficial: Bool
    public weak var delegate: AssetDefinitionBackingStoreDelegate?
    private var directoryWatcher: DirectoryContentsWatcherProtocol?
    private var tokenScriptFileIndices = TokenScriptFileIndices()
    private var cachedVersionOfXDaiBridgeTokenScript: String?

    private var indicesFileUrl: URL {
        return directory.appendingPathComponent(TokenScript.indicesFileName)
    }

    public var badTokenScriptFileNames: [TokenScriptFileIndices.FileName] {
        if isOfficial {
            //We exclude .xml in the directory for files downloaded from the repo. Because this are based on pre 2019/04 schemas. We should just delete them
            return tokenScriptFileIndices.badTokenScriptFileNames.filter { !$0.hasSuffix(".xml") }
        } else {
            return tokenScriptFileIndices.badTokenScriptFileNames
        }
    }

    public var conflictingTokenScriptFileNames: (official: [TokenScriptFileIndices.FileName], overrides: [TokenScriptFileIndices.FileName], all: [TokenScriptFileIndices.FileName]) {
        if isOfficial {
            return (official: tokenScriptFileIndices.conflictingTokenScriptFileNames, overrides: [], all: tokenScriptFileIndices.conflictingTokenScriptFileNames)
        } else {
            return (official: [], overrides: tokenScriptFileIndices.conflictingTokenScriptFileNames, all: tokenScriptFileIndices.conflictingTokenScriptFileNames)
        }
    }

    public var contractsWithTokenScriptFileFromOfficialRepo: [Go23Wallet.Address] {
        guard let urls = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return .init() }
        return urls.compactMap { Go23Wallet.Address(string: $0.deletingPathExtension().lastPathComponent) }
    }

    public init(directoryName: String = officialDirectoryName) {
        self.assetDefinitionsDirectoryName = directoryName
        self.isOfficial = assetDefinitionsDirectoryName == AssetDefinitionDiskBackingStore.officialDirectoryName

        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        loadTokenScriptFileIndices()
    }

    deinit {
        try? directoryWatcher?.stop()
    }

    private func loadTokenScriptFileIndices() {
        let previousTokenScriptFileIndices = TokenScriptFileIndices.load(fromUrl: indicesFileUrl) ?? .init()
        tokenScriptFileIndices = .init()
        guard let urls = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return }

        for eachUrl in urls {
            guard eachUrl.pathExtension == AssetDefinitionDiskBackingStore.fileExtension || eachUrl.pathExtension == "xml" else { continue }
            guard let contents = try? String(contentsOf: eachUrl) else { continue }
            let fileName = eachUrl.lastPathComponent
            //TODO don't use regex. When we finally use XMLHandler to extract entities, we have to be careful not to create AssetDefinitionStore instances within XMLHandler otherwise infinite recursion by calling this func again
            if let contracts = XMLHandler.functional.getHoldingContracts(forTokenScript: contents) {
                let entities = XMLHandler.functional.getEntities(forTokenScript: contents)
                for (eachContract, _) in contracts {
                    tokenScriptFileIndices.contractsToFileNames[eachContract, default: []] += [fileName]
                }
                tokenScriptFileIndices.contractsToEntities[fileName] = entities
                tokenScriptFileIndices.trackHash(forFile: fileName, contents: contents)
            } else {
                var isOldTokenScriptVersion = false
                for (contract, fileNames) in previousTokenScriptFileIndices.contractsToOldTokenScriptFileNames where fileNames.contains(fileName) {
                    let newHash = tokenScriptFileIndices.hash(contents: contents)
                    if newHash == previousTokenScriptFileIndices.fileHashes[fileName] {
                        tokenScriptFileIndices.contractsToOldTokenScriptFileNames[contract, default: []] += [fileName]
                        tokenScriptFileIndices.trackHash(forFile: fileName, contents: contents)
                        isOldTokenScriptVersion = true
                    }
                }
                if !isOldTokenScriptVersion {
                    for (contract, fileNames) in previousTokenScriptFileIndices.contractsToFileNames where fileNames.contains(fileName) {
                        let newHash = tokenScriptFileIndices.hash(contents: contents)
                        if newHash == previousTokenScriptFileIndices.fileHashes[fileName] {
                            tokenScriptFileIndices.contractsToOldTokenScriptFileNames[contract, default: []] += [fileName]
                            tokenScriptFileIndices.trackHash(forFile: fileName, contents: contents)
                            isOldTokenScriptVersion = true
                        }
                    }
                }
                if !isOldTokenScriptVersion {
                    tokenScriptFileIndices.badTokenScriptFileNames += [fileName]
                    delegate?.badTokenScriptFilesChanged(in: self)
                }
            }
        }
        tokenScriptFileIndices.copySignatureVerificationTypes(previousTokenScriptFileIndices.signatureVerificationTypes)
        writeIndicesToDisk()
    }

    private func writeIndicesToDisk() {
        tokenScriptFileIndices.write(toUrl: indicesFileUrl)
    }

    private func localURLOfXML(for contract: Go23Wallet.Address) -> URL {
        assert(isOfficial)
        return directory.appendingPathComponent(filename(fromContract: contract))
    }

    ///Only return XML contents if there is exactly 1 file that matches the contract
    private func xml(forContract contract: Go23Wallet.Address) -> String? {
        guard let fileName = tokenScriptFileIndices.nonConflictingFileName(forContract: contract) else { return nil }
        let path = directory.appendingPathComponent(fileName)
        return try? String(contentsOf: path)
    }

    private func filename(fromContract contract: Go23Wallet.Address) -> String {
        return "\(contract.eip55String).\(AssetDefinitionDiskBackingStore.fileExtension)"
    }

    public subscript(contract: Go23Wallet.Address) -> String? {
        get {
            guard var xmlContents = xml(forContract: contract) else { return nil }
            guard let fileName = tokenScriptFileIndices.nonConflictingFileName(forContract: contract) else { return xmlContents }
            guard let entities = tokenScriptFileIndices.contractsToEntities[fileName] else { return xmlContents }
            for each in entities {
                //Guard against XML entity injection
                guard !each.fileName.contains("/") else { continue }
                let url = directory.appendingPathComponent(each.fileName)
                guard let contents = try? String(contentsOf: url) else { continue }
                xmlContents = (xmlContents as NSString).replacingOccurrences(of: "&\(each.name);", with: contents)
            }
            return xmlContents
        }
        set(xml) {
            guard let xml = xml else { return }
            let path = localURLOfXML(for: contract)
            try? xml.write(to: path, atomically: true, encoding: .utf8)
            handleTokenScriptFileChanged(withFilename: path.lastPathComponent, changeHandler: { _ in })
        }
    }

    public func isOfficial(contract: Go23Wallet.Address) -> Bool {
        return isOfficial
    }

    ///We don't bother to check if there's a conflict inside this function because if there's a conflict, the files should be ignored anyway
    public func isCanonicalized(contract: Go23Wallet.Address) -> Bool {
        if let filename = tokenScriptFileIndices.contractsToFileNames[contract]?.first {
            return filename.hasSuffix(".\(AssetDefinitionDiskBackingStore.fileExtension)")
        } else {
            //We return true because then it'll be treated as needing a higher security level rather than a non-canonicalized (debug version)
            return true
        }
    }

    public func hasConflictingFile(forContract contract: Go23Wallet.Address) -> Bool {
        return tokenScriptFileIndices.hasConflictingFile(forContract: contract)
    }

    public func hasOutdatedTokenScript(forContract contract: Go23Wallet.Address) -> Bool {
        return !tokenScriptFileIndices.contractsToOldTokenScriptFileNames[contract].isEmpty
    }

    public func getCacheTokenScriptSignatureVerificationType(forXmlString xmlString: String) -> TokenScriptSignatureVerificationType? {
        return tokenScriptFileIndices.signatureVerificationTypes[tokenScriptFileIndices.hash(contents: xmlString)]
    }

    public func writeCacheTokenScriptSignatureVerificationType(_ verificationType: TokenScriptSignatureVerificationType, forContract contract: Go23Wallet.Address, forXmlString xmlString: String) {
        tokenScriptFileIndices.signatureVerificationTypes[tokenScriptFileIndices.hash(contents: xmlString)] = verificationType
        tokenScriptFileIndices.write(toUrl: indicesFileUrl)
    }

    //When we remove a contract from our database, we must remove the TokenScript file (from the standard repo) that is named after it because this file wouldn't be pulled from the server anymore. If the TokenScript file applies to more than 1 contract, having the outdated file around will mean 2 copies of the same file — with 1 outdated, 1 up-to-date, causing TokenScript client to see a conflict
    public func deleteFileDownloadedFromOfficialRepoFor(contract: Go23Wallet.Address) {
        guard isOfficial else { return }
        let filename = self.filename(fromContract: contract)
        let url = directory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
        tokenScriptFileIndices.removeHash(forFile: filename)

        var contractsToFileNames = tokenScriptFileIndices.contractsToFileNames
        for (eachContract, eachFilenames) in tokenScriptFileIndices.contractsToFileNames where eachFilenames.contains(filename) {
            var updatedFilenames = eachFilenames
            updatedFilenames.removeAll { $0 == filename }
            contractsToFileNames[eachContract] = updatedFilenames
        }
        tokenScriptFileIndices.contractsToFileNames = contractsToFileNames
        tokenScriptFileIndices.contractsToEntities[filename] = nil
        tokenScriptFileIndices.removeBadTokenScriptFileName(filename)
        tokenScriptFileIndices.removeOldTokenScriptFileName(filename)
        writeIndicesToDisk()
    }

    //Must only return the last modified date for a file if it's for the current schema version otherwise, a file using the old schema might have a more recent timestamp (because it was recently downloaded) than a newer version on the server (which was not yet made available by the time the user downloaded the version with the old schema)
    public func lastModifiedDateOfCachedAssetDefinitionFile(forContract contract: Go23Wallet.Address) -> Date? {
        assert(isOfficial)
        let path = localURLOfXML(for: contract)
        guard let lastModified = try? path.resourceValues(forKeys: [.contentModificationDateKey]) else { return nil }
        guard XMLHandler.functional.isTokenScriptSupportedSchemaVersion(path) else { return nil }
        return lastModified.contentModificationDate
    }

    public func forEachContractWithXML(_ body: (Go23Wallet.Address) -> Void) {
        for (contract, _) in tokenScriptFileIndices.contractsToFileNames {
            body(contract)
        }
    }

    public func watchDirectoryContents(changeHandler: @escaping (AddressAndOptionalRPCServer) -> Void) {
        guard directoryWatcher == nil else { return }
        directoryWatcher = DirectoryContentsWatcher.Local(path: directory.path)
        try? directoryWatcher?.start { [weak self] results in
            guard let strongSelf = self else { return }
            switch results {
            case .noChanges:
                break
            case .updated(let filenames):
                for each in filenames {
                    strongSelf.handleTokenScriptFileChanged(withFilename: each, changeHandler: changeHandler)
                }
            }
        }
    }

    private func handleTokenScriptFileChanged(withFilename fileName: String, changeHandler: @escaping (AddressAndOptionalRPCServer) -> Void) {
        let url = directory.appendingPathComponent(fileName)
        var contractsAndServersAffected: [AddressAndOptionalRPCServer]
        if url.pathExtension == AssetDefinitionDiskBackingStore.fileExtension || url.pathExtension == "xml" {
            let contractsPreviouslyForThisXmlFile = tokenScriptFileIndices.contractsToFileNames.filter { _, fileNames in
                return fileNames.contains(fileName)
            }.map { $0.key }
            for eachContract in contractsPreviouslyForThisXmlFile {
                if var fileNames = tokenScriptFileIndices.contractsToFileNames[eachContract], fileNames.count > 1 {
                    fileNames.removeAll { $0 == fileName }
                    tokenScriptFileIndices.contractsToFileNames[eachContract] = fileNames
                } else {
                    tokenScriptFileIndices.contractsToFileNames.removeValue(forKey: eachContract)
                }
            }
            tokenScriptFileIndices.contractsToEntities.removeValue(forKey: fileName)
            tokenScriptFileIndices.removeHash(forFile: fileName)

            let contractsAndServers: [AddressAndOptionalRPCServer]
            if let contents = try? String(contentsOf: url) {
                if let holdingContracts: [AddressAndOptionalRPCServer] = XMLHandler.functional.getHoldingContracts(forTokenScript: contents)?.map({ AddressAndOptionalRPCServer(address: $0.0, server: RPCServer(chainID: $0.1)) }) {
                    contractsAndServers = holdingContracts
                    let entities = XMLHandler.functional.getEntities(forTokenScript: contents)
                    for eachContractAndServer in contractsAndServers {
                        tokenScriptFileIndices.contractsToFileNames[eachContractAndServer.address, default: []] += [fileName]
                    }
                    tokenScriptFileIndices.contractsToEntities[fileName] = entities
                    tokenScriptFileIndices.trackHash(forFile: fileName, contents: contents)
                    tokenScriptFileIndices.removeBadTokenScriptFileName(fileName)
                    tokenScriptFileIndices.removeOldTokenScriptFileName(fileName)
                } else {
                    contractsAndServers = []
                    tokenScriptFileIndices.badTokenScriptFileNames += [fileName]
                }
            } else {
                contractsAndServers = []
                tokenScriptFileIndices.removeHash(forFile: fileName)
                tokenScriptFileIndices.removeBadTokenScriptFileName(fileName)
                tokenScriptFileIndices.removeOldTokenScriptFileName(fileName)
            }

            contractsAndServersAffected = contractsAndServers + contractsPreviouslyForThisXmlFile.map { AddressAndOptionalRPCServer(address: $0, server: nil) }
        } else {
            contractsAndServersAffected = [AddressAndOptionalRPCServer]()
            for (xmlFileName, entities) in tokenScriptFileIndices.contractsToEntities where entities.contains(where: { $0.fileName == fileName }) {
                let contracts = tokenScriptFileIndices.contracts(inFileName: xmlFileName)
                contractsAndServersAffected.append(contentsOf: contracts.map { AddressAndOptionalRPCServer(address: $0, server: nil) })
            }
        }
        purgeCacheFor(contractsAndServers: contractsAndServersAffected, changeHandler: changeHandler)
        writeIndicesToDisk()
        delegate?.badTokenScriptFilesChanged(in: self)
    }

    private func purgeCacheFor(contractsAndServers: [AddressAndOptionalRPCServer], changeHandler: @escaping (AddressAndOptionalRPCServer) -> Void) {
        //Import to clear the signature cache (which includes conflicts) because a file which was in conflict with another earlier might no longer be
        //TODO clear the cache more intelligently rather than purge it entirely. It might be hard or impossible to know which other contracts are affected
        tokenScriptFileIndices.signatureVerificationTypes = .init()
        for each in Array(Set(contractsAndServers)) {
            delegate?.invalidateAssetDefinition(forContractAndServer: .init(address: each.address, server: nil))
            changeHandler(each)
        }
    }
}
