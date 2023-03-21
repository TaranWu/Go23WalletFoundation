//
//  Web3.swift
//  Go23WalletFoundation
//
//  Created by Taran.
//

import Foundation
import Go23Web3Swift
import BigInt

extension Web3.Utils {
    public static func recoverPublicKey(message: Data, v: UInt8, r: [UInt8], s: [UInt8]) -> Data? {
        Web3.Utils.personalECRecoverPublicKey(message: message, r: r, s: s, v: v)
    }

    public static func ecrecover(message: Data, signature: Data) -> EthereumAddress? {
        //need to hash message here because the web3swift implementation adds prefix
        let messageHash = message.sha3(.keccak256)
        let signatureString = signature.hexString.add0x
        //note: web3swift takes the v value as v - 27, so we need to manually convert this
        let vValue = signatureString.drop0x.substring(from: 128)
        let vInt = Int(vValue, radix: 16)! - 27
        let vString = "0" + String(vInt)
        let signature = "0x" + signatureString.drop0x.substring(to: 128) + vString

        return Web3.Utils.hashECRecover(hash: messageHash, signature: Data(bytes: signature.hexToBytes))
    }

    public static func ecrecover(signedOrder: SignedOrder) -> EthereumAddress? {
        //need to hash message here because the web3swift implementation adds prefix
        let messageHash = Data(bytes: signedOrder.message).sha3(.keccak256)
        //note: web3swift takes the v value as v - 27, so we need to manually convert this
        let vValue = signedOrder.signature.drop0x.substring(from: 128)
        let vInt = Int(vValue, radix: 16)! - 27
        let vString = "0" + String(vInt)
        let signature = "0x" + signedOrder.signature.drop0x.substring(to: 128) + vString

        return Web3.Utils.hashECRecover(hash: messageHash, signature: Data(bytes: signature.hexToBytes))
    }
}
