// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import BigInt
import Go23TrustKeystore
import Go23Web3Swift
import Go23WalletAddress

public enum AssetAttributeValueUsableAsFunctionArguments {
    case address(Go23Wallet.Address)
    case string(String)
    case int(BigInt)
    case uint(BigUInt)
    case generalisedTime(GeneralisedTime)
    case bool(Bool)
    case bytes(Data)

    public init?(assetAttribute: AssetInternalValue) {
        switch assetAttribute {
        case .address(let address):
            self = .address(address)
        case .string(let string):
            self = .string(string)
        case .int(let int):
            self = .int(int)
        case .uint(let uint):
            self = .uint(uint)
        case .generalisedTime(let generalisedTime):
            self = .generalisedTime(generalisedTime)
        case .bool(let bool):
            self = .bool(bool)
        case .bytes(let bytes):
            self = .bytes(bytes)
        case .openSeaNonFungibleTraits, .subscribable:
            return nil
        }
    }

    //Returns slightly different results based on the functionType (call or transaction) because we use different encoders for them
    public func coerce(toArgumentType type: SolidityType, forFunctionType functionType: FunctionOrigin.FunctionType) -> AnyObject? {
        //We could have use a switch on a tuple of 2 values — the input and output types, but that will end up with a switch with a default label; then we'll easily forget to update the switch statement when new matching type conversion pairs become available
        switch type {
        case .address:
            return coerceToAddress(forFunctionType: functionType)
        case .bool:
            return coerceToBool(forFunctionType: functionType) as AnyObject
        case .int, .int8, .int16, .int24, .int32, .int40, .int48, .int56, .int64, .int72, .int80, .int88, .int96, .int104, .int112, .int120, .int128, .int136, .int144, .int152, .int160, .int168, .int176, .int184, .int192, .int200, .int208, .int216, .int224, .int232, .int240, .int248, .int256:
            return coerceToInt(forFunctionType: functionType) as AnyObject
        case .string, .bytes:
            return coerceToString(forFunctionType: functionType) as AnyObject
        case .bytes1, .bytes2, .bytes3, .bytes4, .bytes5, .bytes6, .bytes7, .bytes8, .bytes9, .bytes10, .bytes11, .bytes12, .bytes13, .bytes14, .bytes15, .bytes16, .bytes17, .bytes18, .bytes19, .bytes20, .bytes21, .bytes22, .bytes23, .bytes24, .bytes25, .bytes26, .bytes27, .bytes28, .bytes29, .bytes30, .bytes31, .bytes32:
            return coerceToBytes(forFunctionType: functionType) as AnyObject
        case .uint, .uint8, .uint16, .uint24, .uint32, .uint40, .uint48, .uint56, .uint64, .uint72, .uint80, .uint88, .uint96, .uint104, .uint112, .uint120, .uint128, .uint136, .uint144, .uint152, .uint160, .uint168, .uint176, .uint184, .uint192, .uint200, .uint208, .uint216, .uint224, .uint232, .uint240, .uint248, .uint256:
            return coerceToUInt(forFunctionType: functionType) as AnyObject
        case .void:
            return nil
        }
    }

    public func coerceToArgumentTypeForEventFilter(_ parameterType: SolidityType) -> EventFilterable? {
        guard let value = coerce(toArgumentType: parameterType, forFunctionType: .eventFiltering) else { return nil }
        //Need to perform an intermediate cast to BigInt, Data, etc before returning (and hence "casting" as `EventFilterable`)
        switch value {
        case let int as BigInt:
            return int
        case let uint as BigUInt:
            return uint
        case let data as Data:
            return data
        case let string as String:
            return string
        case let address as EthereumAddress:
            return address
        default:
            return nil
        }
    }

