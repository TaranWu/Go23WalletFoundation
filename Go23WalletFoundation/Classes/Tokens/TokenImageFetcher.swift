// Copyright © 2020 Stormbird PTE. LTD.

import UIKit
import PromiseKit
import Go23WalletCore
import Go23WalletOpenSea

public typealias GoogleContentSize = Go23WalletCore.GoogleContentSize
public typealias WebImageURL = Go23WalletCore.WebImageURL
public typealias TokenImage = (image: ImageOrWebImageUrl, symbol: String, isFinal: Bool, overlayServerIcon: UIImage?)
public typealias Image = UIImage

private func programmaticallyGeneratedIconImage(for contractAddress: DerbyWallet.Address, server: RPCServer, colors: [UIColor], blockChainNameColor: UIColor) -> UIImage {
    let backgroundColor = symbolBackgroundColor(for: contractAddress, server: server, colors: colors, blockChainNameColor: blockChainNameColor)
    return UIImage.tokenSymbolBackgroundImage(backgroundColor: backgroundColor)
}

private func symbolBackgroundColor(for contractAddress: DerbyWallet.Address, server: RPCServer, colors: [UIColor], blockChainNameColor: UIColor) -> UIColor {
    if contractAddress.sameContract(as: Constants.nativeCryptoAddressInDatabase) {
        return blockChainNameColor
    } else {
        let index: Int
        //We just need a random number from the contract. The LSBs are more random than the MSBs
        if let i = Int(contractAddress.eip55String.substring(from: 37), radix: 16) {
            index = i % colors.count
        } else {
            index = 0
        }
        return colors[index]
    }
}

public class RPCServerImageFetcher {
    public static var instance = RPCServerImageFetcher()

    private static var subscribables: AtomicDictionary<Int, Subscribable<Image>> = .init()

    public func image(server: RPCServer, iconImage: UIImage) -> Subscribable<Image> {
        if let sub = Self.subscribables[server.chainID] {
            return sub
        } else {
            let sub = Subscribable<Image>(nil)
            Self.subscribables[server.chainID] = sub

            sub.send(iconImage)

            return sub
        }
    }
}

public protocol HasTokenImage {
    var name: String { get }
    var symbol: String { get }
    var contractAddress: DerbyWallet.Address { get }
    var type: TokenType { get }
    var server: RPCServer { get }
    var firstNftAsset: NonFungibleFromJson? { get }
}

extension Token: HasTokenImage {
    public var firstNftAsset: NonFungibleFromJson? {
        balance.compactMap { $0.nonFungibleBalance }.first
    }
}

extension TokenViewModel: HasTokenImage {
    public var firstNftAsset: NonFungibleFromJson? {
        balance.balance.compactMap { $0.nonFungibleBalance }.first
    }
}

extension PopularToken: HasTokenImage {
    public var symbol: String { "" }
    public var type: TokenType { .erc20 }
    public var firstNftAsset: NonFungibleFromJson? { nil }
}

public class TokenImageFetcher {
    enum ImageAvailabilityError: LocalizedError {
        case notAvailable
    }

    public static var instance = TokenImageFetcher()

    private static var subscribables: AtomicDictionary<String, Subscribable<TokenImage>> = .init()
    
    private static func programmaticallyGenerateIcon(for contractAddress: DerbyWallet.Address, type: TokenType, server: RPCServer, symbol: String, colors: [UIColor], staticOverlayIcon: UIImage?, blockChainNameColor: UIColor) -> TokenImage? {
        guard let i = [Constants.Image.numberOfCharactersOfSymbolToShowInIcon, symbol.count].min() else { return nil }
        let symbol = symbol.substring(to: i)
        let rawImage: UIImage?
        let _overlayServerIcon: UIImage?

        switch type {
        case .erc1155, .erc721, .erc721ForTickets:
            rawImage = nil
            _overlayServerIcon = staticOverlayIcon
        case .erc20, .erc875:
            rawImage = programmaticallyGeneratedIconImage(for: contractAddress, server: server, colors: colors, blockChainNameColor: blockChainNameColor)
            _overlayServerIcon = staticOverlayIcon
        case .nativeCryptocurrency:
            rawImage = programmaticallyGeneratedIconImage(for: contractAddress, server: server, colors: colors, blockChainNameColor: blockChainNameColor)
            _overlayServerIcon = nil
        }

        return (image: .image(rawImage), symbol: symbol, isFinal: false, overlayServerIcon: _overlayServerIcon)
    }

    private func getDefaultOrGenerateIcon(server: RPCServer, contractAddress: DerbyWallet.Address, type: TokenType, name: String, tokenImage: UIImage?, colors: [UIColor], staticOverlayIcon: UIImage?, blockChainNameColor: UIColor, serverIconImage: UIImage?) -> TokenImage? {
        switch type {
        case .nativeCryptocurrency:
            if let img = serverIconImage {
                return (image: .image(img), symbol: "", isFinal: true, overlayServerIcon: nil)
            }
        case .erc20, .erc875, .erc721, .erc721ForTickets, .erc1155:
            if let img = tokenImage {
                return (image: .image(img), symbol: "", isFinal: true, overlayServerIcon: staticOverlayIcon)
            }
        }

        return TokenImageFetcher.programmaticallyGenerateIcon(for: contractAddress, type: type, server: server, symbol: name, colors: colors, staticOverlayIcon: staticOverlayIcon, blockChainNameColor: blockChainNameColor)
    }

