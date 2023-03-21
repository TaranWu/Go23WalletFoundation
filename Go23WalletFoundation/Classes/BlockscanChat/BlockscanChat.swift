// Copyright © 2022 Stormbird PTE. LTD.

import Foundation
import SwiftyJSON
import Combine
import Go23WalletCore

public class BlockscanChat {
    private var lastKnownCount: Int?
    private let networkService: NetworkService

    let address: Go23Wallet.Address

    public enum ResponseError: Error {
        case statusCode(Int)
        case other(Error)
    }

    public init(networkService: NetworkService, address: Go23Wallet.Address) {
        self.address = address
        self.networkService = networkService
    }

    public func fetchUnreadCount() -> AnyPublisher<Int, BlockscanChat.ResponseError> {
        return networkService
            .dataTaskPublisher(GetUnreadCountEndpointRequest(address: address))
            .receive(on: DispatchQueue.global())
            .mapError { BlockscanChat.ResponseError.other($0) }
            .flatMap { response -> AnyPublisher<Int, BlockscanChat.ResponseError> in
                do {
                    let json = try JSON(data: response.data)
                    return .just(json["result"].intValue)
                } catch {
                    return .fail(.statusCode(response.response.statusCode))
                }
            }.handleEvents(receiveOutput: { [weak self] in
                self?.lastKnownCount = $0
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

extension BlockscanChat {
    struct GetUnreadCountEndpointRequest: URLRequestConvertible {
        let address: Go23Wallet.Address

        func asURLRequest() throws -> URLRequest {
            guard var components = URLComponents(url: Constants.BlockscanChat.unreadCountBaseUrl, resolvingAgainstBaseURL: false) else { throw URLError(.badURL) }
            components.path = "/blockscanchat/unreadcount/\(address.eip55String)"

            return try URLRequest(url: components.asURL(), method: .get, headers: [
                "PROXY_KEY": Constants.Credentials.blockscanChatProxyKey
            ])
        }
    }
}
