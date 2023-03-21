//
//  GasPriceWarning.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

extension TransactionConfigurator {
    public enum GasPriceWarning {
        case tooHighCustomGasPrice
        case networkCongested
        case tooLowCustomGasPrice
    }
}
