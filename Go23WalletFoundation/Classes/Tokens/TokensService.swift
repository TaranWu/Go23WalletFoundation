//
//  TokensService.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation
import Combine

public protocol TokenProvidable {
    func token(for contract: Go23Wallet.Address) -> Token?
    func token(for contract: Go23Wallet.Address, server: RPCServer) -> Token?
    func tokens(for servers: [RPCServer]) -> [Token]

    func tokenPublisher(for contract: Go23Wallet.Address, server: RPCServer) -> AnyPublisher<Token?, Never>
    func tokensPublisher(servers: [RPCServer]) -> AnyPublisher<[Token], Never>
    func tokensChangesetPublisher(servers: [RPCServer]) -> AnyPublisher<ChangeSet<[Token]>, Never>
}

public protocol TokenAddable {
    @discardableResult func addOrUpdate(tokensOrContracts: [TokenOrContract]) -> [Token]
    @discardableResult func addOrUpdate(with actions: [AddOrUpdateTokenAction]) -> [Token]
}

public protocol TokenAutoDetectable {
    var newTokens: AnyPublisher<[Token], Never> { get }
}

public protocol TokensState {
    var tokens: [Token] { get }
    var tokensPublisher: AnyPublisher<[Token], Never> { get }
}

public protocol TokenHidable {
    func mark(token: TokenIdentifiable, isHidden: Bool)
}

public protocol TokensServiceTests {
    func setBalanceTestsOnly(balance: Balance, for token: Token)
    func setNftBalanceTestsOnly(_ value: NonFungibleBalance, for token: Token)
    func addOrUpdateTokenTestsOnly(token: Token)
    func deleteTokenTestsOnly(token: Token)
}

public protocol PipelineTests: CoinTickersFetcherTests { }

public protocol TokenUpdatable {
    func update(token: TokenIdentifiable, value: TokenFieldUpdate)
    @discardableResult func updateToken(primaryKey: String, action: TokenFieldUpdate) -> Bool?
}

public protocol TokensService: TokensState, TokenProvidable, TokenAddable, TokenHidable, TokenAutoDetectable, TokenBalanceRefreshable, TokensServiceTests, TokenUpdatable, DetectedContractsProvideble {
    func refresh()
    func start()
    func stop()
}