    private func coerceToAddress(forFunctionType functionType: FunctionOrigin.FunctionType) -> AnyObject? {
        switch self {
        case .address(let address):
            switch functionType {
            case .functionCall:
                return address.eip55String as AnyObject
            case .functionTransaction, .paymentTransaction:
                return Address(address: address) as AnyObject
            case .eventFiltering:
                return EthereumAddress(address: address) as AnyObject
            }
        case .string(let string):
            switch functionType {
            case .functionCall:
                //Not use .init(string:) so that addresses like "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE" can go through
                return Go23Wallet.Address(uncheckedAgainstNullAddress: string)?.eip55String as AnyObject
            case .functionTransaction, .paymentTransaction:
                //Not use .init(string:) so that addresses like "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE" can go through
                return Address(uncheckedAgainstNullAddress: string) as AnyObject
            case .eventFiltering:
                return EthereumAddress(string) as AnyObject
            }
        case .int, .uint, .generalisedTime, .bool, .bytes:
            return nil
        }
    }

    private func coerceToBool(forFunctionType functionType: FunctionOrigin.FunctionType) -> Bool? {
        switch self {
        case .bool(let bool):
            return bool
        case .string(let string):
            switch string {
            case "TRUE", "true":
                return true
            case "FALSE", "false":
                return false
            default:
                return nil
            }
        case .int(let int):
            switch int {
            case 1:
                return true
            case 0:
                return false
            default:
                return nil
            }
        case .uint(let uint):
            switch uint {
            case 1:
                return true
            case 0:
                return false
            default:
                return nil
            }
        case .bytes(let data):
            let dataAsBigUInt = BigUInt(data)
            switch dataAsBigUInt {
            case 1:
                return true
            case 0:
                return false
            default:
                return nil
            }
        case .address, .generalisedTime:
            return nil
        }
    }

    private func coerceToInt(forFunctionType functionType: FunctionOrigin.FunctionType) -> BigInt? {
        switch self {
        case .int(let int):
            return int
        case .uint(let uint):
            return BigInt(uint)
        case .string(let string):
            return BigInt(string)
        case .address, .generalisedTime, .bool, .bytes:
            return nil
        }
    }

    private func coerceToString(forFunctionType functionType: FunctionOrigin.FunctionType) -> String {
        switch self {
        case .address(let address):
            return address.eip55String
        case .string(let string):
            return string
        case .bytes(let bytes):
            return bytes.hexEncoded
        case .int(let int):
            return int.description
        case .uint(let uint):
            return uint.description
        case .generalisedTime(let generalisedTime):
            return generalisedTime.formatAsGeneralisedTime
        case .bool(let bool):
            return bool.description
        }
    }

    private func coerceToUInt(forFunctionType functionType: FunctionOrigin.FunctionType) -> BigUInt? {
        switch self {
        case .int(let int):
            return BigUInt(int)
        case .uint(let uint):
            return uint
        case .string(let string):
            return BigUInt(string)
        case .bytes(let data):
            return BigUInt(data)
        case .address, .generalisedTime, .bool:
            return nil
        }
    }

    private func coerceToBytes(forFunctionType functionType: FunctionOrigin.FunctionType) -> Data? {
        switch self {
        case .int(let int):
            return BigUInt(int).serialize()
        case .uint(let uint):
            return uint.serialize()
        case .string(let string):
            if string.hasPrefix("0x"), string.count > 2, string.count % 2 == 0 {
                return Data(_hex: string)
            } else {
                return string.data(using: .utf8)
            }
        case .bytes(let data):
            return data
        case .address, .generalisedTime, .bool:
            return nil
        }
    }

    static func dictionary(fromAssetAttributeKeyValues assetAttributeKeyValues: [AttributeId: AssetInternalValue]) -> [AttributeId: AssetAttributeValueUsableAsFunctionArguments] {
        let availableKeyValues: [(AttributeId, AssetAttributeValueUsableAsFunctionArguments)] = assetAttributeKeyValues.map { key, value in
            if let value = AssetAttributeValueUsableAsFunctionArguments(assetAttribute: value) {
                return (key, value)
            } else {
                return nil
            }
        }.compactMap { $0 }
        return Dictionary(uniqueKeysWithValues: availableKeyValues)
    }
}
