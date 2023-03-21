//
//  WalletConnectTransaction.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//
import Go23WalletCore
import Foundation
import BigInt

public struct WalletConnectTransaction {
    public let value: BigUInt?
    public let to: Go23Wallet.Address?
    public let data: Data
    public let gasLimit: BigUInt?
    public let gasPrice: BigUInt?
    public let nonce: BigUInt?

    public init(value: BigUInt? = nil,
                to: Go23Wallet.Address? = nil,
                data: Data = Data(),
                gasLimit: BigUInt? = nil,
                gasPrice: BigUInt? = nil,
                nonce: BigUInt? = nil) {

        self.value = value
        self.to = to
        self.data = data
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.nonce = nonce
    }
}

extension WalletConnectTransaction: Decodable {
    private enum CodingKeys: String, CodingKey {
        case from
        case to
        case gas
        case gasLimit
        case gasPrice
        case nonce
        case value
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        to = (try? container.decode(String.self, forKey: .to)).flatMap { Go23Wallet.Address(string: $0) }
        let gasLimit = (try? container.decode(String.self, forKey: .gasLimit)).flatMap { BigUInt($0.drop0x, radix: 16) }
        let gas = (try? container.decode(String.self, forKey: .gas)).flatMap { BigUInt($0.drop0x, radix: 16) }
        self.gasLimit = gasLimit ?? gas
        gasPrice = (try? container.decode(String.self, forKey: .gasPrice)).flatMap { BigUInt($0.drop0x, radix: 16) }
        value = (try? container.decode(String.self, forKey: .value)).flatMap { BigUInt($0.drop0x, radix: 16) } ?? .zero
        nonce = (try? container.decode(String.self, forKey: .nonce)).flatMap { BigUInt($0.drop0x, radix: 16) }
        data = (try? container.decode(String.self, forKey: .data)).flatMap { Data.fromHex($0) } ?? Data()

    }
}
