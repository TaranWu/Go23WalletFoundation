//
//  SwapTokenError.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public enum SwapTokenError: LocalizedError {
    case swapNotSupported
}

public enum BuyCryptoError: LocalizedError {
    case buyNotSupported
}

public enum ActiveWalletError: LocalizedError {
    case unavailableToResolveSwapActionProvider
    case unavailableToResolveBridgeActionProvider
    case bridgeNotSupported
    case buyNotSupported
    case operationForTokenNotFound
}

public enum WalletApiError: LocalizedError {
    case connectionAddressNotFound
    case requestedWalletNonActive
    case requestedServerDisabled
    case cancelled
}