    private static var imageFetcher: ImageFetcher?

    public static func register(imageFetcher obj: ImageFetcher?) {
        imageFetcher = obj
    }

    public func image(contractAddress: DerbyWallet.Address, server: RPCServer, name: String, type: TokenType, balance: NonFungibleFromJson?, size: GoogleContentSize, contractDefinedImage: UIImage?, colors: [UIColor], staticOverlayIcon: UIImage?, blockChainNameColor: UIColor, serverIconImage: UIImage?) -> Subscribable<TokenImage> {
        let subscribable: Subscribable<TokenImage>
        let key = "\(contractAddress.eip55String)-\(server.chainID)-\(size.rawValue)"
        if let sub = TokenImageFetcher.subscribables[key] {
            subscribable = sub
            if let value = sub.value, value.isFinal {
                return subscribable
            }
        } else {
            let sub = Subscribable<TokenImage>(nil)
            TokenImageFetcher.subscribables[key] = sub
            subscribable = sub
        }

        let generatedImage = getDefaultOrGenerateIcon(server: server, contractAddress: contractAddress, type: type, name: name, tokenImage: contractDefinedImage, colors: colors, staticOverlayIcon: staticOverlayIcon, blockChainNameColor: blockChainNameColor, serverIconImage: serverIconImage)
        if contractAddress.sameContract(as: Constants.nativeCryptoAddressInDatabase) {
            subscribable.send(generatedImage)
            return subscribable
        }

        if subscribable.value == nil {
            subscribable.send(generatedImage)
        }

        if let image = generatedImage, image.isFinal {
            return subscribable
        }

        firstly {
            TokenImageFetcher
                .fetchFromAssetGitHubRepo(.alphaWallet, contractAddress: contractAddress)
                .map { image -> TokenImage in
                    return (image: .image(image), symbol: "", isFinal: true, overlayServerIcon: staticOverlayIcon)
                }
        }.recover { _ -> Promise<TokenImage> in
            let url = try TokenImageFetcher.imageUrlFromOpenSea(type, balance: balance, size: size)
            return .value((image: url, symbol: "", isFinal: true, overlayServerIcon: staticOverlayIcon))
        }.recover { _ -> Promise<TokenImage> in
            return TokenImageFetcher
                .fetchFromAssetGitHubRepo(.thirdParty, contractAddress: contractAddress)
                .map { image -> TokenImage in
                    return (image: .image(image), symbol: "", isFinal: false, overlayServerIcon: staticOverlayIcon)
                }
        }.done { value in
            subscribable.send(value)
        }.catch { _ in
            subscribable.send(generatedImage)
        }

        return subscribable
    }

    private static func imageUrlFromOpenSea(_ type: TokenType, balance: NonFungibleFromJson?, size: GoogleContentSize) throws -> ImageOrWebImageUrl {
        switch type {
        case .erc721, .erc1155:
            guard let openSeaNonFungible = balance, let url = openSeaNonFungible.nonFungibleImageUrl(rewriteGoogleContentSizeUrl: size) else {
                throw ImageAvailabilityError.notAvailable
            }
            return .url(url)
        case .nativeCryptocurrency, .erc20, .erc875, .erc721ForTickets:
            throw ImageAvailabilityError.notAvailable
        }
    }

    private static func fetchFromAssetGitHubRepo(_ githubAssetsSource: GithubAssetsURLResolver.Source, contractAddress: DerbyWallet.Address) -> Promise<UIImage> {
        struct AnyError: Error { }
        let urlString = githubAssetsSource.url(forContract: contractAddress)
        guard let url = URL(string: urlString) else {
            return .init(error: AnyError())
        }

        guard let fetcher = imageFetcher else { return .init(error: AnyError()) }
        return fetcher.retrieveImage(with: url)
    }
}

public protocol ImageFetcher: AnyObject {
    func retrieveImage(with url: URL) -> Promise<UIImage>
}

class GithubAssetsURLResolver {
    static let file = "logo.png"

    enum Source: String {
        case alphaWallet = "https://raw.githubusercontent.com/AlphaWallet/iconassets/lowercased/"
        case thirdParty = "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/"

        func url(forContract contract: DerbyWallet.Address) -> String {
            switch self {
            case .alphaWallet:
                return rawValue + contract.eip55String.lowercased() + "/" + GithubAssetsURLResolver.file
            case .thirdParty:
                return rawValue + contract.eip55String + "/" + GithubAssetsURLResolver.file
            }
        }
    }
}
