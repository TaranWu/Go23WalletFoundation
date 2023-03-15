//
//  Ramp.swift
//  DerbyWallet
//
//  Created by Tatan.
//

import Foundation
import Combine
import Alamofire
import Go23WalletCore

public final class Ramp: SupportedTokenActionsProvider, BuyTokenURLProviderType {
    private var objectWillChangeSubject = PassthroughSubject<Void, Never>()
    private var assets: [Asset] = []
    private let decoder = JSONDecoder()
    private let queue: DispatchQueue = .init(label: "org.DerbyWallet.swift.Ramp")
    private var cancelable = Set<AnyCancellable>()

    public var objectWillChange: AnyPublisher<Void, Never> {
        objectWillChangeSubject.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
    public let analyticsNavigation: Analytics.Navigation = .onRamp
    public let analyticsName: String = "Ramp"
    public let action: String

    public func url(token: TokenActionsIdentifiable, wallet: Wallet) -> URL? {
        let symbol = asset(for: token)?.symbol
        return symbol
            .flatMap { Constants.buyWithRampUrl(asset: $0, wallet: wallet) }
            .flatMap { URL(string: $0) }
    }

    public init(action: String) {
        self.action = action
    }

    public func actions(token: TokenActionsIdentifiable) -> [TokenInstanceAction] {
        return [.init(type: .buy(service: self))]
    }

    public func isSupport(token: TokenActionsIdentifiable) -> Bool {
        return asset(for: token) != nil
    }

    private func asset(for token: TokenActionsIdentifiable) -> Asset? {
        //We only operate for mainnets. This is because we store native cryptos for Ethereum testnets like `.goerli` with symbol "ETH" which would match Ramp's Ethereum token
        guard !token.server.isTestnet else { return nil }
        return assets.first(where: {
            $0.symbol.lowercased() == token.symbol.trimmingCharacters(in: .controlCharacters).lowercased()
                    && $0.decimals == token.decimals
                    && ($0.address == nil ? token.contractAddress.sameContract(as: Constants.nativeCryptoAddressInDatabase) : $0.address!.sameContract(as: token.contractAddress))
        })
    }

    public func start() {
        let request = RampRequest()
        Just(request)
            .receive(on: queue)
            .setFailureType(to: PromiseError.self)
            .flatMap { request -> AnyPublisher<[Asset], PromiseError> in
                self.retrieveAssets(request)
            }.sink { [objectWillChangeSubject] result in
                objectWillChangeSubject.send(())

                guard case .failure(let error) = result else { return }
            } receiveValue: {
                self.assets = $0
            }.store(in: &cancelable)
    }

    private func retrieveAssets(_ request: RampRequest) -> AnyPublisher<[Asset], PromiseError> {
        return Alamofire.request(request)
            .responseDataPublisher(queue: queue)
            .tryMap { [decoder] in try decoder.decode(RampAssetsResponse.self, from: $0.data).assets }
            .mapError { PromiseError.some(error: $0) }
            .eraseToAnyPublisher()
    }
}

private struct RampRequest: URLRequestConvertible {

    func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(url: Constants.Ramp.exchangeUrl, resolvingAgainstBaseURL: false) else { throw URLError(.badURL) }
        components.path = "/api/host-api/assets"
        let url = try components.asURL()
        return try URLRequest(url: url, method: .get)
    }
}

private struct RampAssetsResponse {
    let assets: [Asset]
}

private struct Asset {
    let symbol: String
    let address: DerbyWallet.Address?
    let name: String
    let decimals: Int
}

extension RampAssetsResponse: Codable {}

extension Asset: Codable {
    private enum CodingKeys: String, CodingKey {
        case symbol
        case address
        case name
        case decimals
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try? container.decode(String.self, forKey: .address) {
            address = DerbyWallet.Address(string: value)
        } else {
            address = .none
        }

        symbol = try container.decode(String.self, forKey: .symbol)
        name = try container.decode(String.self, forKey: .name)
        decimals = try container.decode(Int.self, forKey: .decimals)
    }

}
