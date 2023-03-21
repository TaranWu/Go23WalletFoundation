//
//  ConfirmResult.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public enum ConfirmType {
    case sign
    case signThenSend
}

public enum ConfirmResult {
    case signedTransaction(Data)
    case sentTransaction(SentTransaction)
    case sentRawTransaction(id: String, original: String)
}
